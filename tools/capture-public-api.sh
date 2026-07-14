#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
    echo "Usage: DEVELOPER_DIR=/path/to/Xcode.app/Contents/Developer $0 <derived-data-root> <swiftinterface-output> <api-json-output>" >&2
}

if [ "$#" -ne 3 ]; then
    usage
    exit 64
fi

DERIVED_DATA_ROOT="$1"
SWIFTINTERFACE_OUTPUT="$2"
API_JSON_OUTPUT="$3"

if [ -z "${DEVELOPER_DIR:-}" ]; then
    echo "DEVELOPER_DIR must be set explicitly" >&2
    exit 64
fi

if [ ! -d "$DEVELOPER_DIR" ]; then
    echo "DEVELOPER_DIR does not exist: $DEVELOPER_DIR" >&2
    exit 66
fi

XCODE_VERSION_OUTPUT="$(DEVELOPER_DIR="$DEVELOPER_DIR" xcodebuild -version)"
XCODE_VERSION_LINE="$(printf '%s\n' "$XCODE_VERSION_OUTPUT" | sed -n '1p')"
if [ "$XCODE_VERSION_LINE" != "Xcode 26.4.1" ]; then
    echo "Expected Xcode 26.4.1, found: $XCODE_VERSION_LINE" >&2
    exit 65
fi

echo "Public API capture toolchain:" >&2
printf '%s\n' "$XCODE_VERSION_OUTPUT" >&2
echo "DEVELOPER_DIR=$DEVELOPER_DIR" >&2

HOST_ARCH="$(uname -m)"
case "$HOST_ARCH" in
    arm64)
        INTERFACE_SLICE="arm64-apple-ios-simulator.swiftinterface"
        DIGESTER_TARGET="arm64-apple-ios14.0-simulator"
        ;;
    x86_64)
        INTERFACE_SLICE="x86_64-apple-ios-simulator.swiftinterface"
        DIGESTER_TARGET="x86_64-apple-ios14.0-simulator"
        ;;
    *)
        echo "Unsupported host architecture: $HOST_ARCH" >&2
        exit 65
        ;;
esac

PRODUCTS_ROOT="$DERIVED_DATA_ROOT/Build/Products"
if [ ! -d "$PRODUCTS_ROOT" ]; then
    echo "Build products directory does not exist: $PRODUCTS_ROOT" >&2
    exit 66
fi

INTERFACE_CANDIDATES=()
while IFS= read -r candidate; do
    INTERFACE_CANDIDATES+=("$candidate")
done < <(
    find "$PRODUCTS_ROOT" \
        -type f \
        -path "*/Boardy.swiftmodule/$INTERFACE_SLICE" \
        ! -name '*.private.swiftinterface' \
        -print | LC_ALL=C sort
)

if [ "${#INTERFACE_CANDIDATES[@]}" -ne 1 ]; then
    echo "Expected exactly one public Boardy $INTERFACE_SLICE, found ${#INTERFACE_CANDIDATES[@]}:" >&2
    if [ "${#INTERFACE_CANDIDATES[@]}" -gt 0 ]; then
        printf '  %s\n' "${INTERFACE_CANDIDATES[@]}" >&2
    fi
    exit 65
fi

PUBLIC_INTERFACE="${INTERFACE_CANDIDATES[0]}"
case "$PUBLIC_INTERFACE" in
    *.private.swiftinterface)
        echo "Refusing to capture a private Swift interface: $PUBLIC_INTERFACE" >&2
        exit 65
        ;;
esac

FRAMEWORK_SEARCH_PATHS=()
while IFS= read -r framework_parent; do
    FRAMEWORK_SEARCH_PATHS+=("$framework_parent")
done < <(
    find "$PRODUCTS_ROOT" -type d -name '*.framework' -exec dirname '{}' \; | LC_ALL=C sort -u
)

if [ "${#FRAMEWORK_SEARCH_PATHS[@]}" -eq 0 ]; then
    echo "No built frameworks found under $PRODUCTS_ROOT" >&2
    exit 65
fi

BOARDY_FRAMEWORK_FOUND=0
for framework_parent in "${FRAMEWORK_SEARCH_PATHS[@]}"; do
    if [ -d "$framework_parent/Boardy.framework" ]; then
        BOARDY_FRAMEWORK_FOUND=1
        break
    fi
done

if [ "$BOARDY_FRAMEWORK_FOUND" -ne 1 ]; then
    echo "No Boardy.framework parent was derived under $PRODUCTS_ROOT" >&2
    exit 65
fi

SDK_PATH="$(DEVELOPER_DIR="$DEVELOPER_DIR" xcrun --sdk iphonesimulator --show-sdk-path)"
if [ ! -d "$SDK_PATH" ]; then
    echo "iPhone Simulator SDK does not exist: $SDK_PATH" >&2
    exit 66
fi

LOCAL_TEMP_ROOT="${BOARDY_LOCAL_TMPDIR:-$REPO_ROOT/.build-local/tmp}"
mkdir -p \
    "$(dirname "$SWIFTINTERFACE_OUTPUT")" \
    "$(dirname "$API_JSON_OUTPUT")" \
    "$LOCAL_TEMP_ROOT"
TEMP_ROOT="$(mktemp -d "$LOCAL_TEMP_ROOT/boardy-public-api.XXXXXX")"
trap 'rm -rf "$TEMP_ROOT"' EXIT

INTERFACE_TEMP="$TEMP_ROOT/Boardy.swiftinterface"
API_TEMP="$TEMP_ROOT/Boardy.api.json"
cp "$PUBLIC_INTERFACE" "$INTERFACE_TEMP"

FRAMEWORK_ARGUMENTS=()
for framework_parent in "${FRAMEWORK_SEARCH_PATHS[@]}"; do
    FRAMEWORK_ARGUMENTS+=("-F" "$framework_parent")
done

DEVELOPER_DIR="$DEVELOPER_DIR" xcrun swift-api-digester \
    -dump-sdk \
    -module Boardy \
    -swift-only \
    -avoid-location \
    -avoid-tool-args \
    -abort-on-module-fail \
    -swift-version 5 \
    -sdk "$SDK_PATH" \
    -target "$DIGESTER_TARGET" \
    "${FRAMEWORK_ARGUMENTS[@]}" \
    -o "$API_TEMP"

if [ ! -s "$INTERFACE_TEMP" ]; then
    echo "Captured Swift interface is missing or empty" >&2
    exit 65
fi

if [ ! -s "$API_TEMP" ]; then
    echo "Captured API JSON is missing or empty" >&2
    exit 65
fi

ruby -rjson -e 'JSON.parse(File.read(ARGV.fetch(0)))' "$API_TEMP"

mv "$INTERFACE_TEMP" "$SWIFTINTERFACE_OUTPUT"
mv "$API_TEMP" "$API_JSON_OUTPUT"

echo "Captured public interface: $PUBLIC_INTERFACE -> $SWIFTINTERFACE_OUTPUT" >&2
echo "Captured API graph: $API_JSON_OUTPUT" >&2
echo "Host architecture: $HOST_ARCH" >&2
echo "API digester target: $DIGESTER_TARGET" >&2
