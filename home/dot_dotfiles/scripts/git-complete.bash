#!/usr/bin/bash

set -e

source /mingw64/share/git/completion/git-completion.bash

function git-complete {
  local -a COMPREPLY COMP_WORDS
  local COMP_CWORD
  COMP_WORDS=("git" "" $@)
  ((COMP_CWORD = ${#COMP_WORDS[@]} - 1))
  __git_wrap__git_main
  local IFS=$'\n'
  echo "${COMPREPLY[*]}"
}

git-complete "$@"
