import 'package:example/category_header_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:keymap/keymap.dart';

void main() => runApp(const MyApp());

///An example showing using the keyboard widget with children containing
///focus-aware widgets, like TextFields
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
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: MyStatefulWidget(),
          ),
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
          activator: SingleActivator(LogicalKeyboardKey.keyU),
          description: "increment the counter",
        ): #IncrementIntent,
        Shortcut(
          activator: SingleActivator(LogicalKeyboardKey.keyD),
          description: "decrement the counter",
        ): #DecrementIntent,
        /*KeyAction(
          LogicalKeyboardKey.keyU,
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
      child: IntentReceiver(
        actions: {
          #DecrementIntent: () => setState(() {
                count--;
              }),
          #IncrementIntent: () => setState(() {
                count++;
              })
        },
        child: Column(
          children: [
            const Text('u for adding, down d to subtract'),
            Text('count: $count'),
            const TextField(
              maxLength: 20,
              maxLines: 1,
              decoration: InputDecoration(labelText: 'Try typing u and d'),
            ),
            ElevatedButton(onPressed: () {}, child: const Text('Other Focus')),
          ],
        ),
      ),
    );
  }
}
