import 'dart:async';

import 'package:amallo/data/enums/ollama_models.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/settings.dart';

class SettingService {
  static SettingService? instance;

  SettingService._();

  factory SettingService() => instance ??= SettingService._();

  late Box _box;

  final List listeners = [];

  final String boxName = 'Settings';

  init() async {
    _box = await Hive.openBox(boxName);
  }

  Box get box => _box;

  Future put(key, value) async {
    if (!_box.isOpen) {
      _box = await Hive.openBox(boxName);
    }

    _box.put(key, value);
  }

  FutureOr get(key, {defaultValue}) async {
    if (!_box.isOpen) {
      _box = await Hive.openBox(boxName);
    }

    return _box.get(key, defaultValue: defaultValue);
  }

  Stream<BoxEvent> watch(key) {
    return _box.watch(key: key);
  }

  ///
  /// Convenience getters
  ///

  /// Language model currently selected
  Future<String> currentLanguageModel() async {
    return _box.get(
      Settings.selectedLocalModelIdentifier,
      defaultValue: OllamaModels.codellama34b.value,
    );
  }

  Future<String?> serverAddress() async {
    return _box.get(
      Settings.serverAddress,
    );
  }
}
