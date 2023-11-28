import 'dart:async';

import 'package:amallo/services/settings_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ViewModelProperty<T> extends ChangeNotifier {
  T? _value;

  T? _defaultValue;

  Stream<BoxEvent>? _stream;

  ViewModelProperty._(this._defaultValue);

  factory ViewModelProperty([T? defaultValue]) {
    return ViewModelProperty._(defaultValue)..value = defaultValue;
  }

  set value(newValue) {
    if (newValue != _value) {
      _value = newValue;
      notifyListeners();
    }
  }

  T? get value => _value;

  bind(key) async {
    var v = await SettingService().get(key);
    value = v;

    _stream = SettingService().watch(key);
    _stream?.listen((BoxEvent event) {
      if (event.value != value) {
        value = event.value;
      }
    });
  }
}
