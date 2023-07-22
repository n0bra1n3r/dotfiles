if has("win32")
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

""" Init settings

set modeline

""" Lua

lua require "main"
