#!/bin/bash -e

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ ! -d ".git" ]; then
    echo "This script must be run inside a git repository"
    exit 1
fi

if [ ! -d ".githooks" ]; then
    echo "Missing .githooks directory"
    exit 1
fi

chmod +x .githooks/*
git config core.hooksPath .githooks

echo "Installed git hooks from .githooks"
echo "core.hooksPath=$(git config --get core.hooksPath)"
