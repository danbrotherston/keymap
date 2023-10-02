import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';

void main() => runApp(const MaterialApp(
      title: 'Categories Example',
      home: Material(
        child: CategoryHeaderExample(),
      ),
    ));

class CategoryHeaderExample extends StatefulWidget {
  const CategoryHeaderExample({super.key});

  @override
  State<CategoryHeaderExample> createState() => _CategoryHeaderExampleState();
}

class TempIntent extends Intent {}

class _CategoryHeaderExampleState extends State<CategoryHeaderExample> {
  int count = 0;
  late Map<Shortcut, Intention> bindings;
  bool showCategories = true;
  bool showLines = false;

  @override
  void initState() {
    super.initState();
    bindings = {
      const Shortcut(
        activator: CharacterActivator("I"),
        description: "Increase",
        category: "Counter",
      ): #TempIntent,
      /*setState(() {
          count++;
        });
      })*/
      const Shortcut(
        activator: CharacterActivator("%", control: true),
        description: "Increase by 5",
        category: "Counter",
      ): #TempIntent,

/*      KeyAction.fromString('5', 'Increase by 5',
          isShiftPressed: true,
          isControlPressed: true,
          categoryHeader: 'Counter', () {
        setState(() {
          count += 5;
        });
      }),*/
      const Shortcut(
        activator: CharacterActivator("%"),
        description: "Increase by 5",
        category: "Counter",
      ): #TempIntent,
      /*KeyAction.fromString('5', 'Decrease by 5',
          isShiftPressed: true, categoryHeader: 'Counter', () {
        setState(() {
          count -= 5;
        });
      }),*/
      const Shortcut(
        activator: CharacterActivator("D"),
        description: "Decrease",
        category: "Counter",
      ): #TempIntent,
      /*KeyAction.fromString('D', 'Decrease', categoryHeader: 'Counter', () {
        setState(() {
          count--;
        });
      }),*/
      const Shortcut(
        activator: CharacterActivator("A"),
        description: "About dialog",
        category: "Information",
      ): #TempIntent,
      /*KeyAction.fromString('A', 'About dialog',
          isShiftPressed: true, categoryHeader: 'Information', () {
        showAboutDialog(context: context);
      }),*/
      const Shortcut(
        activator: CharacterActivator("R"),
        description: "Random dialog",
        category: "Information",
      ): #TempIntent,
      /*KeyAction.fromString('R', 'Random dialog', categoryHeader: 'Information',
          () {
        showAboutDialog(context: context);
      }),*/
      const Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.arrowUp),
        description: "Increase",
        category: "Secondary counter",
      ): #TempIntent,
      /*KeyAction(LogicalKeyboardKey.arrowUp, 'Increase',
          categoryHeader: 'Secondary Counter', () {
        setState(() {
          count++;
        });
      }),*/
      const Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.arrowUp,
            shift: true, control: true),
        description: "Increase by 5",
        category: "Secondary counter",
      ): #TempIntent,
      /*KeyAction(LogicalKeyboardKey.arrowUp, 'Increase by 5',
          isShiftPressed: true,
          isControlPressed: true,
          categoryHeader: 'Secondary Counter', () {
        setState(() {
          count += 5;
        });
      }),*/
      const Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.arrowDown,
            shift: true, control: true),
        description: "Decrease by 5",
        category: "Secondary counter",
      ): #TempIntent,
      /*KeyAction(LogicalKeyboardKey.arrowDown, 'Decrease by 5',
          isShiftPressed: true, categoryHeader: 'Secondary Counter', () {
        setState(() {
          count -= 5;
        });
      }),*/
      const Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.arrowDown),
        description: "Decrease",
        category: "Secondary counter",
      ): #TempIntent,
      /*KeyAction(LogicalKeyboardKey.arrowDown, 'Decrease',
          categoryHeader: 'Secondary Counter', () {
        setState(() {
          count--;
        });
      }),*/
    };
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcuts(
        bindings: bindings,
        showLines: showLines,
        groupByCategory: showCategories,
        // columnCount: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text('The count is $count'),
            SwitchListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: showCategories,
                visualDensity: VisualDensity.compact,
                title: const Text('Show categories'),
                onChanged: (selected) {
                  setState(() {
                    showCategories = selected;
                  });
                }),
            SwitchListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: showLines,
                visualDensity: VisualDensity.compact,
                title: const Text('Show lines'),
                onChanged: (selected) {
                  setState(() {
                    showLines = selected;
                  });
                }),
          ],
        ));
  }
}
