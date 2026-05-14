#!/usr/bin/env bash
# Structural validator for a Hermes agent package.
# Exits 0 only if every required file is present, parses, and has the
# expected runtime marker.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_ROOT="$(dirname "$SCRIPT_DIR")"
ERRORS=0
WARNINGS=0

fail() { echo "  ✗ $*" >&2; ERRORS=$((ERRORS + 1)); }
warn() { echo "  ⚠ $*"; WARNINGS=$((WARNINGS + 1)); }
ok()   { echo "  ✓ $*"; }

echo "→ Validating Hermes profile at $PKG_ROOT"

# manifest
if [[ ! -f "$PKG_ROOT/manifest.json" ]]; then
  fail "manifest.json missing"
else
  if command -v jq >/dev/null 2>&1; then
    if ! jq -e '.runtime == "hermes"' "$PKG_ROOT/manifest.json" >/dev/null; then
      fail "manifest.runtime != \"hermes\""
    fi
    for field in agent.id agent.name agent.description agent.version requires.hermes; do
      if [[ -z "$(jq -r ".${field} // empty" "$PKG_ROOT/manifest.json")" ]]; then
        fail "manifest missing required field: ${field}"
      fi
    done
    ok "manifest.json parses and declares runtime=hermes"
  else
    warn "jq not installed — manifest contents not validated"
  fi
fi

# config
if [[ ! -f "$PKG_ROOT/config/config.yaml" ]]; then
  fail "config/config.yaml missing"
else
  if command -v python3 >/dev/null 2>&1; then
    if ! python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$PKG_ROOT/config/config.yaml" 2>/dev/null; then
      fail "config/config.yaml fails to parse as YAML"
    else
      ok "config/config.yaml parses"
    fi
  else
    warn "python3 not installed — YAML not parsed"
  fi
fi

if [[ ! -f "$PKG_ROOT/config/env.example" ]]; then
  fail "config/env.example missing"
else
  if grep -E '^(ANTHROPIC|OPENAI|TELEGRAM|DISCORD|SLACK)_[A-Z_]+=(sk-|xoxb-|xapp-|[0-9]+:AA)' "$PKG_ROOT/config/env.example" >/dev/null 2>&1; then
    fail "config/env.example contains what looks like a real secret"
  else
    ok "config/env.example uses placeholders only"
  fi
fi

# required files
for required in identity/SOUL.md context/AGENTS.md context/HERMES.md \
                memories/MEMORY.template.md memories/USER.template.md \
                memories/memory-policy.md README.md install.sh; do
  if [[ ! -f "$PKG_ROOT/$required" ]]; then
    fail "$required missing"
  else
    ok "$required present"
  fi
done

# SOUL purity
if [[ -f "$PKG_ROOT/identity/SOUL.md" ]]; then
  if grep -qE '\$\{|export |\.env|HERMES_HOME|chmod' "$PKG_ROOT/identity/SOUL.md"; then
    fail "identity/SOUL.md contains setup instructions — keep it identity-focused"
  else
    ok "identity/SOUL.md looks identity-focused"
  fi
fi

# skills count
if [[ -d "$PKG_ROOT/skills" ]]; then
  skill_count=$(find "$PKG_ROOT/skills" -name SKILL.md -type f | wc -l | tr -d ' ')
  ok "skills present ($skill_count skill(s))"
else
  warn "skills/ directory missing"
fi

# package-wide secret scan
if grep -rEn 'sk-[A-Za-z0-9]{20,}|xoxb-[A-Za-z0-9-]{20,}|AKIA[A-Z0-9]{16}|eyJ[A-Za-z0-9_-]{20,}\.eyJ' "$PKG_ROOT" \
     --exclude-dir=.git --exclude='env.example' --exclude='*.lock' 2>/dev/null; then
  fail "credential-shaped string found in package — refuse to ship"
else
  ok "no obvious credentials in package"
fi

echo
if [[ "$ERRORS" -eq 0 ]]; then
  echo "✅  Profile valid ($WARNINGS warning(s))"
  exit 0
else
  echo "❌  $ERRORS error(s), $WARNINGS warning(s)"
  exit 1
fi
