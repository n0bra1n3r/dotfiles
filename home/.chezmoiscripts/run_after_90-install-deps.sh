#!/usr/bin/env bash

set -e

shopt -u nullglob

for zip in ~/.dotfiles/deps/*/*.zip; do
  dir="$(dirname "$zip")"
  if [[ -d "$dir" ]]; then
    cd "$dir" && unzip -oqq "$zip" && rm "$zip" && echo "> unzip $zip"
  fi
done

for dir in ~/.dotfiles/deps/*/.[^.]*; do
  cp -rf "$dir" ~ && echo "> cp $dir ~"
done

chmod 600 ~/.ssh/keys/* && echo "> chmod 600 ~/.ssh/keys/*"

os="$(uname -s)"
if [[ "$os" == "MSYS_NT"* ]] || [[ "$os" == "MINGW64_NT"* ]]; then
  font_dir="$HOME/.local/share/fonts"
  if [[ -d "$font_dir" ]]; then
    for font_file in "$font_dir"/*.?tf; do
      font_path="$(cygpath -m "$font_file")"
      powershell -ExecutionPolicy Bypass -command "~/.dotfiles/scripts/register-fonts.ps1 '$font_path'" && echo "> register-fonts $font_file"
    done
  fi
fi
