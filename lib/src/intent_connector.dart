import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:keymap/keymap.dart';

class IntentConnector extends StatelessWidget {
  Widget child;
  Intention intent;
  IntentConnector({
    required this.child,
    required this.intent,
  }) : super(key: GlobalKey());

  @override
  Widget build(BuildContext context) => IntentReceiver(
        child: child,
        actions: {
          intent: () async {
            RenderBox renderbox = (key as GlobalKey)
                .currentContext!
                .findRenderObject() as RenderBox;

            final targetPos = renderbox.localToGlobal(const Offset(1, 1));

            GestureBinding.instance.handlePointerEvent(PointerDownEvent(
              position: targetPos,
            )); //trigger button up,

            await Future.delayed(const Duration(milliseconds: 50));
            //add delay between up and down button

            GestureBinding.instance.handlePointerEvent(PointerUpEvent(
              position: targetPos,
            )); //trigger button down
          },
        },
      );
}
