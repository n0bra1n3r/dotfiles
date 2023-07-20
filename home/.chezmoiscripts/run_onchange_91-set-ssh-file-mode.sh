#!/usr/bin/env bash

# {{ (joinPath .chezmoi.homeDir "~/.ssh/keys" | lstat).mode }}

chmod -R 700 ~/.ssh/keys && echo "> chmod -R 700 ~/.ssh/keys"
