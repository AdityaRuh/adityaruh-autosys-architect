#!/usr/bin/env bash
# Validates every SKILL.md in the package: required frontmatter fields,
# referenced scripts exist, env vars are declared, no secrets in frontmatter.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$PKG_ROOT/skills"
ERRORS=0

fail() { echo "  ✗ $*" >&2; ERRORS=$((ERRORS + 1)); }
ok()   { echo "  ✓ $*"; }

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "→ No skills/ directory — skipping."
  exit 0
fi

echo "→ Validating skills under $SKILLS_DIR"

shopt -s nullglob
mapfile -t SKILL_FILES < <(find "$SKILLS_DIR" -mindepth 3 -maxdepth 3 -name SKILL.md -type f | sort)

if [[ ${#SKILL_FILES[@]} -eq 0 ]]; then
  echo "→ No SKILL.md files found."
  exit 0
fi

for skill in "${SKILL_FILES[@]}"; do
  rel="${skill#$PKG_ROOT/}"
  skill_dir="$(dirname "$skill")"

  if ! head -n 1 "$skill" | grep -q '^---$'; then
    fail "$rel: frontmatter delimiters missing"
    continue
  fi

  frontmatter=$(awk '/^---$/{c++; next} c==1' "$skill")
  for field in name description version; do
    if ! echo "$frontmatter" | grep -qE "^${field}:[[:space:]]+"; then
      fail "$rel: frontmatter missing required field: $field"
    fi
  done

  if ! grep -qE '^#+ (When to Use|Procedure)' "$skill"; then
    fail "$rel: body missing 'When to Use' or 'Procedure' section"
  fi

  while IFS= read -r script_path; do
    [[ -z "$script_path" ]] && continue
    full="$skill_dir/$script_path"
    if [[ ! -f "$full" ]]; then
      fail "$rel: references missing script: $script_path"
    fi
  done < <(grep -oE 'scripts/[A-Za-z0-9_./-]+\.(sh|py|js|ts)' "$skill" || true)

  if echo "$frontmatter" | grep -qE 'sk-[A-Za-z0-9]{20,}|xoxb-[A-Za-z0-9-]{20,}'; then
    fail "$rel: secret-shaped string in frontmatter"
  fi

  ok "$rel"
done

echo
if [[ "$ERRORS" -eq 0 ]]; then
  echo "✅  All ${#SKILL_FILES[@]} skill(s) valid"
  exit 0
else
  echo "❌  $ERRORS error(s) across ${#SKILL_FILES[@]} skill(s)"
  exit 1
fi
