#!/usr/bin/env bash
set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)

[[ -z "$FILE_PATH" ]] && exit 0

# Find nearest tsconfig.json
DIR=$(dirname "$FILE_PATH")
TS_ROOT=""
while [[ "$DIR" != "/" ]]; do
  [[ -f "$DIR/tsconfig.json" ]] && TS_ROOT="$DIR" && break
  DIR=$(dirname "$DIR")
done
[[ -z "$TS_ROOT" ]] && exit 0

cd "$TS_ROOT"

# Run typecheck, show only errors (max 20 lines)
OUTPUT=$(npx tsc --noEmit --pretty 2>&1 | head -20)

if [[ $? -ne 0 ]] && [[ -n "$OUTPUT" ]]; then
  # Return as additionalContext so Claude sees the errors
  echo "$OUTPUT" >&2
  # Exit 0 — don't block, just inform Claude
  exit 0
fi

exit 0
