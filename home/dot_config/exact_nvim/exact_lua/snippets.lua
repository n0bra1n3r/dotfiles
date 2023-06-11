my_snippets {
  lua = {
    ["create snippet"] = {
      prefix = "snippet",
      description = "Create a new object.",
      body = [=[
      ["${1:name}"] = {
        prefix = "${2:prefix}",
        description = "${3:description}",
        body = [[
        ${4:body}
        ]],
      },
      ]=],
    },
  },
}
