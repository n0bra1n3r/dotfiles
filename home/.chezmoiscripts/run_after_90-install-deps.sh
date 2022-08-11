#!/usr/bin/env bash

set -e

cp -rf ~/.dotfiles/deps/*/.local ~

chmod 600 ~/.ssh/keys/*
