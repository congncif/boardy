#!/bin/bash -e

set -e

NAME=$1
PREFIX=$2

if [ -z $NAME ]; then
    echo "Missing module name"
    exit 1
fi

if [ -z $PREFIX ]; then
    PREFIX="DAD"
fi

echo "● Module name set to $NAME"
echo "● Module prefix set to $PREFIX"

git clone https://github.com/ifsolution/module-structure-template.git

rm -rf module-structure-template/.git
cp -r module-structure-template/ .
rm -rf module-structure-template

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

NO_PREFIX_NAME=$(sed "s/$PREFIX//g" <<<"$NAME")

sed -i '' "s/___VARIABLE_moduleName___/${NO_PREFIX_NAME}/g" "IO/Interface/___VARIABLE_moduleName___IOInterface.swift"
sed -i '' "s/___VARIABLE_moduleName___/${NO_PREFIX_NAME}/g" "IO/Interface/___VARIABLE_moduleName___InOut.swift"

sed -i '' "s/___VARIABLE_moduleName___/${NO_PREFIX_NAME}/g" "IO/Shared/___VARIABLE_moduleName___ServiceMap.swift"
sed -i '' "s/__DAD__/${NAME}/g" "IO/Shared/___VARIABLE_moduleName___ServiceMap.swift"
sed -i '' "s/___VARIABLE_serviceMap___/mod${NAME}/g" "IO/Shared/___VARIABLE_moduleName___ServiceMap.swift"

VAR_MOD_NAME="$(tr '[:upper:]' '[:lower:]' <<<${NO_PREFIX_NAME:0:1})${NO_PREFIX_NAME:1}"
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
