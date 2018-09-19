import 'dart:io';
import 'dart:async';

import 'package:path/path.dart' as path;

// Path to rollup on linux/mac machine that npm installed correctly.
const rollup = 'node_modules/rollup/bin/rollup';

// Assumes a local checkout of the dart sdk in the parent directory.
// Somewhat based on:
// https://github.com/dart-lang/sdk/blob/5721d8af6d8755fa6f70f3951de2c451c57bf12f/pkg/dev_compiler/tool/ddb#L7
Future<void> main(List<String> args) async {
  var dartSdk = '../dart-sdk';
  var ddcPath = '../dart-sdk/bin/dartdevc';
  var sdkJsPath = path.join(dartSdk, 'lib', 'dev_compiler', 'es6', 'dart_sdk.js');
  var ddcSdk = path.join(dartSdk, 'lib', '_internal', 'ddc_sdk.sum');
  print('running');
  var result = Process.runSync(ddcPath, <String>[
    '-o',
    'out/main.ddc.js',
    '--modules=es6',
    '--library-root=mangle'
    '--dart-sdk-summary=$ddcSdk',
  ]..addAll(args));
  print('Result of DDC: ${result.exitCode} - ${result.stderr}');

  Process.runSync('cp', <String>[sdkJsPath, 'out/dart_sdk.js']);

  String file = new File('out/main.ddc.js').readAsStringSync();
  file = file.replaceFirst("} from 'dart_sdk';", "} from './dart_sdk.js';");
  new File('out/main.ddc.js').writeAsStringSync(file);

  result= Process.runSync(rollup, <String>[
    'out/main.ddc.js',
    '-c',
    'rollup.config.js',
  ]);
  print('Result of Rollup: ${result.exitCode} - ${result.stderr}');
}