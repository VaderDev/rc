#!/bin/bash

# ./update.sh && source ~/.bashrc

cd "$(dirname $0)"

cp -f .bashrc   ~/.bashrc
cp -f .minttyrc ~/.minttyrc
cp -f .screenrc ~/.screenrc
cp -f .vimrc    ~/.vimrc

