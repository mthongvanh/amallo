import 'package:amallo/data/models/view_model_property.dart';
import 'package:amallo/screens/local_model_list.dart';
import 'package:amallo/services/remote_data_service.dart';
import 'package:flutter/material.dart';

import '../../../data/models/pull_model_task.dart';

class DownloadModelViewModel {
  init() {}

  TextEditingController modelNameController = TextEditingController();

  downloadInstructions() =>
      "Enter the model's tag below to begin downloading the model from the Ollama servers";

  ValueNotifier<List<PullModelTask>> get downloads =>
      ModelTransferService().downloads;

  final ViewModelProperty<DateTime> updatedOn =
      ViewModelProperty(DateTime.now());

  void downloadModel(String modelName, {ProgressHandler? onData}) {
    try {
      ModelTransferService(
        LocalModelService(),
      ).pull(
        modelName,
        progressHandler: onData,
      );
    } catch (e) {
      rethrow;
    }
  }
}
