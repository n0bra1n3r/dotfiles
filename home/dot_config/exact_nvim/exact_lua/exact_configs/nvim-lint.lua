return {
  config = function()
    require 'lint'.linters.nim_check = {
      cmd = 'nim',
      stdin = false,
      args = { 'check' },
      stream = 'stderr',
      ignore_exitcode = false,
      parser = require 'lint.parser'.from_errorformat(
        [[%f(%l\, %c) %trror: %m,]]
        .. [[%f(%l\, %c) %tarning: %m,]]
        .. [[%N%f(%l\, %c) Hint: %m,]]
        .. [[%A%f(%l\, %c) %m,]]
        .. [[%-IHint: %m,]]
        .. [[%-EError: %m,]]
        .. [[%-ICC: %m,]]
        .. [[%-Istack trace: %m]]),
    }

    require 'lint'.linters_by_ft = {
      nim = { 'nim_check' }
    }
  end,
}
