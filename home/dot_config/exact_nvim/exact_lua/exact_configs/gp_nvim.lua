return {
  config = function()
    require'gp'.setup {
      hooks = {
        ApiDoc = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Enrich the public API with documentation comments that can be "
            .. "published as formal documentation. Do NOT change the code. "
            .. "Add documentation for parameters, and wrap all comments at 80 "
            .. "columns."
            .. "\n\nRespond only with the snippet of finalized code:"

          gp.Prompt(
            params,
            gp.Target.rewrite,
            nil,
            gp.config.command_model,
            template,
            gp.config.command_system_prompt
          )
        end,
      },
    }
  end,
}
