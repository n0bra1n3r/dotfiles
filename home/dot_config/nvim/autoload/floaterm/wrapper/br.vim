let s:broot_confpath = "$HOME/.config/broot/vim.toml"

function! floaterm#wrapper#br#(cmd, jobopts, config) abort
  let cwd = join(split(getcwd(), "\\"), "/")

  let cmd = printf(
    \ 'broot --conf "%s" "%s"',
    \ s:broot_confpath,
    \ cwd
    \ )

  let cmd = ["bash", "-c", cmd]
  return [v:false, cmd]
endfunction
