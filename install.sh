#!/usr/bin/env bash

set -e

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
else
  chezmoi=chezmoi
fi

script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

exec "$chezmoi" init --apply "--source=$script_dir"
