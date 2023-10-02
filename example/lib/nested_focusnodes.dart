import 'package:example/category_header_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:keymap/keymap.dart';

void main() => runApp(const MyApp());

///An example of using the Keymap widget to implement keyboard
///shortcuts
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'keymap shortcut example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
        ),
        body: const Center(
          child: MyStatefulWidget(),
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcuts(
      columnCount: 2,
      bindings: const {
        Shortcut(
          activator: SingleActivator(LogicalKeyboardKey.keyA),
          description: "increment the counter",
        ): #TempIntent,
        Shortcut(
          activator: SingleActivator(LogicalKeyboardKey.keyD),
          description: "decrement the counter",
        ): #TempIntent,
        /*KeyAction(
          LogicalKeyboardKey.keyA,
          'increment the counter',
          () {
            setState(() {
              count++;
            });
          },
        ),
        KeyAction(
          LogicalKeyboardKey.keyD,
          'decrement the counter',
          () {
            setState(() {
              count--;
            });
          },
        ),*/
      },
      child: Column(
        children: [
          const Text('Press "a" for adding, "d" to subtract'),
          Text('count: $count'),
        ],
      ),
    );
  }
}
