#!/usr/bin/env bash

set -e

shopt -u nullglob

os="$(uname -s)"

for zip in ~/.dotfiles/deps/*/*.zip; do
  dir="$(dirname "$zip")"
  if [[ -d "$dir" ]]; then
    pushd "$dir" >/dev/null && \
      unzip -oqq "$zip" && \
      rm "$zip" && \
      echo "> unzip $zip"
    popd >/dev/null
  fi
done

if [[ "$os" == "MSYS_NT"* ]] || [[ "$os" == "MINGW64_NT"* ]]; then
  for pkg in ~/.dotfiles/deps/*/*.zst; do
    dir="$(dirname "$pkg")"
    if [[ -d "$dir" ]]; then
      pushd "$dir" >/dev/null && \
        rm -rf !"$pkg" && \
        zstd --decompress "$pkg" &>/dev/null && \
        tar -xvf ./*.pkg.tar >/dev/null && \
        rm ./*.pkg.* && \
        rm ./.* && \
        echo "> zstd $pkg"
      popd >/dev/null
      powershell \
        -command "Start-Process \
          'bash' '-c \"PATH=\\\"$PATH\\\" cp -rf \\\"$dir\\\"/* /\"' \
          -Verb runAs" && \
        echo "> cp $dir/* /"
    fi
  done
fi

for dir in ~/.dotfiles/deps/*/.[^.]*; do
  cp -rf "$dir" ~ && echo "> cp $dir ~"
done

chmod 600 ~/.ssh/keys/* && echo "> chmod 600 ~/.ssh/keys/*"

if [[ "$os" == "MSYS_NT"* ]] || [[ "$os" == "MINGW64_NT"* ]]; then
  font_dir="$HOME/.local/share/fonts"
  if [[ -d "$font_dir" ]]; then
    echo "> register-fonts $font_dir/*"
    for font_file in "$font_dir"/*.?tf; do
      font_path="$(cygpath -m "$font_file")"
      powershell -ExecutionPolicy Bypass \
        -command "~/.dotfiles/scripts/register-fonts.ps1 '$font_path'"
    done
  fi
fi
