local M = {}

function M.config()
  require"stabilize".setup {
    force = true,
    forcemark = nil,
    ignore = {
      filetype = {},
      buftype = {},
    },
    nested = "QuickFixCmdPost",
  }
end

return M
