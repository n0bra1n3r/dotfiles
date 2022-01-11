if exists("is_nim_compiler_set")
  finish
endif

let is_nim_compiler_set = 1
let current_compiler = "nim"

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=nim\ c\ --verbosity:0\ $*\ %:p

CompilerSet errorformat=
CompilerSet errorformat+=\%E%f(%l\\,\ %c)\ Error:\ %m
CompilerSet errorformat+=\%N%f(%l\\,\ %c)\ Hint:\ %m
CompilerSet errorformat+=\%W%f(%l\\,\ %c)\ Warning:\ %m

let &cpo = s:cpo_save

unlet s:cpo_save
