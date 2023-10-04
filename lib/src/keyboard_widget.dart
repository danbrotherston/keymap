import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:keymap/keymap.dart';
import 'package:keymap/src/intent_manager.dart';

typedef Intention = Symbol;

/// A keymap widget allowing easy addition of shortcut keys to any widget tree
/// with an optional help screen overlay
class KeyboardShortcuts extends StatefulWidget {
  final bool hasFocus;
  final Widget child;

  ///Optional introductory/descriptive text to include above the table of
  ///keystroke shortcuts. It expects text in the
  ///[https://daringfireball.net/projects/markdown/] markdown format, using
  ///the [https://pub.dev/packages/flutter_markdown] flutter markdown package.
  final String? helpText;

  ///Have group the keybindings shown in the overlay grouped according to
  ///the (optional) headers associated with each shortcut
  final bool groupByCategory;

  ///The list of keystrokes and methods called
  final Map<Shortcut, Intention> bindings;

  ///The [ShortcutActivator] used to show the help screen
  final ShortcutActivator showHelpShortcut;

  ///The [ShortcutActivator] used to dismiss the help screen
  final ShortcutActivator hideHelpShortcut;

  ///The number of columns of text in the help screen
  final int columnCount;
  final VoidCallback? callbackOnHide;

  ///The color of the surface of the card used to display a help screen.
  ///If null, the card color of the inherited [ThemeData.colorScheme] will be used
  final Color? backgroundColor;

  ///Whether underlines should be shown between each help entry
  final bool showLines;

  ///The text style for the text used in the help screen. If null, the
  ///inherited [TextTheme.labelSmall] is used.
  final TextStyle? textStyle;

  /// Creates a new KeyboardWidget with a list of Keystrokes and associated
  /// functions [bindings], a required [child] widget and an optional
  /// keystroke to show and dismiss the displayed map, [showDismissKey].
  ///
  /// The number of columns of text used to display the options can be optionally
  /// chosen. It defaults to one column.
  ///
  /// The [backgroundColor] and [textColor] set the background of the
  /// card used to display the help screen background and text respectively.
  /// Otherwise they default to the inherited theme's card and primary text
  /// colors.
  ///
  /// By default the F1 keyboard key is used to show and dismiss the keymap
  /// display. If another key is preferred, set the [showDismissKey] to another
  /// [LogicalKeyboardKey].
  ///
  /// If the help map should be displayed, set the parameter [showMap] to true.
  /// This lets the implementer programmatically show the map.
  /// You would usually pair this with a function [callbackOnHide] so that the caller
  /// to show the help screen can be notified when it is hidden
  ///
  const KeyboardShortcuts({
    Key? key,
    required this.bindings,
    this.helpText,
    this.hasFocus = true,
    required this.child,
    this.showHelpShortcut = const SingleActivator(LogicalKeyboardKey.f1),
    this.hideHelpShortcut = const MultipleActivator(activators: [
      SingleActivator(LogicalKeyboardKey.f1),
      SingleActivator(LogicalKeyboardKey.escape),
    ]),
    this.groupByCategory = false,
    this.columnCount = 1,
    this.backgroundColor,
    this.showLines = false,
    this.textStyle,
    this.callbackOnHide,
  })  : assert(columnCount > 0),
        super(key: key);

  @override
  KeyboardShortcutsState createState() => KeyboardShortcutsState();
}

class KeyboardShortcutsState extends State<KeyboardShortcuts> {
  late FocusNode _focusNode;

  OverlayEntry? _overlayEntry;

  static const Color defaultBackground = Color(0xFF0a0a0a);
  static const Color shadow = Color(0x55000000);
  static const Color defaultTextColor = Colors.white;

  static const TextStyle defaultTextStyle =
      TextStyle(color: defaultTextColor, fontSize: 12);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
  }

  @override
  void didUpdateWidget(KeyboardShortcuts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget _getAltText(
    String text,
    TextStyle _textStyle,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: Text(
        text,
        style: _textStyle,
      ),
    );
  }

  //returns text surrounded with a rounded-rect
  Widget _getBubble(
      String text, Color color, Color color2, TextStyle _textStyle,
      {bool invert = false}) {
    // bool isDark = background.computeLuminance() < .5;
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
          color: invert ? color : color2,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color)),
      child: Text(text,
          style: _textStyle.copyWith(
              color: invert
                  ? color2
                  : color)), //isDark? _whiteStyle :_blackStyle,),
    );
  }

  //returns the modifier key as text or a symbol (where possible)
  String _getModifiers(ShortcutActivator shortcut) {
    final (meta, shift, alt, control) = switch (shortcut) {
      SingleActivator(:final meta, :final shift, :final alt, :final control) =>
        (meta, shift, alt, control),
      LogicalKeySet() => (
          shortcut.keys.contains(LogicalKeyboardKey.meta),
          shortcut.keys.contains(LogicalKeyboardKey.shift),
          shortcut.keys.contains(LogicalKeyboardKey.alt),
          shortcut.keys.contains(LogicalKeyboardKey.control),
        ),
      CharacterActivator(
        :final meta,
        :final alt,
        :final control,
        character: final c,
      ) =>
        (meta, c.toUpperCase() == c && c.toLowerCase() != c, alt, control),
      _ => (false, false, false, false)
    };

    StringBuffer buffer = StringBuffer();
    if (meta) {
      //Platform operating system is not available in the web platform
      if (!kIsWeb && Platform.isMacOS) {
        buffer.write('⌘');
      } else {
        buffer.write('meta ');
      }
    }
    if (shift) {
      if (kIsWeb) {
        buffer.write('shift ');
      } else {
        buffer.write('⇧');
      }
    }
    if (control) {
      if (!kIsWeb && Platform.isMacOS) {
        buffer.write('⌃');
      } else {
        buffer.write('ctrl ');
      }
    }
    if (alt) {
      if (!kIsWeb && Platform.isMacOS) {
        buffer.write('⌥');
      } else {
        buffer.write('alt ');
      }
    }
    if (kIsWeb || !Platform.isMacOS) {
      return buffer.toString().trimRight();
    } else {
      return buffer.toString();
    }
  }

  Intention? _findMatch(RawKeyEvent event) {
    for (final MapEntry(:key, value: intent) in widget.bindings.entries) {
      if (ShortcutActivator.isActivatedBy(key.activator, event)) {
        return intent;
      }
    }
    return null;
  }

  static const double horizontalMargin = 16.0;

  Map<String, List<Shortcut>> _getBindingsMap() =>
      widget.bindings.keys.fold<Map<String, List<Shortcut>>>(
          {},
          (categories, shortcut) => {
                shortcut.category: (categories[shortcut.category] ?? [])
                  ..add(shortcut),
                ...categories
              });

  OverlayEntry _buildCategoryOverlay() {
    final ThemeData theme = Theme.of(context);
    TextStyle? bodyText =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
    TextStyle _categoryTextStyle =
        bodyText ?? const TextStyle().copyWith(fontWeight: FontWeight.bold);

    Map<String, List<Shortcut>> map = _getBindingsMap();
    int length = map.length + widget.bindings.length;

    final MediaQueryData media = MediaQuery.of(context);
    Size size = media.size;
    List<List<DataCell>> tableRows = [];
    for (int k = 0; k < length; k++) {
      tableRows.add(<DataCell>[]);
    }

    List<Widget> rows = [];
    for (String category in map.keys) {
      Container header = Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 2.0)),
          ),
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            category,
            style: _categoryTextStyle,
          ));
      rows.add(header);

      List<Shortcut> actions = map[category]!;
      Widget table = _getTableForActions(actions);
      rows.add(table);
    }
    Widget dataTable = SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: ListView(
        shrinkWrap: true,
        children: rows,
      ),
    );

    return OverlayEntry(builder: (context) {
      return Positioned(
        child: GestureDetector(
          onTap: () {
            _hideOverlay();
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(horizontalMargin),
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(color: Colors.white),
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  alignment: Alignment.center,
                  child: dataTable,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _getTableForActions(List<Shortcut> actions) {
    int colCount = widget.columnCount;
    final ThemeData theme = Theme.of(context);
    TextStyle _textStyle =
        widget.textStyle ?? theme.textTheme.labelSmall ?? defaultTextStyle;
    TextStyle _altTextStyle = _textStyle.copyWith(fontWeight: FontWeight.bold);
    Color background = widget.backgroundColor ?? theme.cardColor;
    Color textColor = _textStyle.color ?? defaultTextColor;

    List<DataColumn> columns = [];
    for (int k = 0; k < colCount; k++) {
      columns.add(const DataColumn(label: Text('d')));
      columns.add(const DataColumn(label: Text('m'), numeric: true));
      columns.add(const DataColumn(label: Text('k')));
    }

    int rowCount = (actions.length / colCount).ceil();
    int fullRows = actions.length ~/ colCount;

    List<List<DataCell>> tableRows = [];
    for (int k = 0; k < rowCount; k++) {
      tableRows.add(<DataCell>[]);
    }

    for (int k = 0; k < fullRows; k++) {
      List<DataCell> dataRow = tableRows[k];
      for (int t = 0; t < colCount; t++) {
        Shortcut shortcut = actions[k * colCount + t];
        dataRow.addAll(_getDataRow(
            shortcut, _textStyle, _altTextStyle, background, textColor));
      }
    }
    if (actions.length % colCount != 0) {
      for (int k = fullRows * colCount; k < actions.length; k++) {
        Shortcut shortcut = actions[k];
        tableRows[k].addAll(_getDataRow(
            shortcut, _textStyle, _altTextStyle, background, textColor));
      }
      for (int k = actions.length; k < rowCount * colCount; k++) {
        tableRows[k].add(DataCell.empty);
        tableRows[k].add(DataCell.empty);
        tableRows[k].add(DataCell.empty);
      }
    }
    List<DataRow> rows = [];
    for (List<DataCell> cells in tableRows) {
      rows.add(DataRow(cells: cells));
    }

    ThemeData data = Theme.of(context);
    Color dividerColor =
        widget.showLines ? data.dividerColor : Colors.transparent;
    return Theme(
      data: data.copyWith(dividerColor: dividerColor),
      child: DataTable(
        columns: columns,
        rows: rows,
        columnSpacing: 2,
        dividerThickness: 1,
        dataRowMinHeight: 4 + (_textStyle.fontSize ?? 12.0),
        dataRowMaxHeight: 18 + (_textStyle.fontSize ?? 12.0),
        headingRowHeight: 0,
      ),
    );
  }

  List<DataCell> _getDataRow(
    Shortcut shortcut,
    TextStyle _textStyle,
    TextStyle _altTextStyle,
    Color background,
    Color textColor,
  ) {
    List<DataCell> dataRow = [];
    String modifiers = _getModifiers(shortcut.activator);
    dataRow.add(DataCell(Text(
      shortcut.description ?? "",
      overflow: TextOverflow.ellipsis,
      style: _textStyle,
    )));
    dataRow.add(modifiers.isNotEmpty
        ? DataCell(_getBubble(modifiers, textColor, background, _altTextStyle))
        : DataCell.empty);
    dataRow.add(DataCell(
      _getAltText(shortcut.label, _altTextStyle),
    ));
    return dataRow;
  }

  OverlayEntry _buildOverlay() {
    final ThemeData themeData = Theme.of(context);
    TextStyle _textStyle =
        widget.textStyle ?? themeData.textTheme.labelSmall ?? defaultTextStyle;
    Color background = widget.backgroundColor ?? themeData.cardColor;
    Color textColor = _textStyle.color ?? defaultTextColor;

    final MediaQueryData media = MediaQuery.of(context);
    Size size = media.size;
    int length = widget.bindings.length;

    int rowCount = (length / widget.columnCount).ceil();
    List<List<DataCell>> tableRows = [];
    for (int k = 0; k < rowCount; k++) {
      tableRows.add(<DataCell>[]);
    }
    List<DataColumn> columns = [];
    for (int k = 0; k < widget.columnCount; k++) {
      columns.add(const DataColumn(label: Text('d')));
      columns.add(const DataColumn(label: Text('m'), numeric: true));
      columns.add(const DataColumn(label: Text('k')));
    }
    int fullRows = length ~/ widget.columnCount;
    for (int k = 0; k < fullRows; k++) {
      List<DataCell> dataRow = tableRows[k];
      for (int t = 0; t < widget.columnCount; t++) {
        Shortcut shortcut =
            widget.bindings.keys.toList()[k * widget.columnCount + t];
        String modifiers = _getModifiers(shortcut.activator);

        dataRow.add(
          DataCell(
            Text(
              shortcut.description ?? "",
              overflow: TextOverflow.ellipsis,
              style: _textStyle,
            ),
          ),
        );
        dataRow.add(modifiers.isNotEmpty
            ? DataCell(_getBubble(modifiers, textColor, background, _textStyle,
                invert: true))
            : DataCell.empty);
        dataRow.add(DataCell(
            _getBubble(shortcut.label, textColor, background, _textStyle)));
      }
    }
    if (widget.bindings.length % widget.columnCount != 0) {
      List<DataCell> dataRow = tableRows[fullRows];
      for (int k = fullRows * widget.columnCount;
          k < widget.bindings.length;
          k++) {
        Shortcut shortcut = widget.bindings.keys.toList()[k];
        String modifiers = _getModifiers(shortcut.activator);
        dataRow.add(DataCell(Text(
          shortcut.description ?? "",
          overflow: TextOverflow.ellipsis,
          style: _textStyle,
        )));
        dataRow.add(modifiers.isNotEmpty
            ? DataCell(_getBubble(modifiers, textColor, background, _textStyle))
            : DataCell.empty);
        dataRow.add(DataCell(_getBubble(
            shortcut.label, textColor, background, _textStyle,
            invert: true)));
      }
      for (int k = widget.bindings.length;
          k < rowCount * widget.columnCount;
          k++) {
        dataRow.add(DataCell.empty);
        dataRow.add(DataCell.empty);
        dataRow.add(DataCell.empty);
      }
    }
    List<DataRow> rows = [];
    for (List<DataCell> cells in tableRows) {
      rows.add(DataRow(
        cells: cells,
      ));
    }

    Color dividerColor =
        widget.showLines ? themeData.dividerColor : Colors.transparent;
    Widget dataTable = Theme(
        data: Theme.of(context).copyWith(dividerColor: dividerColor),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 2,
            dividerThickness: 1,
            columns: columns,
            rows: rows,
            dataRowMinHeight: 4 + (_textStyle.fontSize ?? 12.0),
            dataRowMaxHeight: 20 + (_textStyle.fontSize ?? 12.0),
            headingRowHeight: 0,
          ),
        ));

    Widget grid = Container(
      alignment: Alignment.center,
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          color: background,
          border: Border.all(color: background, width: 12),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: shadow, blurRadius: 30, spreadRadius: 1)
          ]),
      child: (widget.helpText != null)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  Flexible(
                      child: Markdown(
                    shrinkWrap: true,
                    data: widget.helpText!,
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(fontWeight: FontWeight.bold),
                      h1Align: WrapAlignment.center,
                    ),
                  )),
                  const Divider(height: 0.5, thickness: 0.5),
                  const SizedBox(
                    height: 18,
                  ),
                  dataTable,
                ])
          : dataTable,
    );

    return OverlayEntry(builder: (context) {
      return Positioned(
          child: GestureDetector(
        onTap: () {
          _hideOverlay();
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(horizontalMargin),
          width: size.width,
          // - padding.left - padding.right - 40,
          height: size.height,
          // - padding.top - padding.bottom - 40,
          decoration: const BoxDecoration(
            color: Colors.black12,
          ),
          child: Material(
              color: Colors.transparent,
              child: Center(
                  child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                alignment: Alignment.center,
                child: grid,
              ))),
        ),
      ));
    });
  }

  ///Returns the keyboard widget on desktop platforms. It does not
  ///provide shortcuts on IOS or Android
  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: true,
      descendantsAreFocusable: true,
      skipTraversal: false,
      focusNode: _focusNode,
      autofocus: false, //widget.hasFocus,
      onKey: (FocusNode node, RawKeyEvent event) {
        if (event.runtimeType == RawKeyDownEvent && node.hasPrimaryFocus) {
          if (!showingOverlay &&
              ShortcutActivator.isActivatedBy(widget.showHelpShortcut, event)) {
            toggleOverlay();
            return KeyEventResult.handled;
          } else if (showingOverlay &&
              ShortcutActivator.isActivatedBy(widget.hideHelpShortcut, event)) {
            _hideOverlay();
            return KeyEventResult.handled;
          } else {
            Intention? intent = _findMatch(event);
            if (intent != null) {
              debugPrint("Found intent: $intent");
              IntentManager.instance
                  .getHandlers(intent)
                  .forEach((handler) => handler());
              return KeyEventResult.handled;
            } else {
              return KeyEventResult.ignored;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: FocusTraversalGroup(child: widget.child),
    );
  }

  void _showOverlay() {
    setState(() {
      _overlayEntry =
          widget.groupByCategory ? _buildCategoryOverlay() : _buildOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    });
  }

  bool get showingOverlay => _overlayEntry != null;

  void toggleOverlay() => showingOverlay ? _hideOverlay() : _showOverlay();

  void _hideOverlay() {
    setState(() {
      _overlayEntry?.remove();
      if (widget.callbackOnHide != null) {
        widget.callbackOnHide!();
      }
      _overlayEntry = null;
    });
  }
}

///A combination of a [LogicalKeyboardKey] (e.g., control-shift-A), a description
///of what action that keystroke should trigger (e.g., "select all text"),
///and a callback method to be invoked when that keystroke is pressed. Optionally
///includes a category header for the shortcut.
@immutable
class Shortcut {
  final ShortcutActivator activator;
  final String? description;
  final String category;

  /// Creates a KeystrokeRep with the given LogicalKeyboardKey [keyStroke],
  /// [description] and [callback] method. Includes optional bool values (defaulting
  /// to false) for key modifiers for meta [isMetaPressed], shift [isShiftPressed],
  /// alt [isAltPressed]
  const Shortcut({
    required this.activator,
    this.category = "",
    this.description,
  });

  String get label {
    String logicalKeyToLabel(LogicalKeyboardKey key) {
      String label = key.keyLabel;
      if (key == LogicalKeyboardKey.arrowRight) {
        if (kIsWeb) {
          label = 'arrow right';
        } else {
          label = '→';
        }
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        if (kIsWeb) {
          label = 'arrow left';
        } else {
          label = '←';
        }
      } else if (key == LogicalKeyboardKey.arrowUp) {
        if (kIsWeb) {
          label = 'arrow up';
        } else {
          label = '↑';
        }
      } else if (key == LogicalKeyboardKey.arrowDown) {
        if (kIsWeb) {
          label = 'arrow down';
        } else {
          label = '↓';
        }
      } else if (key == LogicalKeyboardKey.delete) {
        if (kIsWeb) {
          label = 'delete';
        } else {
          label = '\u232B';
        }
      }
      // else if (key == LogicalKeyboardKey.enter) {
      //   if (kIsWeb) {
      //     label = 'enter';
      //   }
      //   else {
      //     label = '\u2B90';
      //   }
      // }
      return label;
    }

    final activator = this.activator;
    if (activator is CharacterActivator) return activator.character;
    if (activator is LogicalKeySet) {
      return activator.keys.map((key) => logicalKeyToLabel(key)).join(" + ");
    }
    if (activator is SingleActivator) {
      return logicalKeyToLabel(activator.trigger);
    } else {
      return activator.debugDescribeKeys();
    }
  }
}
