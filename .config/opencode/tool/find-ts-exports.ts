import { tool } from "@opencode-ai/plugin";

/**
 * Find where a symbol is exported from in the codebase
 */
export default tool({
  description: "Find where a symbol is exported from in the codebase",
  args: {
    name: tool.schema.string().describe("Symbol name to find"),
    dir: tool.schema
      .string()
      .optional()
      .describe("Directory to search (default: src/)"),
  },
  async execute({ name, dir = "src/" }) {
    // Search for various export patterns
    const patterns = [
      `export (function|const|let|class|type|interface|enum) ${name}\\b`,
      `export \\{ [^}]*\\b${name}\\b`,
      `export default ${name}\\b`,
      `export \\* from`, // re-exports
    ];

    const results: string[] = [];

    for (const pattern of patterns.slice(0, 3)) {
      try {
        const output =
          await Bun.$`rg "${pattern}" ${dir} -n --glob "*.ts" --glob "*.tsx" --glob "*.js" --glob "*.jsx" 2>/dev/null`.text();
        if (output.trim()) {
          results.push(...output.trim().split("\n"));
        }
      } catch {
        // rg returns non-zero if no matches
      }
    }

    // Also check for re-exports that might include this symbol
    try {
      const reexports =
        await Bun.$`rg "export \\*" ${dir} -l --glob "*.ts" --glob "*.tsx" 2>/dev/null`.text();
      if (reexports.trim()) {
        results.push(`\nPossible re-export barrels:\n${reexports.trim()}`);
      }
    } catch {
      // ignore
    }

    if (results.length === 0) {
      return `No exports found for: ${name}`;
    }

    // Dedupe and format
    const unique = [...new Set(results)].slice(0, 20);
    return `Exports for "${name}":\n${unique.join("\n")}`;
  },
});
