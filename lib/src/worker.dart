@JS()
library worker;

import 'package:js/js.dart';

external void importScripts(String script);

external void elementOpenStart(String name);

external void elementOpenEnd(String name);

external void elementClose(String name);

external void attribute(String name, Object value);

external void identify(int id);

external void listen(String type, int id);

external void text(String value);

external void patchStart(int id);

external void patchEnd();

external void flushMessages();

external setEventDispatcher(void Function(int id, Object data) cb);