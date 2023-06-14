#!/usr/bin/env bash

set -e

shopt -u nullglob

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

if [[ "$OS" == *_NT* ]]; then
  for pkg in ~/.dotfiles/deps/*/.local/*.zst; do
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
    fi
  done
fi

chmod 600 ~/.ssh/keys/* && echo "> chmod 600 ~/.ssh/keys/*"

if [[ "$OS" == *_NT* ]]; then
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

# Install nim tree-sitter queries
NIM_QUERIES_PATH=~/.dotfiles/deps/tree-sitter-nim/_/queries

mkdir -p $NIM_QUERIES_PATH/nim
echo "> mkdir $NIM_QUERIES_PATH/nim"

cp $NIM_QUERIES_PATH/nvim/highlights.scm \
  $NIM_QUERIES_PATH/nim/highlights.scm && \
echo "> cp ../nvim/highlights.scm nim/highlights.scm"

cp $NIM_QUERIES_PATH/nvim/indents.scm \
  $NIM_QUERIES_PATH/nim/indents.scm && \
echo "> cp ../nvim/indents.scm nim/indents.scm"

cp $NIM_QUERIES_PATH/nvim/untested_locals.scm \
  $NIM_QUERIES_PATH/nim/locals.scm && \
echo "> cp ../nvim/locals.scm nim/locals.scm"
