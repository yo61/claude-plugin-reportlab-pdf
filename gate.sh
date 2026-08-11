#!/usr/bin/env bash
# Narrow gate for the ruff 0.15.14 -> 0.16.1 bump: verifies the pre-commit
# ruff-format hook is now a no-op (previously it left SKILL.md modified,
# which pre-commit/prek reports as a hook failure).
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

uv sync --group dev --frozen

# Snapshot tree, run the exact hook command, and fail if it changes anything.
before="$(git status --porcelain)"
uv run --no-sync ruff format
uv run --no-sync ruff check
after="$(git status --porcelain)"

if [ "$before" != "$after" ]; then
  echo "ruff format modified files after the fix — hook would still fail:" >&2
  git status --porcelain >&2
  exit 1
fi

echo "gate passed: ruff format/check are no-ops on the current tree"
