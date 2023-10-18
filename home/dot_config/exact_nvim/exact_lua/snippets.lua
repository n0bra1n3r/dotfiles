my_snippets {
  dart = {
    ["create flutter stateless widget class"] = {
      prefix = "fstatelesswidget",
      body = [[
      import 'package:flutter/material.dart';

      class ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/} extends StatelessWidget {
        const ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}({super.key});

        @override
        Widget build(BuildContext context) {
          return $0;
        }
      }
      ]]
    },
    ["create flutter stateful widget class"] = {
      prefix = "fstatefulwidget",
      body = [[
      import 'package:flutter/material.dart';

      class ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/} extends StatefulWidget {
        const ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}({super.key});

        @override
        State<${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}> createState() => _${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}State();
      }

      class _${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}State extends State<${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}> {
        @override
        Widget build(BuildContext context) {
          return $0;
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
        $0
        ]],
      },
      ]=],
    },
  },
}
