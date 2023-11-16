import 'package:flutter/material.dart';

import 'update_setting_view_model.dart';

class UpdateSettingPage extends StatefulWidget {
  final String settingKey;
  final String settingDisplayName;
  final String? settingValue;

  final UpdateSettingViewModel viewModel;

  const UpdateSettingPage({
    super.key,
    required this.settingKey,
    required this.settingDisplayName,
    this.settingValue,
    required this.viewModel,
  });

  @override
  State<UpdateSettingPage> createState() => _UpdateSettingPageState();
}

class _UpdateSettingPageState extends State<UpdateSettingPage> {
  @override
  void initState() {
    widget.viewModel.init(widget.settingKey);
    widget.viewModel.textController.text = widget.settingValue ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(widget.settingDisplayName),
            ListenableBuilder(
                listenable: widget.viewModel.setting,
                builder: (context, _) {
                  return TextField(
                    controller: widget.viewModel.textController,
                    textAlign: TextAlign.center,
                  );
                }),
            const SizedBox(
              height: 50,
            ),
            OutlinedButton(
              onPressed: () {
                // save
                widget.viewModel.save();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
