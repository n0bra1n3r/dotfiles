-- vim: foldmethod=marker foldlevel=0 foldenable

local opt = vim.opt

my_options {
  background = "dark",
  opt.clipboard + "unnamed,unnamedplus",
  cmdheight = 0,
  confirm = true,
  cursorline = true,
  cursorlineopt = "number",
  opt.display + "lastline,uhex",
  equalalways = true,
  expandtab = true,
  fillchars = { --{{{
    eob = " ",
    fold = " ",
    foldopen = "",
    foldsep = " ",
    foldclose = "",
    stl = " ",
  }, --}}}
  foldcolumn = '1',
  foldenable = true,
  foldlevelstart = 99,
  foldmethod = "indent",
  grepprg = "rg --vimgrep --no-heading --smart-case",
  grepformat = "%f:%l:%c:%m",
  guicursor = { --{{{
    "v-n-sm:block",
    "i-c-ci-ve:ver25",
    "r-cr:hor20",
    "o:hor20-blinkwait0-blinkon400-blinkoff250",
  }, --}}}
  guifont = "CaskaydiaCove Nerd Font:h12",
  hidden = true,
  ignorecase = true,
  isfname = "@,48-57,/,\\,.,-,_,+,,,#,$,%,~,=",
  isident = "@,48-57,_,192-255",
  linebreak = true,
  list = true,
  opt.listchars + { --{{{
    multispace = "· ",
    tab = "▸ ",
  }, --}}}
  mouse = "nv",
  number = false,
  numberwidth = 2,
  ruler = false,
  scrollback = 9001,
  sessionoptions = "buffers,folds,winsize,winpos",
  selection = "exclusive",
  shiftwidth = 2,
  opt.shortmess + "sFISW",
  showbreak = "↪",
  showcmd = false,
  showmode = false,
  showtabline = 0,
  signcolumn = "yes",
  smartcase = true,
  smartindent = true,
  spell = false,
  splitbelow = true,
  splitright = true,
  tabstop = 2,
  termguicolors = true,
  timeoutlen = 400,
  title = true,
  undofile = true,
  updatetime = 500,
  virtualedit = "onemore",
  opt.whichwrap + "<>[]hl",
  wrap = true,
}
