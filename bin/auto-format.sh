#!/usr/bin/env bash
set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)

# Skip if no file path or not a formattable file
[[ -z "$FILE_PATH" ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && exit 0

case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.scss|*.html|*.md|*.yaml|*.yml) ;;
  *) exit 0 ;;
esac

# Find project root (nearest package.json or git root)
DIR=$(dirname "$FILE_PATH")
PROJECT_ROOT=""
while [[ "$DIR" != "/" ]]; do
  [[ -f "$DIR/package.json" ]] && PROJECT_ROOT="$DIR" && break
  [[ -d "$DIR/.git" ]] && PROJECT_ROOT="$DIR" && break
  DIR=$(dirname "$DIR")
done
[[ -z "$PROJECT_ROOT" ]] && exit 0

cd "$PROJECT_ROOT"

# Auto-detect formatter and run on the changed file
REL_PATH="${FILE_PATH#$PROJECT_ROOT/}"

if [[ -f "biome.json" ]] || [[ -f "biome.jsonc" ]]; then
  npx @biomejs/biome format --write "$REL_PATH" 2>&1 | tail -3
elif [[ -f ".prettierrc" ]] || [[ -f ".prettierrc.json" ]] || [[ -f ".prettierrc.js" ]] || [[ -f ".prettierrc.cjs" ]] || [[ -f "prettier.config.js" ]] || [[ -f "prettier.config.cjs" ]] || grep -q '"prettier"' package.json 2>/dev/null; then
  npx prettier --write "$REL_PATH" 2>&1 | tail -3
elif [[ -f "deno.json" ]] || [[ -f "deno.jsonc" ]]; then
  deno fmt "$REL_PATH" 2>&1 | tail -3
fi

exit 0
