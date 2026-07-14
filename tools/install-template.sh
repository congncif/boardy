#!/bin/bash

set -euo pipefail

readonly REVISION="892828b9c003d1194fb044921000708345e00493"
readonly REPOSITORY_URL="https://github.com/congncif/module-template.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly REPO_ROOT
LOCAL_TMP_ROOT="${BOARDY_LOCAL_TMPDIR:-$REPO_ROOT/.build-local/tmp}"
readonly LOCAL_TMP_ROOT

mkdir -p "$LOCAL_TMP_ROOT"

WORK_DIR="$(mktemp -d "$LOCAL_TMP_ROOT/install-template.XXXXXX")"
readonly WORK_DIR
readonly CHECKOUT_DIR="$WORK_DIR/module-template"
trap 'rm -rf "$WORK_DIR"' EXIT

git clone --filter=blob:none "$REPOSITORY_URL" "$CHECKOUT_DIR"
git -C "$CHECKOUT_DIR" checkout --detach "$REVISION"

ACTUAL_REVISION="$(git -C "$CHECKOUT_DIR" rev-parse HEAD)"
readonly ACTUAL_REVISION
if [[ "$ACTUAL_REVISION" != "$REVISION" ]]; then
    echo "Revision mismatch: expected $REVISION, got $ACTUAL_REVISION" >&2
    exit 1
fi
echo "Verified module-template revision $ACTUAL_REVISION"

(
    cd "$CHECKOUT_DIR"
    sh ./install-template.sh
)
