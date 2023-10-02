import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keymap/keymap.dart';

class IntentReceiver extends StatefulWidget {
  final Widget child;
  final Map<Intention, IntentHandler> actions;

  const IntentReceiver({
    super.key,
    required this.child,
    required this.actions,
  });

  @override
  State<IntentReceiver> createState() => IntentReceiverState();
}

class IntentReceiverState extends State<IntentReceiver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    IntentManager.instance.registerHandlers(widget.actions);
  }

  @override
  void didUpdateWidget(covariant IntentReceiver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.actions, widget.actions)) {
      IntentManager.instance.deregisterHandlers(oldWidget.actions);
      IntentManager.instance.registerHandlers(widget.actions);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    IntentManager.instance.deregisterHandlers(widget.actions);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
