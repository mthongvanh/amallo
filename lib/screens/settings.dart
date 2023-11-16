import 'package:flutter/material.dart';
import 'package:amallo/data/models/settings.dart';
import 'package:amallo/data/models/view_model_property.dart';
import 'package:amallo/extensions/colors.dart';
import 'package:amallo/screens/update_setting.dart';
import 'package:amallo/services/settings_service.dart';

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
                Column(
                  children: [
                    const Text('Use SSL/TLS'),
                    sslSwitch(),
                  ],
                ),
              ],
            ),
            serverPort(),
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

  Widget serverPort() => buildSetting(
        settingDisplayName: 'Server Port',
        listenable: viewModel.serverPort,
        settingKey: Settings.serverPort,
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

  Widget sslSwitch() {
    return ListenableBuilder(
        listenable: viewModel.useSSL,
        builder: (context, _) {
          return Switch(
            // This bool value toggles the switch.
            value: viewModel.useSSL.value ?? false,
            activeColor: AppColors.turquoise,
            onChanged: (bool value) {
              viewModel.useSSL.value = value;
              SettingService().put(Settings.useTLSSSL, value);
            },
          );
        });
  }
}

class SettingPageViewModel {
  init() {
    serverAddress.bind(Settings.serverAddress);
    serverPort.bind(Settings.serverPort);
    modelDefault.bind(Settings.defaultLocalModelIdentifier);
    useSSL.bind(Settings.useTLSSSL);
  }

  final ViewModelProperty<String> serverAddress =
      ViewModelProperty<String>('localhost');

  final ViewModelProperty<String> serverPort =
      ViewModelProperty<String>('11434');

  final ViewModelProperty<String?> modelDefault = ViewModelProperty<String?>();

  final ViewModelProperty<bool?> useSSL = ViewModelProperty<bool?>();
}
