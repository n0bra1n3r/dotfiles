#!/usr/bin/env bash

set -e

DEP_NAME="tree-sitter-nim"

NIM_QUERIES_PATH="$HOME/.dotfiles/deps/$DEP_NAME/contents/queries"

REL_PATH="$HOME/.dotfiles/deps/$DEP_NAME/release.json"
SHA_PATH="$HOME/.dotfiles/deps/$DEP_NAME/release.sha256"

if [[ -f "$REL_PATH" ]]; then
  CUR_SHA=$(sha256sum < "$REL_PATH")
fi

if [[ -f "$SHA_PATH" ]]; then
  OLD_SHA=$(cat "$SHA_PATH")
fi

if [[ -z "$CUR_SHA" || "$CUR_SHA" != "$OLD_SHA" ]]; then
  mkdir -p "$NIM_QUERIES_PATH/nim"

  cp "$NIM_QUERIES_PATH/highlights.scm" \
    "$NIM_QUERIES_PATH/nim/highlights.scm" && \
  echo "> installed nim/highlights.scm"

  if [[ -f "$NIM_QUERIES_PATH/indents.scm" ]]; then
    cp "$NIM_QUERIES_PATH/indents.scm" \
      "$NIM_QUERIES_PATH/nim/indents.scm" && \
    echo "> installed nim/indents.scm"
  fi

  if [[ -f "$NIM_QUERIES_PATH/locals.scm" ]]; then
    cp "$NIM_QUERIES_PATH/locals.scm" \
      "$NIM_QUERIES_PATH/nim/locals.scm" && \
    echo "> installed nim/locals.scm"
  fi

  printf '%s' "$CUR_SHA" > "$SHA_PATH"
fi
