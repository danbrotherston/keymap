import 'package:example/category_header_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';

///An example showing the keymap working with a dialog
///containing text fields.
void main() => runApp(const MaterialApp(
    title: 'Dialog Example', home: Material(child: TextFieldExample())));

class TextFieldExample extends StatefulWidget {
  const TextFieldExample({Key? key}) : super(key: key);

  @override
  State<TextFieldExample> createState() => _TextFieldExampleState();
}

class _TextFieldExampleState extends State<TextFieldExample> {
  late Map<Shortcut, Intention> bindings;
  int count = 0;

  @override
  void initState() {
    super.initState();
    bindings = const {
      Shortcut(
        activator: CharacterActivator('D'),
        description: "open dialog",
      ): #TempIntent,
      Shortcut(
        activator: CharacterActivator('A'),
        description: "Add 1",
      ): #TempIntent,
      Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.keyS),
        description: "Subtract 1",
      ): #TempIntent,
      /*KeyAction.fromString('D', 'open dialog', () {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: Text('Hello, world'),
              );
            });
      }),
      KeyAction(LogicalKeyboardKey.keyS, 'Subtract 1', () {
        setState(() {
          count--;
        });
      }),
      KeyAction.fromString(
        "A",
        'Add 1',
        () {
          setState(() {
            count++;
          });
        },
      ),*/
    };
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcuts(
        bindings: bindings,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('The count is $count'),
            const TextField(
              decoration: InputDecoration(hintText: 'First Field'),
            ),
            const TextField(
              decoration: InputDecoration(hintText: 'Second Field'),
            ),
          ],
        ));
  }
}
