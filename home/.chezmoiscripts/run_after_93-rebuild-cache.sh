#!/usr/bin/env bash

source ~/.dotfiles/envrc

echo "> rebuilding caches..."

bat cache --source="$HOME/.dotfiles/deps/bat/.config/bat" --build
