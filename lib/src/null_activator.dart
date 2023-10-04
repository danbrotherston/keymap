import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

@immutable
class NullActivator extends ShortcutActivator {
  @override
  bool accepts(RawKeyEvent event, RawKeyboard state) => false;

  @override
  String debugDescribeKeys() => "Null activator cannot be activated.";

  @override
  Iterable<LogicalKeyboardKey>? get triggers => [];
}
