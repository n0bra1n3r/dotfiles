my_snippets {
  dart = {
    ["create flutter stateless widget class"] = {
      prefix = "flutterstatelesswidget",
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
      prefix = "flutterstatefulwidget",
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
    ["create project snippet"] = {
      prefix = "projectsnippet",
      body = [=[
      ["${1:name}"] = { --{{{
        prefix = "${2:prefix}",
        body = [[
        $0
        ]],
      }, --}}}
      ]=],
    },
    ["create project task"] = {
      prefix = "projecttask",
      body = [=[
      ["${1:name}"] = { --{{{
        cmd = "${2:command}",
        args ={
          "${3:args}",
        },
        priority = 99,
      }, --}}}
      ]=],
    },
  },
}
