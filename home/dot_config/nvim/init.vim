set runtimepath+=~/.config/nvim,~/.config/nvim/lua

let &packpath = &runtimepath

lua require "main"

colorscheme tokyonight
 
""" Commands

command -nargs=+ NimEval !nim --skipProjCfg:on --hint[Conf]:off --eval:<q-args>

""" Autocommands

augroup conf_console
  autocmd!
  autocmd BufEnter * let &titlestring = 'nvim - ' . expand("%:t")
augroup end

augroup auto_read
  autocmd!
  autocmd BufEnter * checktime
augroup end
 
augroup auto_close
  autocmd!
  autocmd TextChanged,TextChangedI * let b:changedtime = localtime()
augroup end

augroup conf_modes
  autocmd!
  autocmd InsertEnter * set nocursorcolumn
  autocmd InsertLeave * set cursorcolumn
augroup end

augroup highlight_on_yank
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank()
augroup end

augroup conf_quickfix
  autocmd!
  autocmd FileType qf if (getwininfo(win_getid())[0].loclist != 1)
    \| wincmd J
    \| endif
  autocmd FileType qf setlocal colorcolumn=
  autocmd FileType qf nnoremap <buffer><silent> <Esc> <cmd>quit<CR>
  autocmd VimLeavePre * cclose
augroup end

augroup conf_help
  autocmd!
  autocmd FileType help wincmd K
  autocmd FileType help nnoremap <buffer><silent> <Esc> <cmd>bdelete<CR>
augroup end

augroup conf_terminal
  autocmd!
  autocmd TermEnter * nnoremap <buffer><silent> <Esc> <cmd>hide<CR>
augroup end

augroup conf_git
  autocmd!
  autocmd FileType gitcommit set textwidth=72
  autocmd FileType gitcommit set colorcolumn=51,73
augroup end

augroup conf_packer
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end

augroup conf_lsp
  autocmd!
  autocmd TextChangedI,TextChangedP * lua fn.trigger_completion()
  autocmd CursorMovedI * lua fn.end_completion()
augroup end

augroup conf_asyncrun
  autocmd!
  autocmd BufWritePost * if &ft == "nim"
    \| exec "lua fn.run_nim_check()"
    \| endif
  autocmd User AsyncRunPre cclose | let g:is_job_in_progress=1
  autocmd User AsyncRunStop exec "lua fn.show_quickfix()" | let g:is_job_in_progress=0
augroup end

augroup conf_nvimtree
  autocmd!
  autocmd BufLeave NvimTree NvimTreeClose
augroup end

augroup auto_write_config
  autocmd!
  autocmd BufWritePost ~/.local/share/chezmoi/* silent !chezmoi apply --source-path "%"
augroup end
