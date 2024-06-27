#!/usr/bin/env bash

if [[ -f ".puro.json" ]]; then
  PURO_ENV="$(jq -r .env ".puro.json")"
  echo "$HOME/.puro/envs/$PURO_ENV/flutter"
else
  type flutter | cut -d' ' -f3-
fi
