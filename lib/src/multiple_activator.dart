import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class MultipleActivator extends ShortcutActivator {
  final List<ShortcutActivator> activators;

  const MultipleActivator({required this.activators}) : super();

  @override
  bool accepts(RawKeyEvent event, RawKeyboard state) =>
      activators.any((activator) => activator.accepts(event, state));

  @override
  String debugDescribeKeys() =>
      activators.map((activator) => activator.debugDescribeKeys()).join(", ");

  @override
  Set<LogicalKeyboardKey> get triggers => activators.fold(
      {}, (triggers, activator) => {...triggers, ...activator.triggers ?? {}});
}
