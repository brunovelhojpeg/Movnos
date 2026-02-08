#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Package name: $(grep '^name:' "$ROOT/pubspec.yaml" | head -1 | awk '{print $2}')"
echo "Checking localization setup..."

if rg --quiet "flutter_gen/gen_l10n/app_localizations.dart" "$ROOT/lib"; then
  echo "FAIL: Found flutter_gen AppLocalizations import in lib/." >&2
  exit 1
fi

test -f "$ROOT/lib/l10n/app_pt.arb" || { echo "FAIL: lib/l10n/app_pt.arb missing" >&2; exit 1; }
test -f "$ROOT/lib/l10n/app_pt_BR.arb" || { echo "FAIL: lib/l10n/app_pt_BR.arb missing" >&2; exit 1; }

if [[ -f "$ROOT/l10n.yaml" ]]; then
  echo "l10n.yaml present:"
  cat "$ROOT/l10n.yaml"
else
  echo "FAIL: l10n.yaml missing" >&2
  exit 1
fi

echo "OK: localization guardrails passed."
