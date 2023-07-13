my_snippets {
  dart = {
    ["create flutter stateless widget class"] = {
      prefix = "fstatelesswidget",
      body = [[
      import 'package:flutter/material.dart';

      class ${TM_FILENAME_BASE/([a-z]*)_*([a-z]*)/${1:/capitalize}${2:/capitalize}/g} extends StatelessWidget {
        const ${TM_FILENAME_BASE/([a-z]*)_*([a-z]*)/${1:/capitalize}${2:/capitalize}/g}({super.key});

        @override
        Widget build(BuildContext context) {
          return ${1:child}(${2:args});
        }
      }
      ]]
    },
    ["create flutter stateful widget class"] = {
      prefix = "fstatefulwidget",
      body = [[
      import 'package:flutter/material.dart';

      class ${TM_FILENAME_BASE/([a-z]*)_*([a-z]*)/${1:/capitalize}${2:/capitalize}/g} extends StatefulWidget {
        const ${TM_FILENAME_BASE/([a-z]*)_*([a-z]*)/${1:/capitalize}${2:/capitalize}/g}({super.key});

        @override
        State<${TM_FILENAME_BASE/([a-z]*)_*([a-z]*)/${1:/capitalize}${2:/capitalize}/g}> createState() => _${TM_FILENAME_BASE/([a-z]*)_*([a-z]*)/${1:/capitalize}${2:/capitalize}/g}State();
      }

      class _${TM_FILENAME_BASE/([a-z]*)_*([a-z]*)/${1:/capitalize}${2:/capitalize}/g}State extends State<${TM_FILENAME_BASE/([a-z]*)_*([a-z]*)/${1:/capitalize}${2:/capitalize}/g}> {
        @override
        Widget build(BuildContext context) {
          return ${1:child}(${2:args});
        }
      }
      ]]
    },
  },
  lua = {
    ["create snippet"] = {
      prefix = "snippet",
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
