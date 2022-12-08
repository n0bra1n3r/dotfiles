if has("win32")
  set runtimepath+=~/.config/nvim

  let &packpath = &runtimepath
endif

""" Lua

lua require "main"

""" Autocommands

augroup conf_editor
  autocmd!
  autocmd BufEnter * lua fn.set_shell_title()
  autocmd BufEnter * highlight ColorColumn guifg=darkgray ctermfg=darkgray guibg=NONE ctermbg=NONE
  autocmd BufEnter * lua vim.diagnostic.show()
  autocmd BufEnter,CursorHold,CursorHoldI,FocusGained * if mode() == "n" && getcmdwintype() == "" | checktime | endif
  autocmd BufWritePost,TermLeave * lua fn.refresh_git_change_info()
  autocmd BufWritePost ~/.local/share/chezmoi/home/* lua fn.save_dot_files()
  autocmd BufWritePost,VimEnter * lua fn.project_check()
  autocmd CmdwinEnter * nnoremap <buffer> <Esc> $l<C-c>
  autocmd DirChanged,VimEnter * lua fn.refresh_git_info()
  autocmd TextChanged,TextChangedI * let b:changedtime = localtime()
  autocmd TextYankPost * lua vim.highlight.on_yank()
  autocmd WinLeave * lua fn.cleanup_window_if_needed()
augroup end

augroup conf_help
  autocmd!
  autocmd FileType help wincmd K
  autocmd FileType help nnoremap <buffer><silent> <Esc> <cmd>close<CR>
augroup end

augroup conf_quickfix
  autocmd!
  autocmd FileType qf setlocal colorcolumn=
  autocmd FileType qf nnoremap <buffer><silent> <Esc> <cmd>close<CR>
  autocmd VimLeavePre * cclose
augroup end

augroup conf_git
  autocmd!
  autocmd FileType gitcommit set textwidth=72
  autocmd FileType gitcommit set colorcolumn=51,73
augroup end

augroup conf_lsp
  autocmd!
  autocmd TextChangedI,TextChangedP * lua fn.trigger_completion()
  autocmd CursorMovedI * lua fn.end_completion()
augroup end

if &t_ts == ""
  let &t_ts = "\e]2;"
  set title
endif
