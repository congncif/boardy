#!/bin/bash

# Derives a Swift API Digester graph from a `.swiftinterface`.
#
# Use this for BOTH sides of a comparison. The two ways of producing a graph are not
# interchangeable, and mixing them is the trap this script exists to close:
#
#   * interface-derived (this script): the digester type-checks the textual interface, which
#     EXPANDS typealiases — `FlowMotherboard` prints as `FlowManageable & MotherboardType`.
#   * binary-module-derived (`capture-public-api.sh`): the digester reads the compiled
#     `.swiftmodule`, which PRESERVES the sugar — the same declaration prints as `FlowMotherboard`.
#
# Comparing one against the other reports every sugared declaration as a phantom "type change"
# (40+ findings on Boardy, none of them real). `.swiftinterface` is the committed, human-diffable
# baseline, so the interface-derived form is the one both sides use.
#
# Why the framework scaffold below is required: a Boardy `.swiftinterface` opens with
# `@_exported import Boardy`, so the interface only loads when an underlying Boardy module is
# resolvable. Loading it standalone through `-I` fails with "underlying Objective-C module 'Boardy'
# not found". The scaffold therefore copies a freshly built `Boardy.framework`, deletes every
# shipped module slice and swaps in the given interface — so the digester reads the API surface from
# that interface and not from the binary.
#
# The output is NOT byte-reproducible across toolchains. Its contract is semantic: verifying against
# it must produce the same findings as the interface it was derived from. `tools/verify-public-api.sh`
# is what enforces that.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
    echo "Usage: [DEVELOPER_DIR=/path/to/Xcode.app/Contents/Developer] $0 <swiftinterface> <derived-data-root> <api-json-output>" >&2
    echo "The library must be built first with BUILD_LIBRARY_FOR_DISTRIBUTION=YES so the scaffold and" >&2
    echo "dependency frameworks exist under <derived-data-root>/Build/Products." >&2
    echo "Use this for both the baseline and the candidate; do not compare against a graph from" >&2
    echo "capture-public-api.sh, which is binary-module-derived and spells typealiases differently." >&2
}

if [ "$#" -ne 3 ]; then
    usage
    exit 64
fi

SOURCE_INTERFACE="$1"
DERIVED_DATA_ROOT="$2"
API_JSON_OUTPUT="$3"

if [ ! -s "$SOURCE_INTERFACE" ]; then
    echo "Source interface is missing or empty: $SOURCE_INTERFACE" >&2
    exit 66
fi

DEVELOPER_DIR="${DEVELOPER_DIR:-$(xcode-select -p)}"
if [ ! -d "$DEVELOPER_DIR" ]; then
    echo "DEVELOPER_DIR does not exist: $DEVELOPER_DIR" >&2
    exit 66
fi

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

BUILT_FRAMEWORK="$(find "$PRODUCTS_ROOT" -type d -name 'Boardy.framework' -print | LC_ALL=C sort | sed -n '1p')"
if [ -z "$BUILT_FRAMEWORK" ]; then
    echo "No Boardy.framework found under $PRODUCTS_ROOT; build with BUILD_LIBRARY_FOR_DISTRIBUTION=YES first" >&2
    exit 65
fi

FRAMEWORK_SEARCH_PATHS=()
while IFS= read -r framework_parent; do
    FRAMEWORK_SEARCH_PATHS+=("$framework_parent")
done < <(
    find "$PRODUCTS_ROOT" -type d -name '*.framework' ! -name 'Boardy.framework' -exec dirname '{}' \; | LC_ALL=C sort -u
)

SDK_PATH="$(DEVELOPER_DIR="$DEVELOPER_DIR" xcrun --sdk iphonesimulator --show-sdk-path)"
if [ ! -d "$SDK_PATH" ]; then
    echo "iPhone Simulator SDK does not exist: $SDK_PATH" >&2
    exit 66
fi

LOCAL_TEMP_ROOT="${BOARDY_LOCAL_TMPDIR:-$REPO_ROOT/.build-local/tmp}"
mkdir -p "$(dirname "$API_JSON_OUTPUT")" "$LOCAL_TEMP_ROOT"
TEMP_ROOT="$(mktemp -d "$LOCAL_TEMP_ROOT/boardy-derived-api.XXXXXX")"
trap 'rm -rf "$TEMP_ROOT"' EXIT

SCAFFOLD="$TEMP_ROOT/scaffold"
mkdir -p "$SCAFFOLD"
cp -R "$BUILT_FRAMEWORK" "$SCAFFOLD/"

SCAFFOLD_MODULES="$SCAFFOLD/Boardy.framework/Modules/Boardy.swiftmodule"
if [ ! -d "$SCAFFOLD_MODULES" ]; then
    echo "Built framework has no Boardy.swiftmodule; it was not built with BUILD_LIBRARY_FOR_DISTRIBUTION=YES" >&2
    exit 65
fi

# Drop every shipped slice so the digester cannot silently read the built API instead of the
# interface passed in.
find "$SCAFFOLD_MODULES" -type f \( -name '*.swiftinterface' -o -name '*.swiftmodule' \) -delete
cp "$SOURCE_INTERFACE" "$SCAFFOLD_MODULES/$INTERFACE_SLICE"

API_TEMP="$TEMP_ROOT/Boardy.derived.api.json"

FRAMEWORK_ARGUMENTS=("-F" "$SCAFFOLD")
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

if [ ! -s "$API_TEMP" ]; then
    echo "Derived graph is missing or empty" >&2
    exit 65
fi

# `swift-api-digester` can report success while emitting an empty or truncated graph when the module
# fails to load, so assert a floor on the node count here as well as in verify-public-api.sh.
MIN_TOP_LEVEL_NODES="${BOARDY_MIN_TOP_LEVEL_NODES:-100}"
NODE_COUNT="$(ruby -rjson -e 'puts JSON.parse(File.read(ARGV.fetch(0), encoding: "UTF-8")).dig("ABIRoot", "children")&.size.to_i' "$API_TEMP")"
if [ "$NODE_COUNT" -lt "$MIN_TOP_LEVEL_NODES" ]; then
    echo "Derived graph has only $NODE_COUNT top-level nodes; expected >= $MIN_TOP_LEVEL_NODES." >&2
    echo "The interface most likely failed to load." >&2
    exit 65
fi

mv "$API_TEMP" "$API_JSON_OUTPUT"

echo "Derived API graph from: $SOURCE_INTERFACE" >&2
echo "Scaffold framework: $BUILT_FRAMEWORK" >&2
echo "Output: $API_JSON_OUTPUT ($NODE_COUNT top-level nodes)" >&2
echo "API digester target: $DIGESTER_TARGET" >&2
