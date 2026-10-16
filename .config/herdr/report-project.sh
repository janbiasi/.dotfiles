#!/usr/bin/env bash
# Report the git project (directory name of the main checkout) as the herdr
# pane metadata token "project". Worktrees resolve to their main checkout.
#
# Usage: report-project.sh [--print] [--claude-hook] [cwd]
#   --print        print the project name instead of reporting it
#   --claude-hook  read the cwd from the Claude Code hook JSON on stdin
set -euo pipefail

print_only=0
claude_hook=0
cwd=$PWD
for arg in "$@"; do
  case $arg in
    --print) print_only=1 ;;
    --claude-hook) claude_hook=1 ;;
    *) cwd=$arg ;;
  esac
done

((print_only)) || [[ ${HERDR_ENV:-} == 1 ]] || exit 0

if ((claude_hook)); then
  # empty for subagent events, which must not override the parent's project
  cwd=$(jq -r 'if .agent_id then empty else .cwd // empty end')
  [[ -n $cwd ]] || exit 0
fi

# the first worktree listed is always the main checkout
main_checkout=$(git -C "$cwd" worktree list --porcelain 2>/dev/null | head -n1 || true)
project=${main_checkout#worktree }
project=${project##*/}

if ((print_only)); then
  echo "$project"
  exit 0
fi

args=(--source dotfiles:project)
if [[ -n $project ]]; then
  args+=(--token "project=$project")
else
  args+=(--clear-token project)
fi
timeout 3 herdr pane report-metadata "$HERDR_PANE_ID" "${args[@]}" >/dev/null
