import { tool } from "@opencode-ai/plugin";

/**
 * List available package.json scripts
 */
export default tool({
  description: "List available npm/pnpm scripts from package.json",
  args: {
    filter: tool.schema
      .string()
      .optional()
      .describe("Filter scripts by name pattern"),
  },
  async execute({ filter }) {
    try {
      const pkgPath = "package.json";
      const file = Bun.file(pkgPath);

      if (!(await file.exists())) {
        return "No package.json found in current directory";
      }

      const pkg = await file.json();
      const scripts = pkg.scripts || {};

      if (Object.keys(scripts).length === 0) {
        return "No scripts defined in package.json";
      }

      let entries = Object.entries(scripts) as [string, string][];

      // Filter if pattern provided
      if (filter) {
        const pattern = filter.toLowerCase();
        entries = entries.filter(([name]) =>
          name.toLowerCase().includes(pattern),
        );
      }

      if (entries.length === 0) {
        return `No scripts matching "${filter}"`;
      }

      // Format output with alignment
      const maxNameLen = Math.min(
        20,
        Math.max(...entries.map(([n]) => n.length)),
      );

      const formatted = entries
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([name, cmd]) => {
          const truncCmd = cmd.length > 60 ? cmd.slice(0, 57) + "..." : cmd;
          return `  ${name.padEnd(maxNameLen)}  ${truncCmd}`;
        })
        .join("\n");

      return `Scripts${filter ? ` (filter: ${filter})` : ""}:\n${formatted}`;
    } catch (e) {
      return `Failed to read package.json: ${e}`;
    }
  },
});
