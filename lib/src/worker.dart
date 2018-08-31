@JS()
library worker;

import 'package:js/js.dart';

import 'shared.dart';

final context = new RenderContext._();

/// The rendering context buffers and flushes rendering operations to a
/// rendering client.
class RenderContext {
  RenderContext._() {
    onmessage = allowInterop((MessageEvent data) {
      print(data.data);
    });
  }

  List<Object> _pending = <Object>[];
  bool _debugInElementHead = false;
  bool _debugInPatchOperation = false;

  /// Start rendering an element with tag [name] and set the render context to
  /// the opening tag.
  void elementOpenStart(String name) {
    assert(_debugInPatchOperation);
    _pending.add(RenderCommand.elementOpenStartCommand);
    _pending.add(name);
    _pending.add(null);
    _debugInElementHead = true;
  }

  /// Finish rendering the current element opening tag and set the render context to
  /// the child list.
  void elementOpenEnd() {
    assert(_debugInPatchOperation);
    _pending.add(RenderCommand.elementOpenEndCommand);
    _pending.add(null);
    _pending.add(null);
    _debugInElementHead = false;
  }

  /// Start rendering an element with tag [name] and set the render context to
  /// the child list.
  ///
  /// This method is provided as a shortcut for an [elementOpenStart] and
  /// [elementOpenEnd] with no calls in between.
  void elementOpen(String name) {
    assert(_debugInPatchOperation);
    _pending.add(RenderCommand.elementOpenCommand);
    _pending.add(name);
    _pending.add(null);
  }

  /// Finish rendering the child list of the last element with tag [name].
  void elementClose(String name) {
    assert(_debugInPatchOperation);
    _pending.add(RenderCommand.elementCloseCommand);
    _pending.add(name);
    _pending.add(null);
  }

  /// Add an an attribute with [name] and [value] to the current element head.
  ///
  /// value must be an [int], [double], [String], [bool], or [null].
  void attribute(String name, Object value) {
    assert(_debugInPatchOperation);
    assert(_debugInElementHead);
    assert(value is int || value is double || value is String || value is bool || value == null);
    _pending.add(RenderCommand.attributeCommand);
    _pending.add(name);
    _pending.add(value);
  }

  void eventListener(String type, String key) {
    assert(_debugInPatchOperation);
    assert(_debugInElementHead);
    _pending.add(RenderCommand.eventListenerCommand);
    _pending.add(type);
    _pending.add(key);
  }

  void text(String value) {
    assert(_debugInPatchOperation);
    assert(!_debugInElementHead);
    _pending.add(RenderCommand.textCommand);
    _pending.add(value);
    _pending.add(null);
  }

  /// Start a rendering patch operation.
  void start(String id) {
    assert(!_debugInPatchOperation);
    _debugInPatchOperation = true;
    _pending.add(RenderCommand.patchCommand);
    _pending.add(id);
    _pending.add(null);
  }

  void boundary(String id) {
    assert(_debugInPatchOperation);
    assert(!_debugInElementHead);
    _pending.add(RenderCommand.patchBoundaryCommand);
    _pending.add(id);
    _pending.add(null);
  }

  /// Finish a rendering patch operation.
  void end() {
    assert(_debugInPatchOperation);
    _debugInPatchOperation = false;
  }

  /// Flush the rendering buffer to the client.
  void flush() {
    assert(!_debugInPatchOperation);
    assert((_pending.length % 3) == 0); // is divisible by 3.
    postMessage(_pending);
    _pending = <Object>[];
  }
}

@JS()
abstract class MessageEvent {
  external dynamic get data;
}

@JS()
external set onmessage(dynamic callback);

@JS()
external dynamic get onmessage;

@JS()
external void postMessage(Object value);