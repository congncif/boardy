#!/bin/bash -e

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT/.claude/CLAUDE.md"
TARGET="$ROOT/AGENTS.md"

if [ ! -f "$SOURCE" ]; then
    echo "Missing source file: .claude/CLAUDE.md"
    exit 1
fi

TMP_FILE="$(mktemp)"
cp "$SOURCE" "$TMP_FILE"

if [ -f "$TARGET" ] && cmp -s "$TMP_FILE" "$TARGET"; then
    rm "$TMP_FILE"
    echo "AGENTS.md is already in sync"
    exit 0
fi

mv "$TMP_FILE" "$TARGET"
echo "Synced AGENTS.md from .claude/CLAUDE.md"
