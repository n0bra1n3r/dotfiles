if has("win32")
  let $PATH = 'C:\PROGRA~1\Git\usr\bin;' . $PATH
  let $TMP = "/tmp"
  let &shell = "sh.exe"
  let &shellcmdflag = "-c"
  let &shellredir = ">%s 2>&1"
  let &shellpipe = "2>&1 | tee"
  set shellslash
  set shellquote=
  set shellxescape=
  set shellxquote=
endif

set runtimepath+=~/.config/nvim

""" Init settings

set modeline

""" Lua

lua require "main"

""" Autocommands

augroup conf_lsp
  autocmd!
  "autocmd TextChangedI,TextChangedP * lua fn.trigger_completion()
  "autocmd CursorMovedI * lua fn.end_completion()
augroup end