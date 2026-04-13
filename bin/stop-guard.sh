#!/usr/bin/env bash
set -euo pipefail

# Prevent infinite Stop hook loops
INPUT=$(cat)
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)
[[ "$STOP_ACTIVE" == "true" ]] && exit 0

# Check for unstaged formatting changes that auto-format.sh may have created
if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  DIRTY=$(git diff --name-only 2>/dev/null | head -5)
  if [[ -n "$DIRTY" ]]; then
    cat <<EOF
{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"Auto-format changed these files since last edit. Consider staging them:\n$(echo "$DIRTY" | tr '\n' ' ')"}}
EOF
    exit 0
  fi
fi

exit 0
