---
name: validate
description: Run full local validation (format, typecheck, lint, tests) before committing. Auto-detects project toolchain.
allowed-tools: Bash Read Glob
---

Run a full quality gate for the current project. Auto-detect the toolchain and run all applicable checks.

## Detection

1. Find the nearest `package.json` from the current working directory
2. Detect package manager: `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, else npm
3. Detect available tooling from `package.json` scripts and config files

## Checks (run in order, skip if not applicable)

### 1. Format check
- If `biome.json` exists: `npx @biomejs/biome check .`
- Elif prettier is configured: `$PM run format --check` or `npx prettier --check .`
- Elif `deno.json` exists: `deno fmt --check`

### 2. TypeScript typecheck
- If `tsconfig.json` exists: `npx tsc --noEmit`
- Check ALL tsconfig files if monorepo (look for `tsconfig.json` in subdirs with `package.json`)

### 3. Lint
- If eslint is configured: `$PM run lint` or `npx eslint .`
- If biome: `npx @biomejs/biome lint .`

### 4. Tests
- If vitest: `$PM run test` or `npx vitest run`
- If jest: `$PM test`
- If pytest: `python -m pytest`
- If go: `go test ./...`

## Output

Report each check as:
```
Format:    PASS | FAIL (N issues)
Typecheck: PASS | FAIL (N errors) | SKIP (no tsconfig)
Lint:      PASS | FAIL (N warnings, M errors) | SKIP
Tests:     PASS (N passed) | FAIL (N failed / M total) | SKIP
```

If all checks pass, say: "Ready to commit."
If any fail, list the specific errors and suggest fixes.
