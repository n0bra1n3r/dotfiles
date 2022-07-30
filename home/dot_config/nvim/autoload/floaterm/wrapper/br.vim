let s:broot_confpath = "$HOME/.config/broot/vim.toml"

function! floaterm#wrapper#br#(cmd, jobopts, config) abort
  let s:broot_tmpfile = join(split(tempname(), "\\"), "/")
  let cwd = join(split(getcwd(), "\\"), "/")

  let cmd = printf(
    \ 'broot --conf "%s" %s',
    \ s:broot_confpath,
    \ cwd
    \ )

  let cmd = ["bash", "-c", cmd.." > "..s:broot_tmpfile]
  let jobopts = { "on_exit": funcref("s:broot_callback") }
  call floaterm#util#deep_extend(a:jobopts, jobopts)
  return [v:false, cmd]
endfunction

function! s:broot_callback(job, data, event, opener) abort
  if filereadable(s:broot_tmpfile)
    let filenames = readfile(s:broot_tmpfile)
    if !empty(filenames)
      if has("nvim")
        call floaterm#window#hide(bufnr("%"))
      endif
      let locations = []
      for filename in filenames
        let dict = { "filename": fnamemodify(filename, ":p") }
        call add(locations, dict)
      endfor
      call floaterm#util#open(locations, "edit")
    endif
  endif
endfunction
