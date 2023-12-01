import 'package:flutter/material.dart';
import 'package:amallo/data/models/settings.dart';
import 'package:amallo/data/models/view_model_property.dart';
import 'package:amallo/screens/update_setting.dart';

import 'update_setting_view_model.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = 'settings';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingPageViewModel viewModel = SettingPageViewModel();

  @override
  void initState() {
    viewModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: serverAddress(),
                ),
              ],
            ),
            buildSetting<String>(
              settingDisplayName: 'Default Language Model',
              listenable: viewModel.modelDefault,
              settingKey: Settings.defaultLocalModelIdentifier,
              defaultValue: 'No Model Selected',
            ),
          ],
        ),
      ),
    );
  }

  Widget serverAddress() => buildSetting(
        settingDisplayName: 'Server Address',
        listenable: viewModel.serverAddress,
        settingKey: Settings.serverAddress,
      );

  Widget buildSetting<T>({
    required ViewModelProperty listenable,
    required String settingKey,
    required String settingDisplayName,
    T? defaultValue,
  }) =>
      ListenableBuilder(
          listenable: listenable,
          builder: (context, _) {
            T? settingValue = listenable.value ?? defaultValue;

            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) {
                  return UpdateSettingPage(
                    settingKey: settingKey,
                    settingDisplayName: settingDisplayName,
                    settingValue: settingValue,
                    viewModel: UpdateSettingViewModel(),
                  );
                }),
              ),
              child: ListTile(
                title: Text(settingDisplayName),
                subtitle: Text(settingValue as String? ?? ''),
              ),
            );
          });
}

class SettingPageViewModel {
  init() {
    serverAddress.bind(Settings.serverAddress);
    modelDefault.bind(Settings.defaultLocalModelIdentifier);
  }

  final ViewModelProperty<String> serverAddress =
      ViewModelProperty<String>('http://localhost:11434/api');

  final ViewModelProperty<String?> modelDefault = ViewModelProperty<String?>();
}
