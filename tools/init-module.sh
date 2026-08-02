#!/bin/bash

set -euo pipefail

readonly REVISION="62e618beba9900a26970deb722f12163c77c319f"
readonly REPOSITORY_URL="https://github.com/ifsolution/module-structure-template.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly REPO_ROOT
LOCAL_TMP_ROOT="${BOARDY_LOCAL_TMPDIR:-$REPO_ROOT/.build-local/tmp}"
readonly LOCAL_TMP_ROOT

NAME="${1:-}"
PREFIX="${2:-DAD}"

if [[ -z "$NAME" ]]; then
    echo "Missing module name"
    exit 1
fi

if [[ ! "$NAME" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    echo "Invalid module name: use a Swift identifier (letters, digits, and underscores)" >&2
    exit 1
fi

if [[ ! "$PREFIX" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    echo "Invalid module prefix: use a Swift identifier (letters, digits, and underscores)" >&2
    exit 1
fi

NO_PREFIX_NAME="$(sed "s/$PREFIX//g" <<<"$NAME")"
readonly NO_PREFIX_NAME
if [[ -z "$NO_PREFIX_NAME" ]]; then
    echo "Module name must contain characters beyond its prefix" >&2
    exit 1
fi

echo "● Module name set to $NAME"
echo "● Module prefix set to $PREFIX"

mkdir -p "$LOCAL_TMP_ROOT"

WORK_DIR="$(mktemp -d "$LOCAL_TMP_ROOT/init-module.XXXXXX")"
readonly WORK_DIR
readonly CHECKOUT_DIR="$WORK_DIR/module-structure-template"
trap 'rm -rf "$WORK_DIR"' EXIT

git clone --filter=blob:none "$REPOSITORY_URL" "$CHECKOUT_DIR"
git -C "$CHECKOUT_DIR" checkout --detach "$REVISION"

ACTUAL_REVISION="$(git -C "$CHECKOUT_DIR" rev-parse HEAD)"
readonly ACTUAL_REVISION
if [[ "$ACTUAL_REVISION" != "$REVISION" ]]; then
    echo "Revision mismatch: expected $REVISION, got $ACTUAL_REVISION" >&2
    exit 1
fi
echo "Verified module-structure-template revision $ACTUAL_REVISION"

rm -rf "$CHECKOUT_DIR/.git"
cp -R "$CHECKOUT_DIR"/. .

echo "👉 Renmame module name"

sed -i '' "s/__DAD__/${NAME}/g" "__DAD__Plugins.podspec"
sed -i '' "s/__DAD__/${NAME}/g" "__DAD__.podspec"

mv __DAD__.podspec "${NAME}.podspec"
mv __DAD__Plugins.podspec "${NAME}Plugins.podspec"

mv "Sources/Resources/en.lproj/__DAD__.strings" "Sources/Resources/en.lproj/${NAME}.strings"
mv "Sources/Resources/vi.lproj/__DAD__.strings" "Sources/Resources/vi.lproj/${NAME}.strings"
mv "Sources/Resources/__DAD__.xcassets" "Sources/Resources/${NAME}.xcassets"

sed -i '' "s/__DAD__/${NAME}/g" "Sources/Components/CombineFlows/___VARIABLE_moduleName___Board.swift"
# sed -i '' "s/__DAD__/${NAME}/g" "Sources/Components/CombineFlows/___VARIABLE_moduleName___InOut.swift"
sed -i '' "s/__DAD__/${NAME}/g" "Sources/Integration/___VARIABLE_moduleName___ModulePlugin.swift"

echo "👉 Renmame no-prefix name"

sed -i '' "s/___VARIABLE_moduleName___/${NO_PREFIX_NAME}/g" "IO/Interface/___VARIABLE_moduleName___IOInterface.swift"
sed -i '' "s/___VARIABLE_moduleName___/${NO_PREFIX_NAME}/g" "IO/Interface/___VARIABLE_moduleName___InOut.swift"

sed -i '' "s/___VARIABLE_moduleName___/${NO_PREFIX_NAME}/g" "IO/Shared/___VARIABLE_moduleName___ServiceMap.swift"
sed -i '' "s/__DAD__/${NAME}/g" "IO/Shared/___VARIABLE_moduleName___ServiceMap.swift"
sed -i '' "s/___VARIABLE_serviceMap___/mod${NAME}/g" "IO/Shared/___VARIABLE_moduleName___ServiceMap.swift"

VAR_MOD_NAME="$(tr '[:upper:]' '[:lower:]' <<<"${NO_PREFIX_NAME:0:1}")${NO_PREFIX_NAME:1}"
# sed -i '' "s/___VARIABLE_serviceMap___/${VAR_MOD_NAME}/g" "IO/Shared/___VARIABLE_moduleName___ServiceMap.swift"

mv "IO/Interface/___VARIABLE_moduleName___IOInterface.swift" "IO/Interface/${NO_PREFIX_NAME}IOInterface.swift"
mv "IO/Interface/___VARIABLE_moduleName___InOut.swift" "IO/Interface/${NO_PREFIX_NAME}InOut.swift"
mv "IO/Shared/___VARIABLE_moduleName___ServiceMap.swift" "IO/Shared/${NO_PREFIX_NAME}ServiceMap.swift"

echo "👉 Renmame Module Integration"

sed -i '' "s/___VARIABLE_moduleName___/${NO_PREFIX_NAME}/g" "Sources/Integration/___VARIABLE_moduleName___ModulePlugin.swift"
sed -i '' "s/___VARIABLE_moduleName___/${NO_PREFIX_NAME}/g" "Sources/Components/CombineFlows/___VARIABLE_moduleName___Board.swift"
# sed -i '' "s/___VARIABLE_moduleName___/${NO_PREFIX_NAME}/g" "Sources/Components/CombineFlows/RootInOut.swift"

mv "Sources/Integration/___VARIABLE_moduleName___ModulePlugin.swift" "Sources/Integration/${NO_PREFIX_NAME}ModulePlugin.swift"
mv "Sources/Components/CombineFlows/___VARIABLE_moduleName___Board.swift" "Sources/Components/CombineFlows/${NO_PREFIX_NAME}Board.swift"

echo "✅ Initialized $NAME module successfully!"
