#!/bin/bash -e

set -e

rm -rf temp
mkdir temp

cd temp

git clone https://github.com/congncif/module-template.git

cd module-template

sh install-template.sh

cd ..
cd ..

rm -rf temp