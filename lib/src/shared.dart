/// Rendering command codess.
abstract class RenderCommand {
  static const elementOpenStartCommand = 0;
  static const elementOpenEndCommand = 1;
  static const attributeCommand = 2;
  static const elementCloseCommand = 3;
  static const textCommand = 4;
  static const elementOpenCommand = 5;
  static const eventListenerCommand = 6;
  static const patchCommand = 7;
  static const patchBoundaryCommand =8;
}