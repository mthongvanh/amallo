import 'package:flutter/widgets.dart';

import '../data/models/view_model_property.dart';
import '../services/settings_service.dart';

class UpdateSettingViewModel {
  String? _settingKey;

  init(settingKey) {
    _settingKey = settingKey;
    setting.bind(settingKey);
  }

  final ViewModelProperty setting = ViewModelProperty();

  final TextEditingController textController = TextEditingController();

  save() async {
    if (textController.text.isNotEmpty) {
      await SettingService().put(_settingKey, textController.text);
    }
  }
}
