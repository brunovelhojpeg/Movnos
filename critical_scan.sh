#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# MOVNOS — CRITICAL SCAN (One-shot)
# What it does:
# 1) Clean + pub get (baseline)
# 2) Generate l10n (avoid false negatives)
# 3) Static analyze (flutter analyze)
# 4) Compile web + iOS (build only) to catch hard breaks
# 5) Dependency risk report (outdated + discontinued)
# 6) Grep for common “break-soon” patterns
# 7) Produces a single report file: critical_scan_report.txt
# =========================================================

REPORT="critical_scan_report.txt"
ROOT="$(pwd)"

echo "==> Writing report to: $REPORT"
rm -f "$REPORT"

log() { echo -e "$@" | tee -a "$REPORT"; }
run() {
  local title="$1"; shift
  log "\n=================================================="
  log "## $title"
  log "=================================================="
  set +e
  "$@" 2>&1 | tee -a "$REPORT"
  local code="${PIPESTATUS[0]}"
  set -e
  log "\n(exit code: $code)"
  return 0
}

log "MOVNOS Critical Scan"
log "Project: $ROOT"
log "Date: $(date)"
log "--------------------------------------------------"

# 0) sanity
if [ ! -f "$ROOT/pubspec.yaml" ]; then
  log "ERROR: Run this from your Flutter project root (where pubspec.yaml exists)."
  exit 1
fi

# 1) baseline
run "Flutter clean" flutter clean
run "Flutter pub get" flutter pub get

# 2) l10n generation (prevents “missing AppLocalizations” noise)
if [ -f "$ROOT/l10n.yaml" ] || [ -d "$ROOT/lib/l10n" ]; then
  run "Flutter gen-l10n" flutter gen-l10n
else
  log "\n[SKIP] No l10n.yaml or lib/l10n found."
fi

# 3) analyzer (most useful for “about to break”)
run "Flutter analyze (static checks)" flutter analyze

# 4) compile checks (hard failure detector)
run "Build Web (release) — compile-only check" flutter build web --release

# iOS build is optional on macOS; still useful to catch CocoaPods / Swift / plist issues.
if [[ "$(uname -s)" == "Darwin" ]]; then
  run "Build iOS (no codesign) — compile-only check" flutter build ios --no-codesign
else
  log "\n[SKIP] iOS build: not on macOS."
fi

# 5) dependency risk
run "Pub outdated — dependency drift / incompatibilities" flutter pub outdated

# 6) heuristic greps (common future-break hotspots)
log "\n=================================================="
log "## Grep scan — common breakpoints"
log "=================================================="

# A) Deprecated / removed flags
run "Search deprecated web renderer flags" bash -lc \
  "grep -RIn --exclude-dir=build --exclude-dir=.dart_tool \"--web-renderer\\|web-renderer\" . || true"

# B) Old flutter_gen localization import
run "Search old flutter_gen gen_l10n import" bash -lc \
  "grep -RIn --exclude-dir=build --exclude-dir=.dart_tool \"package:flutter_gen/gen_l10n\" lib || true"

# C) Missing localization keys patterns (context.l10n.* keys that aren't in ARBs are compile errors)
run "List all context.l10n.<key> usages (top 200)" bash -lc \
  "grep -Roh --exclude-dir=build --exclude-dir=.dart_tool \"context\\.l10n\\.[A-Za-z0-9_]*\" lib | sort | uniq | head -n 200 || true"

# D) Navigator double-push / looping issues (quick smell check)
run "Search for pushNamed in tap handlers (possible double navigation)" bash -lc \
  "grep -RIn --exclude-dir=build --exclude-dir=.dart_tool \"onTap:.*pushNamed\\|onPressed:.*pushNamed\\|pushReplacement\\|pushAndRemoveUntil\" lib || true"

# E) Common null-assertion crash hotspot
run "Search for null-assertion operator (!) in app code" bash -lc \
  "grep -RIn --exclude-dir=build --exclude-dir=.dart_tool \"!;\\|!\\]\\|!\\)\\|!\\.\" lib || true"

# F) TODO/FIXME left behind
run "Search TODO/FIXME" bash -lc \
  "grep -RIn --exclude-dir=build --exclude-dir=.dart_tool \"TODO\\|FIXME\" lib || true"

# 7) summary hints
log "\n=================================================="
log "## What to look at next (manual quick check)"
log "=================================================="
log "- Any 'ERROR' lines above in analyze/build steps are critical."
log "- If build web passes but iOS fails: focus CocoaPods/Info.plist entitlements."
log "- If analyze passes but runtime loops: look at navigation grep section."
log "- If lots of '!' results: potential runtime crashes when data is null."
log "- If pub outdated shows many incompatible updates: freeze or plan upgrades in batches."

log "\nDONE ✅  Report saved to: $REPORT"
echo "DONE ✅  Report saved to: $REPORT"
