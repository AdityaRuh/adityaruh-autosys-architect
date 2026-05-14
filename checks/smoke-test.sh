#!/usr/bin/env bash
# Pre-install smoke test. Runs every validator and a minimal install
# rehearsal without touching $HERMES_HOME.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_ROOT="$(dirname "$SCRIPT_DIR")"

echo "===================================="
echo "  Hermes package smoke test"
echo "===================================="
echo "Package: $PKG_ROOT"
echo

if [[ ! -f "$PKG_ROOT/.env" ]]; then
  echo "❌  Missing .env. Copy config/env.example to .env first." >&2
  exit 1
fi

echo "[1/3] Profile validator"
"$SCRIPT_DIR/validate-hermes-profile.sh"
echo

echo "[2/3] Skills validator"
"$SCRIPT_DIR/validate-skills.sh"
echo

echo "[3/3] Install dry-run"
if [[ -x "$PKG_ROOT/install.sh" ]]; then
  bash "$PKG_ROOT/install.sh" --dry-run
else
  echo "  ⚠ install.sh is not executable — chmod +x install.sh"
fi

echo
echo "✅  Smoke test passed. Safe to run ./install.sh"
