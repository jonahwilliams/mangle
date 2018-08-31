@JS()
library client;

import 'dart:html';

import 'package:js/js.dart';

import 'shared.dart';

class RenderClient {
  RenderClient._(String scriptFile) {
    _worker = new Worker(scriptFile);
    _worker.onMessage.listen(_handleMessage);
  }

  Worker _worker;
  List<Object> _pending;
  int _index;
  int _frameBudget = 1000;
  final _patchBoundaries = <String, Node>{};

  void _handleMessage(MessageEvent event) {
    _pending = event.data;
    _index = 0;
    _render();
  }

  void _render() async {
    int frameStart = 0;
    for (; _index < _pending.length; ) {
      final int command = _pending[_index];
      if (command == RenderCommand.patchCommand) {
        final String id = _pending[_index + 1];
        final Node node = id == null ? document.body : _patchBoundaries[id];
        _index += 3;
        IncrementalDom.patch(node, allowInterop(_renderPatch));
      } else {
        assert(false);
      }
      if (_index - frameStart >= _frameBudget) {
        await window.animationFrame;
        frameStart = _index;
      }
    }
  }

  void _renderPatch(Object _) {
    Node currentParent;
    for (; _index < _pending.length; _index += 3) {
      final int command = _pending[_index];
      switch (command) {
        case RenderCommand.elementOpenCommand:
          final String name = _pending[_index + 1];
          currentParent = IncrementalDom.elementOpen(name);
          break;
        case RenderCommand.elementCloseCommand:
          final String name = _pending[_index + 1];
          IncrementalDom.elementClose(name);
          break;
        case RenderCommand.elementOpenEndCommand:
          currentParent = IncrementalDom.elementOpenEnd();
          break;
        case RenderCommand.elementOpenStartCommand:
          final String name = _pending[_index + 1];
          IncrementalDom.elementOpenStart(name);
          break;
        case RenderCommand.attributeCommand:
            final String name = _pending[_index + 1];
            final Object value = _pending[_index + 2];
           IncrementalDom.attribute(name, value);
          break;
        case RenderCommand.textCommand:
          final String value = _pending[_index + 1];
          IncrementalDom.text(value);
          break;
        case RenderCommand.patchBoundaryCommand:
          final String id = _pending[_index + 1];
          _patchBoundaries[id] = currentParent;
          break;
        case RenderCommand.eventListenerCommand:
          final String type = _pending[_index + 1];
          final String key = _pending[_index + 2];
          IncrementalDom.attribute(type, _makeCallback(key));
          break;
        case RenderCommand.patchCommand:
          return;
      }
    }
  }

  Function _makeCallback(String key) {
    return allowInterop((Event _) {
      _worker.postMessage(key);
    });
  }
}

@JS('IncrementalDOM')
abstract class IncrementalDom {
  external static void text(String value);

  external static void elementOpenStart(String name);

  external static Node elementOpenEnd();

  external static Node elementOpen(String name);

  external static Node elementClose(String name);

  @JS('attr')
  external static void attribute(String name, Object value);

  external static void patch(Node node, Function patchFn);

  external static Node currentElement();

  external static Node currentPointer();
}

/// Run the application with a main entrypoint in [scriptFile].
void runApp(String scriptFile) {
  new RenderClient._(scriptFile);
}