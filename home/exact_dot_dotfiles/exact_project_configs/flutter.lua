-- vim: fcl=all fdm=marker fdl=0 fen

my_globals {
  project_type = 'flutter',
}

my_autocmds {
  { 'BufWritePost', -- run codegen
    pattern = {
      '*/controllers/*_controller.dart',
      '*/models/*_model.dart',
      '*/providers/*_provider.dart',
      'lib/common/constants.dart',
    }, --{{{
    callback = function(args)
      fn.run_task([[Run codegen]], {
        '--build-filter',
        vim.fn.fnamemodify(args.file, ':~:.:h')
          ..'/'
          ..vim.fn.fnamemodify(args.file, ':t:r')..'.*.dart',
      })
    end, --}}}
  },
  { { 'BufDelete', 'BufWritePre' }, -- initialize widgetbook
    pattern = {
      'widgetbook/**/*.dart',
    }, --{{{
    callback = function(args)
      if vim.fn.filereadable(args.file) == 0 then
        vim.schedule(function()
          fn.run_task[[Regen widgetbook]]
        end)
      end
    end, --}}}
  },
  { 'BufWritePost', -- generate strings
    pattern = {
      '*.arb',
    }, --{{{
    callback = function()
      fn.run_task[[Gen strings]]
    end, --}}}
  },
}

my_tasks {
  ["Install dependencies"] = { --{{{
    cmd = 'fvm',
    args = {
      'flutter',
      'pub',
      'get',
    },
    priority = 1,
  }, --}}}
  ["Run codegen"] = { --{{{
    cmd = 'fvm',
    args = {
      'flutter',
      'pub',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    },
    priority = 2,
  }, --}}}
  ["Gen strings"] = { --{{{
    cmd = 'fvm',
    args = {
      'flutter',
      'gen-l10n',
    },
    priority = 3,
  }, --}}}
  ["Regen widgetbook"] = { --{{{
    cmd = 'fvm',
    args = {
      'flutter',
      'pub',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    },
    cwd = 'widgetbook',
    priority = 4,
  }, --}}}
}

my_launchers { --{{{
  dart = vim.tbl_map(function(project)
    local env = vim.fn.fnamemodify('.env.json', ':p')
    return {
      cwd = vim.fn.fnamemodify(project, ':p:h:h'),
      name = "Launch "..(project:match'(%w+)/lib/main%.dart$' or 'app'),
      request = 'launch',
      toolArgs = vim.fn.filereadable(env) == 1 and {
        '--dart-define-from-file', env,
      } or nil,
    }
  end, vim.fn.glob('./**/lib/main.dart', true, true)),
} --}}}

my_snippets {
  dart = {
    ["create riverpod provider"] = { --{{{
      prefix = 'riverpodprovider',
      body = [[
      import 'package:riverpod_annotation/riverpod_annotation.dart';

      part '$TM_FILENAME_BASE.g.dart';

      @riverpod
      ${1:type} ${TM_FILENAME_BASE/(.*)_provider/${1:/camelcase}/}(${TM_FILENAME_BASE/(.*)_provider/${1:/pascalcase}/}Ref ref) {
        return ${2:value};
      }
      ]]
    }, --}}}
    ["create riverpod controller"] = { --{{{
      prefix = 'riverpodcontroller',
      body = [[
      import 'package:riverpod_annotation/riverpod_annotation.dart';

      part '$TM_FILENAME_BASE.g.dart';

      @riverpod
      final class ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/} extends _$${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/} {
        @override
        FutureOr<${1:type}> build() async {}$0
      }
      ]]
    }, --}}}
    ["create freezed model"] = { --{{{
      prefix = "freezedmodel",
      body = [[
      import 'package:freezed_annotation/freezed_annotation.dart';

      part '$TM_FILENAME_BASE.freezed.dart';
      part '$TM_FILENAME_BASE.g.dart';

      @freezed
      sealed class ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/} extends _$${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/} {
        // ignore: invalid_annotation_target
        @JsonSerializable(fieldRename: FieldRename.snake)
        const factory ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}({
          $0
        }) = _${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/};

        factory ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}.fromJson(Map<String, dynamic> json) => _$${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}FromJson(json);
      }
      ]],
    }, --}}}
    ["create widgetbook usecase"] = { --{{{
      prefix = 'widgetbookusecase',
      body = [[
      import 'package:widgetbook_annotation/widgetbook_annotation.dart';

      @UseCase(name: '${1:name}', type: ${2:type})
      Widget ${TM_FILENAME_BASE/(.*)/${1:/camelcase}/}(BuildContext context) {
        return $0;
      }
      ]]
    }, --}}}
  },
}
