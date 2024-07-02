#!/usr/bin/env bash

if [[ -f ".puro.json" ]]; then
  PURO_ENV="$(jq -r .env ".puro.json")"
  echo "$HOME/.puro/envs/$PURO_ENV/flutter"
else
  FLUTTER_DIR="$(type flutter | cut -d' ' -f3-)"
  FLUTTER_DIR="$(dirname "$FLUTTER_DIR")"
  FLUTTER_DIR="$(dirname "$FLUTTER_DIR")"
fi
