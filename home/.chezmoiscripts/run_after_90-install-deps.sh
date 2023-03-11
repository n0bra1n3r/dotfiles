#!/usr/bin/env bash

set -e

shopt -u nullglob

for zip in ~/.dotfiles/deps/*/*.zip; do
  cd "$(dirname "$zip")" && unzip -oqq "$zip" && rm "$zip" && echo "> unzip $zip"
done

for dir in ~/.dotfiles/deps/*/.local; do
  cp -rf "$dir" ~ && echo "> cp -r $dir ~"
done

chmod 600 ~/.ssh/keys/* && echo "> chmod 600 ~/.ssh/keys/*"
