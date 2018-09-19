import 'dart:async';

import 'package:angular_ast/angular_ast.dart' as ng;
import 'package:build/build.dart';

/// A builder for incremental-dom templates on the client.
class IncrementalDomBuilder implements Builder {
  const IncrementalDomBuilder();

  @override
  Future<void> build(BuildStep step) async {
    final inputId = step.inputId;
    final contents = await step.readAsString(inputId);
    final templateJS = inputId.addExtension('.js');
    final templateDart = inputId.addExtension('.dart');
    final name = inputId.path.split('/').last.split('.').first;
    final visitor = IncrementalDomVisitor(name);
    final nodes = ng.parse(contents, sourceUrl: '', parseExpressions: false, desugar: true);
    for (final node in nodes)
      node.accept(visitor);
    await step.writeAsString(templateJS, visitor.finish());
    await step.writeAsString(templateDart, _dartTemplate(name));
  }

  @override
  final buildExtensions = const {
    '.html': ['.html.js', '.html.dart']
  };

  String _dartTemplate(String name) {
    return '@JS()\n'
    'library $name;\n'
    '\n'
    'import \'package:js/js.dart\';\n'
    '\n'
    '@JS()\n'
    'external void render$name(dynamic value);\n';
  }
}

class IncrementalDomVisitor extends ng.TemplateAstVisitor<void, void> {
  static const prefix = 'IDOM';

  IncrementalDomVisitor(String name) {
    buffer.writeln('import * as $prefix from "incremental-dom";');
    buffer.writeln('export default function render$name(scope) {');
  }

  String finish() {
    buffer.writeln('}');
    return buffer.toString();
  }

  final buffer = StringBuffer();
  int indent = 1;
  final locals = Set<String>();

  String get leading => ' ' * (indent * 2);

  @override
  void visitEmbeddedTemplate(ng.EmbeddedTemplateAst astNode, [void context]) {
    final properties = <String, ng.PropertyAst>{};
    for (var prop in astNode.properties)
      properties[prop.name] = prop;
    final ngIf = properties['ngIf'];
    final ngFor = properties['ngForOf'];
    if (ngIf != null) {
      buffer.writeln('${leading}if (scope.${ngIf.value}) {');
      indent++;
      for (var child in astNode.childNodes)
        child.accept(this, context);
      indent--;
      buffer.writeln('$leading}');
      return;
    }
    if (ngFor != null) {
      final implicit = astNode.letBindings.singleWhere((binding) => binding.value == null);
      final index = astNode.letBindings.firstWhere((binding) => binding.value == 'index', orElse: () => null)?.name ?? 'index';
      buffer.writeln('${leading}for (var $index = 0; i < scope.${ngFor.value}.length; $index++) {');
      indent++;
      buffer.writeln('${leading}var ${implicit.name} = scope.${ngFor.value}[$index];');
      locals.add(implicit.name);
      for (var child in astNode.childNodes)
        child.accept(this, context);
      locals.remove(implicit.value);
      indent--;
      buffer.writeln('${leading}}');
      return;
    }
    throw new UnsupportedError('only ngFor and ngIf on templates are supported');
  }

  @override
  void visitElement(ng.ElementAst astNode, [void context]) {
    if (astNode.attributes.isNotEmpty || astNode.events.isNotEmpty) {
      buffer.writeln('${leading}$prefix.elementOpenStart("${astNode.name}");');
      for (var attribute in astNode.attributes) {
        if (attribute.mustaches.isEmpty) {
          buffer.writeln('${leading}$prefix.attr("${attribute.name}", "${attribute.value}")');
        } else {
          final moustache = attribute.mustaches.single;
          buffer.writeln('${leading}$prefix.attr("${attribute.name}", scope.${moustache.value});');
        }
      }
      for (var event in astNode.events)
        buffer.writeln('${leading}$prefix.attr("${event.name}", scope.${event.value});');
      buffer.writeln('${leading}$prefix.elementOpenEnd()');
    } else {
      buffer.writeln('${leading}$prefix.elementOpen("${astNode.name}")');
    }
    for (var child in astNode.childNodes)
      child.accept(this, context);
    buffer.writeln('${leading}$prefix.elementClose("${astNode.name}")');
  }

  @override
  void visitAnnotation(ng.AnnotationAst astNode, [void context]) {}

  @override
  void visitAttribute(ng.AttributeAst astNode, [void context]) {}

  @override
  void visitBanana(ng.BananaAst astNode, [void context]) {}

  @override
  void visitCloseElement(ng.CloseElementAst astNode, [void context]) {}

  @override
  void visitComment(ng.CommentAst astNode, [void context]) {}

  @override
  void visitEmbeddedContent(ng.EmbeddedContentAst astNode, [void context]) {}

  @override
  void visitEvent(ng.EventAst astNode, [void context]) {}

  @override
  void visitExpression(ng.ExpressionAst astNode, [void context]) {}

  @override
  void visitInterpolation(ng.InterpolationAst astNode, [void context]) {
    if (locals.contains(astNode.value))
      buffer.writeln('${leading}$prefix.text(${astNode.value})');
    else
      buffer.writeln('${leading}$prefix.text(scope.${astNode.value})');
  }

  @override
  void visitLetBinding(ng.LetBindingAst astNode, [void context]) {}

  @override
  void visitProperty(ng.PropertyAst astNode, [void context]) {}

  @override
  void visitReference(ng.ReferenceAst astNode, [void context]) {}

  @override
  void visitStar(ng.StarAst astNode, [void context]) {}

  @override
  void visitText(ng.TextAst astNode, [void context]) {
    final String text = astNode.value.trim();
    if (text.isEmpty)
      return;
    buffer.writeln('${leading}$prefix.text("$text")');
  }
}
