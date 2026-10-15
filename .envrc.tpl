# augment, load and unload via https://direnv.net/

export CONTEXT7_API_KEY="op://Personal/vw5uq42daywk3lrwifgth6im2a/credential"
export OPENCODE_API_KEY="op://Personal/df5vsow22qb3kgdh4keyo743ou/credential"
export KANEO_API_KEY="op://Personal/6x3imghrqsdt7zozuegruxnewm/credential"

# 1Password CLI: account `op` uses, from a per-project variable (never a literal account ID)
if [ -n "${PROJECT_OP_ACCOUNT:-}" ]; then export OP_ACCOUNT="$PROJECT_OP_ACCOUNT"; fi
