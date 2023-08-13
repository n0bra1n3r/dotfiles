#!/usr/bin/env bash

set -e

NIM_QUERIES_PATH=~/.dotfiles/deps/tree-sitter-nim/.dotfiles/queries

DEP_NAME="tree-sitter-nim"

REL_PATH="$HOME/.dotfiles/logs/$DEP_NAME.txt"
SHA_PATH="$HOME/.dotfiles/logs/$DEP_NAME.sha256"

if [[ -f "$REL_PATH" ]]; then
  CUR_SHA=$(sha256sum < "$REL_PATH")
fi

if [[ -f "$SHA_PATH" ]]; then
  OLD_SHA=$(cat "$SHA_PATH")
fi

if [[ -z "$CUR_SHA" || "$CUR_SHA" != "$OLD_SHA" ]]; then
  mkdir -p "$NIM_QUERIES_PATH/nim"

  cp "$NIM_QUERIES_PATH/nvim/highlights.scm" \
    "$NIM_QUERIES_PATH/nim/highlights.scm" && \
  echo "> installed nim/highlights.scm"

  cp $NIM_QUERIES_PATH/nvim/indents.scm \
    $NIM_QUERIES_PATH/nim/indents.scm && \
  echo "> installed nim/indents.scm"

  cp $NIM_QUERIES_PATH/nvim/untested_locals.scm \
    $NIM_QUERIES_PATH/nim/locals.scm && \
  echo "> installed nim/locals.scm"

  printf '%s' "$CUR_SHA" > "$SHA_PATH"
fi
