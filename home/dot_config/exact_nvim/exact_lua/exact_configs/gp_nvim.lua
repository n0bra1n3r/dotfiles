return {
  config = function()
    require'gp'.setup {
      hooks = {
        ApiDoc = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Enrich the public API with documentation comments that can be "
            .. "published as formal documentation. Do NOT change the code. "
            .. "Use end-of-line form for doc comments in dart. "
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
        CodeConv = function(gp, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Convert the code to equivalent idiomatic {{command}} code."
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
