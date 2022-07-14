vim.cmd[[command! -nargs=+ G lua fn.open_shell("git "..<q-args>)]]

return {}
