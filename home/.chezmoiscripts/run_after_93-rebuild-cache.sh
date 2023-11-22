#!/usr/bin/env bash

source ~/.dotfiles/envrc

echo "> rebuilding caches..."

bat cache --build
