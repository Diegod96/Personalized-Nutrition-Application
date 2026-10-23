#!/usr/bin/env bash
# One verification command for CI and agents.
# Usage: scripts/verify.sh [engine|app|supabase]   (no argument runs all three)
set -euo pipefail

cd "$(dirname "$0")/.."

verify_engine() {
  if [[ -f Packages/FuelingEngine/Package.swift ]]; then
    swift test --package-path Packages/FuelingEngine
  else
    echo "FuelingEngine not created yet; skipping"
  fi
}

verify_app() {
  local project=""
  if [[ -d App ]]; then
    project=$(find App -maxdepth 2 -name '*.xcodeproj' -print -quit)
  fi
  if [[ -z "$project" ]]; then
    echo "No Xcode project under App/ yet; skipping"
    return 0
  fi
  local scheme="${SCHEME:-$(basename "$project" .xcodeproj)}"
  local destination="${DESTINATION:-platform=iOS Simulator,name=iPhone 17}"
  rm -rf build/TestResults.xcresult
  mkdir -p build
  xcodebuild test \
    -project "$project" \
    -scheme "$scheme" \
    -destination "$destination" \
    -resultBundlePath build/TestResults.xcresult
}

verify_supabase() {
  if [[ -d supabase/functions ]]; then
    (cd supabase/functions && deno test)
  else
    echo "supabase/functions not created yet; skipping"
  fi
}

case "${1:-all}" in
  engine) verify_engine ;;
  app) verify_app ;;
  supabase) verify_supabase ;;
  all)
    verify_engine
    verify_app
    verify_supabase
    ;;
  *)
    echo "Usage: $0 [engine|app|supabase]" >&2
    exit 2
    ;;
esac
