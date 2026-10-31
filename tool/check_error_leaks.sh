#!/usr/bin/env bash
set -euo pipefail

status=0

check() {
  local label="$1"
  shift
  if "$@"; then
    echo "error leak guard failed: $label" >&2
    status=1
  fi
}

check "raw error inside AppToast.error" \
  bash -c "grep -rn -A3 'AppToast.error(' lib --include='*.dart' | grep -q '\$error'"

check "raw error assigned to _error" \
  bash -c "grep -rn \"_error = '\\\$error'\" lib --include='*.dart' | grep -q ."

check "raw error rendered directly" \
  bash -c "grep -rn \"Text('\\\$error')\" lib --include='*.dart' | grep -q ."

exit "$status"
