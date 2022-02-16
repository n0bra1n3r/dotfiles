#!/usr/bin/env bash

set -e

if [ ! "$(command -v git)" ]; then
  echo "ERROR: git must be installed and in your path" >&2
  exit 1
fi

git clone https://github.com/n0bra1n3r/dotfiles.git ~/.local/share/chezmoi

if [ ! "$(command -v chezmoi)" ]; then
  BIN_DIR="$HOME/.local/bin"
  chezmoi="$BIN_DIR/chezmoi"
  sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$BIN_DIR"
else
  chezmoi=chezmoi
fi

exec "$chezmoi" init --apply
