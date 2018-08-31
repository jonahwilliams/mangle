abstract class Event {
  const Event();

  static const focus = 'onfocus';
  static const blur = 'onblur';
  static const submit = 'onsubmit';
  static const reset = 'onreset';
  static const keydown = 'onkeydown';
  static const input = 'oninput';
  static const mouseover = 'onmouseover';
}

class FocusEvent extends Event {}

class BlurEvent extends Event {}

class SubmitEvent extends Event {}

class ResetEvent extends Event {}

class KeyDownEvent extends Event {
  const KeyDownEvent(this.keyCode);

  final int keyCode;
}

class KeyUpEvent extends Event {
  const KeyUpEvent(this.keyCode);

  final int keyCode;
}

class KeyPressEvent extends Event {
  const KeyPressEvent(this.keyCode);

  final int keyCode;
}

class MouseDownEvent extends Event {}

class MouseUpEvent extends Event {}

class MouseMoveEvent extends Event {}

class MouseOverEvent extends Event {}

class MouseEnterEvent extends Event {}

class MouseLeaveEvent extends Event {}

class InputEvent extends Event {
  const InputEvent(this.value);

  final String value;
}

class ChangeEvent extends Event {
  const ChangeEvent(this.value);

  final String value;
}

class ClickEvent extends Event {}

class DoubleClickEvent extends Event {}



