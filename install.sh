#!/usr/bin/env bash
# Install AutoSys Architect into the configured Hermes home.
#
# Usage:
#   ./install.sh           # full install
#   ./install.sh --update  # refresh from this checkout (preserves user data)
#   ./install.sh --dry-run # show what would change without touching disk

set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="install"

for arg in "$@"; do
  case "$arg" in
    --update) MODE="update" ;;
    --dry-run) MODE="dry-run" ;;
    -h|--help)
      echo "Usage: $0 [--update|--dry-run]"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

if [[ ! -f "$SCRIPT_DIR/.env" && "$MODE" != "dry-run" ]]; then
  echo "❌  No .env found. Copy config/env.example to .env and fill in the required secrets." >&2
  exit 1
fi

echo "→ Hermes home:   $HERMES_HOME"
echo "→ Source:        $SCRIPT_DIR"
echo "→ Mode:          $MODE"
echo

run() {
  if [[ "$MODE" == "dry-run" ]]; then
    echo "DRY  $*"
  else
    eval "$@"
  fi
}

# Skills — installed under ~/.hermes/skills/<category>/<id>/.
for skill_path in "$SCRIPT_DIR"/skills/*/*/SKILL.md; do
  [[ -e "$skill_path" ]] || continue
  rel="${skill_path#$SCRIPT_DIR/skills/}"
  dest_dir="$HERMES_HOME/skills/${rel%/SKILL.md}"
  run "mkdir -p \"$dest_dir\""
  run "cp -R \"$(dirname "$skill_path")\"/. \"$dest_dir/\""
  if command -v hermes >/dev/null 2>&1; then
    run "hermes curator pin \"${rel%/SKILL.md}\" >/dev/null 2>&1 || true"
  fi
done

# Profile-scoped files (identity, config, context, memories).
run "mkdir -p \"$HERMES_HOME/profiles/autosys-architect\""
run "cp \"$SCRIPT_DIR/identity/SOUL.md\" \"$HERMES_HOME/profiles/autosys-architect/SOUL.md\""
run "cp \"$SCRIPT_DIR/config/config.yaml\" \"$HERMES_HOME/profiles/autosys-architect/config.yaml\""
run "cp -R \"$SCRIPT_DIR/context\" \"$HERMES_HOME/profiles/autosys-architect/context\""
run "cp -R \"$SCRIPT_DIR/memories\" \"$HERMES_HOME/profiles/autosys-architect/memories\""

# Cron — register jobs if Hermes CLI is present and jobs.json is non-empty.
if command -v hermes >/dev/null 2>&1 && [[ $(jq '.jobs | length' "$SCRIPT_DIR/cron/jobs.json" 2>/dev/null || echo 0) -gt 0 ]]; then
  run "hermes cron import \"$SCRIPT_DIR/cron/jobs.json\" --label autosys-architect"
fi

echo
echo "✅  Installed. Next:"
echo "    hermes profile use autosys-architect"
# No messaging channels configured.
echo "    hermes                   # start chatting"
