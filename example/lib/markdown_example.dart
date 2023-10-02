import 'package:example/category_header_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keymap/keymap.dart';

///This example shows how to include help text in addition to the
///list of key shortcuts in Markdown format
///The help text includes tables, images and formatted text
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
      darkTheme:
          ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
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
  String? assetLoadedText;

  @override
  void initState() {
    super.initState();
    shortcuts = _getShortcuts();
    //load the help text asynchronously
    loadAssetText();
  }

  Future<void> loadAssetText() async {
    assetLoadedText = await DefaultAssetBundle.of(context)
        .loadString('assets/example_text.md');
    setState(() {});
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
      _counter += 10;
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
    return {
      const Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.arrowUp),
        description: "increment",
      ): #TempIntent,
      const Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.keyI),
        description: "increment",
      ): #TempIntent,
      const Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.keyD),
        description: "decrement",
      ): #TempIntent,
      const Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.enter),
        description: "increase by 10",
      ): #TempIntent,
      const Shortcut(
        activator: SingleActivator(LogicalKeyboardKey.keyR),
        description: "reset the counter",
      ): #TempIntent,
      /*KeyAction(
        LogicalKeyboardKey.arrowUp,
        'increment',
        _incrementCounter,
      ),
      KeyAction(LogicalKeyboardKey.keyI, 'increment', _incrementCounter),
      KeyAction(LogicalKeyboardKey.keyD, 'decrement', _decrementCounter),
      KeyAction(
        LogicalKeyboardKey.enter,
        'increase by 10',
        () {
          increaseBy(10);
        },
      ),
      KeyAction(
        LogicalKeyboardKey.keyR,
        'reset the counter ',
        _resetCounter,
      ),*/
    };
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcuts(
        helpText: assetLoadedText,
        bindings: shortcuts,
        columnCount: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
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
