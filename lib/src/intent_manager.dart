import 'package:keymap/keymap.dart';
import 'package:quiver/collection.dart';

class IntentManager {
  final _handlers = SetMultimap<Intention, IntentHandler>();
  IntentManager._internalConstructor();

  static final instance = IntentManager._internalConstructor();

  Iterable<IntentHandler> getHandlers(Intention forIntent) =>
      _handlers[forIntent];

  void registerHandlers(Map<Intention, IntentHandler> toAdd) =>
      toAdd.forEach((intent, handler) => _handlers.add(intent, handler));

  void deregisterHandlers(Map<Intention, IntentHandler> toRemove) =>
      toRemove.forEach((intent, handler) => _handlers.remove(intent, handler));
}

typedef IntentHandler = void Function();
