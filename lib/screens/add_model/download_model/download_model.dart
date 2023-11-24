import 'package:amallo/screens/add_model/download_model/download_model_view_model.dart';
import 'package:flutter/material.dart';

import '../../../widgets/transfer_list.dart';

class DownloadModelScreen extends StatefulWidget {
  static const routeName = 'downloadModel';

  const DownloadModelScreen({super.key});

  @override
  State<DownloadModelScreen> createState() => _DownloadModelScreenState();
}

class _DownloadModelScreenState extends State<DownloadModelScreen> {
  final DownloadModelViewModel _downloadModelViewModel =
      DownloadModelViewModel();

  @override
  void initState() {
    _downloadModelViewModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _downloadModelViewModel.downloadInstructions(),
          ),
          const SizedBox(
            height: 32,
          ),
          TextField(
            controller: _downloadModelViewModel.modelNameController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Model Tag Identifier (Example: llama2:7b)',
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.0,
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton(
            onPressed: () {
              try {
                _downloadModelViewModel.downloadModel(
                  _downloadModelViewModel.modelNameController.text,
                  onData: (completed, total, status) {
                    _downloadModelViewModel.updatedOn.value = DateTime.now();
                  },
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      e.toString(),
                    ),
                  ),
                );
              }
            },
            child: const Text('Download'),
          ),
          const SizedBox(
            height: 32,
          ),
          ListenableBuilder(
            listenable: _downloadModelViewModel.updatedOn,
            builder: (ctx, value) {
              return const TransferList(true);
            },
          ),
        ],
      ),
    );
  }
}
