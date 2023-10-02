import 'package:example/category_header_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';

///This example shows how to link the help screen to a callback
///and display it. It also shows changing the default key used
///to show the help screen.
/// It uses a global key to let the user
///call up the help screen with a button in the app bar.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner:
          false, //the banner can block view of the help button
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  //The shortcuts used by the KeyMap
  late Map<Shortcut, Intention> shortcuts;

  @override
  void initState() {
    super.initState();
    shortcuts = _getShortcuts();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void increaseBy(int amount) {
    setState(() {
      _counter += amount;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  //each shortcut is defined by the key pressed, the method called and a
  //human-readable description. You can optionally add modifiers like control,
  //alt, etc.
  Map<Shortcut, Intention> _getShortcuts() {
    return const {
      Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.keyI),
        description: "increment the counter",
      ): #TempIntent,
      Shortcut(
        activator:
            SingleActivator(LogicalKeyboardKey.keyD, control: true, alt: true),
        description: "decrement the counter",
      ): #TempIntent,
      Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.enter, control: true),
        description: "increase by 10",
      ): #TempIntent,
      Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.arrowUp, alt: true),
        description: "increase by 5",
      ): #TempIntent,
      Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.arrowDown, alt: true),
        description: "decrease by 5",
      ): #TempIntent,
      Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.keyR, meta: true),
        description: "reset the counter",
      ): #TempIntent,
      Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.enter, shift: true),
        description: "reset the counter",
      ): #TempIntent,
      Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.delete, shift: true),
        description: "round down (by 10s)",
      ): #TempIntent,
      Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.keyM, shift: true),
        description: "multiply by 10",
      ): #TempIntent,
      Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.keyD),
        description: "Divide by 10",
      ): #TempIntent,
      /*
      KeyAction(
        LogicalKeyboardKey.keyI,
        'increment the counter',
        _incrementCounter,
      ),
      KeyAction(
          LogicalKeyboardKey.keyD, 'decrement the counter', _decrementCounter,
          isAltPressed: true, isControlPressed: true),
      KeyAction(LogicalKeyboardKey.enter, 'increase by 10', () {
        increaseBy(10);
      }, isControlPressed: true),
      KeyAction(LogicalKeyboardKey.arrowUp, 'increase by 5', () {
        increaseBy(5);
      }, isAltPressed: true),
      KeyAction(LogicalKeyboardKey.arrowDown, 'decrease by 5', () {
        increaseBy(-5);
      }, isAltPressed: true),
      KeyAction(LogicalKeyboardKey.keyR, 'reset the counter ', () {
        _resetCounter();
      }, isMetaPressed: true),
      KeyAction(LogicalKeyboardKey.enter, 'reset the counter ', () {
        _resetCounter();
      }, isShiftPressed: true),
      KeyAction(LogicalKeyboardKey.delete, 'round down (by 10s)', () {
        setState(() {
          _counter = _counter ~/ 10;
        });
      }, isShiftPressed: true),
      KeyAction(LogicalKeyboardKey.keyM, 'multiply by 10', () {
        setState(() {
          _counter = _counter * 10;
        });
      }, isShiftPressed: true),
      KeyAction(
        LogicalKeyboardKey.keyD,
        'Divide by 10',
        () {
          setState(() {
            _counter = _counter ~/ 10;
          });
        },
      )*/
    };
  }

  //used by the help icon button in the AppBar
  final GlobalKey<KeyboardShortcutsState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcuts(
        key: _key,
        showDismissKey: LogicalKeyboardKey.f2,
        bindings: shortcuts,
        columnCount: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              Tooltip(
                  message: 'Show keyboard shortcuts',
                  child: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      _key.currentState?.toggleOverlay();
                    },
                  )),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}
