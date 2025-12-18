import { tool } from "@opencode-ai/plugin";

/**
 * TypeScript type check with smart error grouping
 */
export default tool({
  description: "Run TypeScript type check, return errors grouped by file",
  args: {
    file: tool.schema
      .string()
      .optional()
      .describe("Specific file to check (optional)"),
  },
  async execute({ file }) {
    try {
      const cmd = file
        ? `pnpm exec tsc --noEmit "${file}" 2>&1`
        : `pnpm exec tsc --noEmit 2>&1`;

      const proc = Bun.spawn(["sh", "-c", cmd], {
        stdout: "pipe",
        stderr: "pipe",
      });

      const stdout = await new Response(proc.stdout).text();
      const stderr = await new Response(proc.stderr).text();
      const output = stdout + stderr;

      if (!output.trim()) {
        return "✓ No type errors";
      }

      // Parse errors
      const errorLines = output
        .split("\n")
        .filter((l) => l.includes("error TS"));

      if (errorLines.length === 0) {
        return "✓ No type errors";
      }

      // Group by file
      const byFile: Record<string, string[]> = {};
      for (const line of errorLines) {
        const match = line.match(
          /^([^(]+)\((\d+),(\d+)\): error (TS\d+): (.+)$/,
        );
        if (match) {
          const [, filePath, lineNum, , code, msg] = match;
          const key = filePath.trim();
          if (!byFile[key]) byFile[key] = [];
          byFile[key].push(`  L${lineNum}: ${code} - ${msg}`);
        }
      }

      const summary = Object.entries(byFile)
        .slice(0, 10) // Limit to 10 files
        .map(
          ([f, errors]) =>
            `${f}\n${errors.slice(0, 5).join("\n")}${errors.length > 5 ? `\n  ... +${errors.length - 5} more` : ""}`,
        )
        .join("\n\n");

      const total = errorLines.length;
      const filesCount = Object.keys(byFile).length;

      return `✗ ${total} error${total > 1 ? "s" : ""} in ${filesCount} file${filesCount > 1 ? "s" : ""}:\n\n${summary}`;
    } catch (e) {
      return `Type check failed: ${e}`;
    }
  },
});
