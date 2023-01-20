let current_compiler = "nim"

CompilerSet errorformat=%A%f(%l\\,\ %c)\ %m
CompilerSet errorformat+=%A%f(%l):\ note:\ %m
CompilerSet errorformat+=%E%f(%l\\,\ %c)\ Error:\ %m
CompilerSet errorformat+=%E%f(%l):\ error\ C%n:\ %m
CompilerSet errorformat+=%N%f(%l\\,\ %c)\ Hint:\ %m
CompilerSet errorformat+=%W%f(%l\\,\ %c)\ Warning:\ %m
CompilerSet errorformat+=%W%f(%l):\ warning\ C%n:\ %m
CompilerSet errorformat+=%-I@m%m
CompilerSet errorformat+=%-ICC:\ %m
CompilerSet errorformat+=%-IHint:\ %m
CompilerSet errorformat+=%-IError:\ %m

CompilerSet makeprg=nim\ c\ --verbosity:0\ $*\ %:p
