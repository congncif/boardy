#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
    echo "Usage: [DEVELOPER_DIR=/path/to/Xcode.app/Contents/Developer] $0 <derived-data-root> <swiftinterface-output> <api-json-output>" >&2
    echo "The library must be built first with BUILD_LIBRARY_FOR_DISTRIBUTION=YES; without library" >&2
    echo "evolution no .swiftinterface is emitted and this script has nothing to capture." >&2
    echo "Set BOARDY_ALLOW_XCODE_MISMATCH=1 to bypass the minimum Xcode check." >&2
    echo >&2
    echo "WARNING: the captured API graph is binary-module-derived and preserves typealias sugar." >&2
    echo "Do not compare it against an interface-derived graph — every sugared declaration is" >&2
    echo "reported as a phantom type change. Use tools/derive-api-graph.sh for both sides of a" >&2
    echo "comparison; the captured .swiftinterface remains the durable artifact." >&2
}

if [ "$#" -ne 3 ]; then
    usage
    exit 64
fi

DERIVED_DATA_ROOT="$1"
SWIFTINTERFACE_OUTPUT="$2"
API_JSON_OUTPUT="$3"

DEVELOPER_DIR="${DEVELOPER_DIR:-$(xcode-select -p)}"

if [ ! -d "$DEVELOPER_DIR" ]; then
    echo "DEVELOPER_DIR does not exist: $DEVELOPER_DIR" >&2
    exit 66
fi

if ! XCODE_VERSION_OUTPUT="$(DEVELOPER_DIR="$DEVELOPER_DIR" xcodebuild -version 2>&1)"; then
    echo "Unable to read the configured Xcode version: $XCODE_VERSION_OUTPUT" >&2
    exit 65
fi
XCODE_VERSION_LINE="$(printf '%s\n' "$XCODE_VERSION_OUTPUT" | sed -n '1p')"
MIN_XCODE_VERSION="${BOARDY_MIN_XCODE_VERSION:-Xcode 26.4.1}"
if [ "${BOARDY_ALLOW_XCODE_MISMATCH:-0}" != "1" ]; then
    if ! printf '%s\n' "$XCODE_VERSION_LINE" "$MIN_XCODE_VERSION" | sort -V | tail -n1 | grep -qx "$XCODE_VERSION_LINE"; then
        echo "Need at least $MIN_XCODE_VERSION, found: $XCODE_VERSION_LINE. Set BOARDY_ALLOW_XCODE_MISMATCH=1 to override." >&2
        exit 65
    fi
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

# Read as UTF-8 explicitly: the graph contains non-ASCII declaration text, and Ruby would
# otherwise decode it with the locale's external encoding and fail under a non-UTF-8 LANG.
ruby -rjson -e 'JSON.parse(File.read(ARGV.fetch(0), encoding: "UTF-8"))' "$API_TEMP"

mv "$INTERFACE_TEMP" "$SWIFTINTERFACE_OUTPUT"
mv "$API_TEMP" "$API_JSON_OUTPUT"

echo "Captured public interface: $PUBLIC_INTERFACE -> $SWIFTINTERFACE_OUTPUT" >&2
echo "Captured API graph: $API_JSON_OUTPUT" >&2
echo "Host architecture: $HOST_ARCH" >&2
echo "API digester target: $DIGESTER_TARGET" >&2
