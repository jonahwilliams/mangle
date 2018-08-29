import 'package:js/js.dart';
import 'package:mangle/src/worker.dart';

typedef RawCallback = void Function(Object);

final callbacks = <int, RawCallback>{};
int count = 0;

void main() {
  importScripts('js/worker.js');
  setEventDispatcher(allowInterop((int id, Object data) {
    final callback = callbacks[id];
    if (callback != null)
      callback(data);
  }));

  callbacks[1] = (_) {
    count++;
    helloWorld();
  };

  helloWorld();
}

void helloWorld() {
  patchStart(0);
  elementOpenStart('div');
  identify(1);
  attribute("foo", true);
  elementOpenEnd('div');
  text('Hello world');
  elementClose('div');

  elementOpenStart('button');
  listen('onclick', 1);
  elementOpenEnd('button');
  text('clicked $count times');
  elementClose('button');

  patchEnd();
  flushMessages();
}
