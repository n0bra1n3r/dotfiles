function plug.config()
  require'toggleterm'.setup {
    autochdir = true,
    hide_numbers = false,
    direction = "float",
    open_mapping = nil,
    -- required to avoid '\r\n' for `chansend` in git bash
    shell = "powershell",
  }
end
