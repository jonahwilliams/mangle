import 'package:mangle/src/worker.dart';

void main() {
  importScripts('js/worker.js');
  // Hello world.
  patchStart(0);
  elementOpenStart('div');
  elementOpenEnd('div');
  text('Hello world');
  elementClose('div');
  patchEnd();
  flushMessages();
}