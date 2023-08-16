#!/usr/bin/env bash

if [[ -f "$PWD/pubspec.yaml" && ! -f "$PWD/.fvm/fvm_config.json" ]]; then
  fvm use "$(fvm list | tail -1)"
fi
