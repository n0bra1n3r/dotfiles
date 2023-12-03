my_globals {
  project_type = 'flutter',
}

my_autocmds {
  { 'BufWritePost',
    pattern = {
      '*/controllers/*_controller.dart',
      '*/models/*_model.dart',
      '*/providers/*_provider.dart',
      'constants.dart',
    },
    callback = function(args)
      fn.run_task([[Run codegen]], {
        '--build-filter',
        vim.fn.fnamemodify(args.file, ':~:.:h')..'/'..vim.fn.fnamemodify(args.file, ':t:r')..'.*',
      })
    end,
  },
  {
    'BufWritePost',
    pattern = { '*.arb' },
    callback = function()
      fn.run_task[[Gen strings]]
    end,
  },
}

my_tasks {
  ["Install dependencies"] = {
    cmd = 'fvm',
    args = {
      'flutter',
      'pub',
      'get',
    },
    deps = { [[Gen strings]], [[Run codegen]] },
    priority = 1,
  },
  ["Run codegen"] = {
    cmd = 'fvm',
    args = {
      'dart',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    },
    deps = { [[Hot reload]] },
    priority = 52,
  },
  ["Gen strings"] = {
    cmd = 'fvm',
    args = {
      'flutter',
      'gen-l10n',
    },
    priority = 53,
  },
}

my_launchers {
  dart = {
    {
      name = "Launch app",
      request = 'launch',
    },
  },
}

my_snippets {
  dart = {
    ["create freezed data class"] = {
      prefix = 'fdclass',
      body = [[
      import 'package:freezed_annotation/freezed_annotation.dart';

      part '$TM_FILENAME_BASE.freezed.dart';
      part '$TM_FILENAME_BASE.g.dart';

      @freezed
      sealed class ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/} with _$${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/} {
        const factory ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}(${1:params}) = _${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/};

        factory ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}.fromJson(Map<String, dynamic> json) => _$${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/}FromJson(json);
        $0
      }
      ]],
    },
    ["create riverpod provider"] = {
      prefix = 'rprovider',
      body = [[
      import 'package:riverpod_annotation/riverpod_annotation.dart';

      part '$TM_FILENAME_BASE.g.dart';

      @riverpod
      ${1:type} ${TM_FILENAME_BASE/(.*)_provider/${1:/camelcase}/}(${TM_FILENAME_BASE/(.*)_provider/${1:/pascalcase}/}Ref ref) {
        $0
      }
      ]]
    },
    ["create riverpod controller"] = {
      prefix = 'rcontroller',
      body = [[
      import 'package:riverpod_annotation/riverpod_annotation.dart';

      part '$TM_FILENAME_BASE.g.dart';

      @riverpod
      final class ${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/} extends _$${TM_FILENAME_BASE/(.*)/${1:/pascalcase}/} {
        @override
        FutureOr<${1:type}> build() async {}$0
      }
      ]]
    },
  },
}
