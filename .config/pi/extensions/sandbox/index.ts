/**
 * Sandbox extension, adapted from pi's examples/extensions/sandbox.
 *
 * Runs the agent's bash commands under @anthropic-ai/sandbox-runtime
 * (bubblewrap on Linux) and applies the same path rules to pi's built-in
 * file tools, which otherwise run unconfined inside the pi process.
 *
 * Differences from the upstream example:
 * - Fails closed: if the sandbox cannot start, agent bash commands are refused.
 * - Project `.pi/sandbox.json` can only add restrictions, never disable or widen.
 * - read/write/edit/grep/find/ls are checked against denyRead/allowWrite/denyWrite.
 * - Secret environment variables are removed from sandboxed commands.
 * - Hosts outside allowedDomains prompt for approval instead of failing silently.
 * - Commands you type yourself with `!` run unsandboxed (escape hatch for
 *   podman/Testcontainers runs).
 *
 * Config: <agent dir>/sandbox.json (global, trusted)
 *         <cwd>/.pi/sandbox.json (project, additive deny rules only)
 *
 * Usage: `pi --no-sandbox` disables bash sandboxing for one session; `/sandbox`
 * shows the active configuration.
 *
 * Linux requires: bubblewrap, socat, ripgrep
 */

import { spawn } from "node:child_process";
import { existsSync, readFileSync, realpathSync } from "node:fs";
import { homedir } from "node:os";
import { basename, dirname, join, resolve, sep } from "node:path";
import {
  SandboxManager,
  type SandboxRuntimeConfig,
} from "@anthropic-ai/sandbox-runtime";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import {
  type BashOperations,
  CONFIG_DIR_NAME,
  createBashTool,
  getAgentDir,
} from "@earendil-works/pi-coding-agent";

interface SandboxConfig extends SandboxRuntimeConfig {
  enabled?: boolean;
  /** Environment variable names or `*` patterns removed from sandboxed commands. */
  denyEnv?: string[];
}

const DEFAULT_CONFIG: SandboxConfig = {
  enabled: true,
  network: {
    allowedDomains: [],
    deniedDomains: [],
  },
  filesystem: {
    denyRead: ["~/.ssh", "~/.aws", "~/.gnupg"],
    allowWrite: [".", "/tmp"],
    denyWrite: ["**/.env", "**/.env.*"],
  },
  denyEnv: [],
};

function readJson(path: string): Partial<SandboxConfig> {
  if (!existsSync(path)) return {};
  try {
    return JSON.parse(readFileSync(path, "utf-8"));
  } catch (e) {
    console.error(`Warning: Could not parse ${path}: ${e}`);
    return {};
  }
}

function loadConfig(cwd: string): SandboxConfig {
  const global = readJson(join(getAgentDir(), "sandbox.json"));
  const project = readJson(join(cwd, CONFIG_DIR_NAME, "sandbox.json"));

  const base: SandboxConfig = {
    ...DEFAULT_CONFIG,
    ...global,
    network: { ...DEFAULT_CONFIG.network, ...global.network },
    filesystem: { ...DEFAULT_CONFIG.filesystem, ...global.filesystem },
  };

  // A cloned repository must not be able to switch the sandbox off or grant
  // itself more access, so only deny lists are taken from the project file.
  const add = (a: string[] | undefined, b: string[] | undefined) => [
    ...(a ?? []),
    ...(b ?? []),
  ];
  return {
    ...base,
    network: {
      ...base.network,
      deniedDomains: add(
        base.network.deniedDomains,
        project.network?.deniedDomains,
      ),
    },
    filesystem: {
      ...base.filesystem,
      denyRead: add(base.filesystem.denyRead, project.filesystem?.denyRead),
      denyWrite: add(base.filesystem.denyWrite, project.filesystem?.denyWrite),
    },
  };
}

/** Matches whole names, e.g. environment variables: `*_TOKEN`. */
function nameGlobToRegExp(glob: string): RegExp {
  const escaped = glob
    .replace(/[.+^${}()|[\]\\]/g, "\\$&")
    .replace(/\*/g, ".*");
  return new RegExp(`^${escaped}$`);
}

/** Matches absolute paths: `**` crosses directories, `*` and `?` stay within one. */
function pathGlobToRegExp(glob: string): RegExp {
  let out = "";
  for (let i = 0; i < glob.length; i++) {
    const c = glob[i];
    if (c === "*" && glob[i + 1] === "*") {
      out += glob[i + 2] === "/" ? "(?:.*/)?" : ".*";
      i += glob[i + 2] === "/" ? 2 : 1;
    } else if (c === "*") out += "[^/]*";
    else if (c === "?") out += "[^/]";
    else out += c.replace(/[.+^${}()|[\]\\]/g, "\\$&");
  }
  return new RegExp(`^${out}(?:/.*)?$`);
}

const hasGlob = (p: string) => /[*?]/.test(p);

/** Same rules as sandbox-runtime: `~/` is home, relative entries resolve against cwd. */
function expandPath(p: string, cwd: string): string {
  if (p === "~") return homedir();
  if (p.startsWith("~/")) return join(homedir(), p.slice(2));
  return resolve(cwd, p);
}

/** Resolves symlinks, including for paths that do not exist yet. */
function realPath(p: string): string {
  try {
    return realpathSync(p);
  } catch {
    const parent = dirname(p);
    return parent === p ? p : join(realPath(parent), basename(p));
  }
}

function isWithin(path: string, base: string): boolean {
  return (
    path === base || path.startsWith(base.endsWith(sep) ? base : base + sep)
  );
}

function matchesEntry(path: string, entry: string, cwd: string): boolean {
  const expanded = expandPath(entry, cwd);
  if (hasGlob(expanded)) return pathGlobToRegExp(expanded).test(path);
  return isWithin(path, realPath(expanded));
}

/** True when a recursive search rooted at `path` would descend into `entry`. */
function containsEntry(path: string, entry: string, cwd: string): boolean {
  const expanded = expandPath(entry, cwd);
  const staticPart = hasGlob(expanded)
    ? dirname(expanded.split(/[*?]/)[0] + "x")
    : expanded;
  return isWithin(realPath(staticPart), path);
}

function checkFileTool(
  toolName: string,
  input: Record<string, unknown>,
  cwd: string,
  config: SandboxConfig,
) {
  const { denyRead = [], allowWrite = [], denyWrite = [] } = config.filesystem;
  const rawPath =
    typeof input.path === "string" && input.path !== "" ? input.path : ".";
  const path = realPath(expandPath(rawPath, cwd));

  const deniedRead = denyRead.find((entry) => matchesEntry(path, entry, cwd));
  if (deniedRead)
    return `Path "${rawPath}" is not readable in the sandbox (denyRead: ${deniedRead})`;

  if (toolName === "grep" || toolName === "find") {
    const nested = denyRead.find((entry) => containsEntry(path, entry, cwd));
    if (nested)
      return `Searching "${rawPath}" would include ${nested}, which is not readable in the sandbox`;
  }

  if (toolName === "write" || toolName === "edit") {
    if (
      !allowWrite.some((entry) =>
        isWithin(path, realPath(expandPath(entry, cwd))),
      )
    ) {
      return `Path "${rawPath}" is outside the sandbox write paths (${allowWrite.join(", ")})`;
    }
    const deniedWrite = denyWrite.find((entry) =>
      matchesEntry(path, entry, cwd),
    );
    if (deniedWrite)
      return `Path "${rawPath}" is not writable in the sandbox (denyWrite: ${deniedWrite})`;
  }

  return undefined;
}

function sandboxEnv(denyEnv: string[]): NodeJS.ProcessEnv {
  const patterns = denyEnv.map(nameGlobToRegExp);
  return Object.fromEntries(
    Object.entries(process.env).filter(
      ([name]) => !patterns.some((p) => p.test(name)),
    ),
  );
}

function createSandboxedBashOps(env: NodeJS.ProcessEnv): BashOperations {
  return {
    async exec(command, cwd, { onData, signal, timeout }) {
      if (!existsSync(cwd)) {
        throw new Error(`Working directory does not exist: ${cwd}`);
      }

      const wrappedCommand = await SandboxManager.wrapWithSandbox(command);

      return new Promise((resolve, reject) => {
        const child = spawn("bash", ["-c", wrappedCommand], {
          cwd,
          env,
          detached: true,
          stdio: ["ignore", "pipe", "pipe"],
        });

        let timedOut = false;
        let timeoutHandle: NodeJS.Timeout | undefined;

        const killGroup = () => {
          if (child.pid) {
            try {
              process.kill(-child.pid, "SIGKILL");
            } catch {
              child.kill("SIGKILL");
            }
          }
        };

        if (timeout !== undefined && timeout > 0) {
          timeoutHandle = setTimeout(() => {
            timedOut = true;
            killGroup();
          }, timeout * 1000);
        }

        child.stdout?.on("data", onData);
        child.stderr?.on("data", onData);

        child.on("error", (err) => {
          if (timeoutHandle) clearTimeout(timeoutHandle);
          reject(err);
        });

        signal?.addEventListener("abort", killGroup, { once: true });

        child.on("close", (code) => {
          if (timeoutHandle) clearTimeout(timeoutHandle);
          signal?.removeEventListener("abort", killGroup);

          if (signal?.aborted) {
            reject(new Error("aborted"));
          } else if (timedOut) {
            reject(new Error(`timeout:${timeout}`));
          } else {
            resolve({ exitCode: code });
          }
        });
      });
    },
  };
}

const FILE_TOOLS = new Set(["read", "write", "edit", "grep", "find", "ls"]);

export default function (pi: ExtensionAPI) {
  pi.registerFlag("no-sandbox", {
    description: "Disable OS-level sandboxing for bash commands",
    type: "boolean",
    default: false,
  });

  const localCwd = process.cwd();
  const localBash = createBashTool(localCwd);

  type State = "starting" | "active" | "disabled" | "failed";
  let state: State = "starting";
  let failure = "";
  let config: SandboxConfig = loadConfig(localCwd);
  let uiCtx: ExtensionContext | undefined;
  const hostDecisions = new Map<string, boolean>();

  pi.registerTool({
    ...localBash,
    label: "bash (sandboxed)",
    async execute(id, params, signal, onUpdate, _ctx) {
      if (state === "disabled") {
        return localBash.execute(id, params, signal, onUpdate);
      }
      if (state !== "active") {
        throw new Error(
          `Sandbox is not active (${failure || state}); refusing to run commands unsandboxed. ` +
            "Ask the user to fix the sandbox or restart pi with --no-sandbox.",
        );
      }

      const sandboxedBash = createBashTool(localCwd, {
        operations: createSandboxedBashOps(sandboxEnv(config.denyEnv ?? [])),
      });
      return sandboxedBash.execute(id, params, signal, onUpdate);
    },
  });

  pi.on("tool_call", async (event, ctx) => {
    if (!FILE_TOOLS.has(event.toolName)) return undefined;
    const reason = checkFileTool(
      event.toolName,
      event.input as Record<string, unknown>,
      ctx.cwd,
      config,
    );
    if (!reason) return undefined;
    if (ctx.hasUI)
      ctx.ui.notify(`Sandbox blocked ${event.toolName}: ${reason}`, "warning");
    return { block: true, reason };
  });

  async function askForHost({
    host,
    port,
  }: {
    host: string;
    port?: number;
  }): Promise<boolean> {
    const key = port ? `${host}:${port}` : host;
    const known = hostDecisions.get(key);
    if (known !== undefined) return known;
    if (!uiCtx?.hasUI) return false;

    const allowed = await uiCtx.ui.confirm(
      "Sandbox network request",
      `A sandboxed command wants to connect to ${key}. Allow for this session?`,
    );
    hostDecisions.set(key, allowed);
    return allowed;
  }

  pi.on("session_start", async (_event, ctx) => {
    uiCtx = ctx;
    config = loadConfig(ctx.cwd);

    if (pi.getFlag("no-sandbox") as boolean) {
      state = "disabled";
      ctx.ui.notify(
        "Bash sandbox disabled via --no-sandbox (file tool rules still apply)",
        "warning",
      );
      return;
    }

    if (config.enabled === false) {
      state = "disabled";
      ctx.ui.notify(
        "Bash sandbox disabled in global config (file tool rules still apply)",
        "warning",
      );
      return;
    }

    if (process.platform !== "darwin" && process.platform !== "linux") {
      state = "failed";
      failure = `unsupported platform ${process.platform}`;
      ctx.ui.notify(
        `Sandbox not supported on ${process.platform}; bash is blocked`,
        "error",
      );
      return;
    }

    try {
      await SandboxManager.initialize(
        {
          network: config.network,
          filesystem: config.filesystem,
          ignoreViolations: config.ignoreViolations,
          enableWeakerNestedSandbox: config.enableWeakerNestedSandbox,
        },
        askForHost,
      );

      state = "active";
    } catch (err) {
      state = "failed";
      failure = err instanceof Error ? err.message : String(err);
      ctx.ui.notify(
        `Sandbox initialization failed; bash is blocked: ${failure}`,
        "error",
      );
    }
  });

  pi.on("session_shutdown", async () => {
    if (state === "active") {
      try {
        await SandboxManager.reset();
      } catch {
        // Ignore cleanup errors
      }
    }
  });

  pi.registerCommand("sandbox", {
    description: "Show sandbox configuration",
    handler: async (_args, ctx) => {
      const lines = [
        `Sandbox: ${state}${failure ? ` (${failure})` : ""}`,
        "",
        "Network:",
        `  Allowed: ${config.network?.allowedDomains?.join(", ") || "(none)"}`,
        `  Denied: ${config.network?.deniedDomains?.join(", ") || "(none)"}`,
        `  Approved this session: ${
          [...hostDecisions]
            .filter(([, ok]) => ok)
            .map(([h]) => h)
            .join(", ") || "(none)"
        }`,
        "",
        "Filesystem:",
        `  Deny Read: ${config.filesystem?.denyRead?.join(", ") || "(none)"}`,
        `  Allow Write: ${config.filesystem?.allowWrite?.join(", ") || "(none)"}`,
        `  Deny Write: ${config.filesystem?.denyWrite?.join(", ") || "(none)"}`,
        "",
        `Hidden env: ${config.denyEnv?.join(", ") || "(none)"}`,
      ];
      ctx.ui.notify(lines.join("\n"), "info");
    },
  });
}
