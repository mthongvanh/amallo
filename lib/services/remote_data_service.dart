import 'package:amallo/screens/local_model_list.dart';
import 'package:flutter/widgets.dart';

import '../data/models/pull_model_task.dart';

typedef ProgressHandler = void Function(
    int? completed, int? total, String status);

enum TransfersSortType {
  ascending,
  descending,
}

class ModelTransferService {
  static ModelTransferService? instance;

  final LocalModelService _modelService;

  final List<PullModelTask> _downloads = [];

  ValueNotifier<List<PullModelTask>> downloads =
      ValueNotifier<List<PullModelTask>>([]);

  List<PullModelTask> sortDownloads({
    TransfersSortType? sortType = TransfersSortType.descending,
  }) {
    _downloads.sort((a, b) {
      if (sortType == TransfersSortType.descending) {
        return b.createdOn.compareTo(a.createdOn);
      } else {
        return a.createdOn.compareTo(b.createdOn);
      }
    });
    return _downloads;
  }

  ModelTransferService._(this._modelService);

  factory ModelTransferService([LocalModelService? modelService]) {
    return instance ??=
        ModelTransferService._(modelService ?? LocalModelService());
  }

  void pull(
    String modelName, {
    ProgressHandler? progressHandler,
  }) {
    try {
      if (downloading(modelName)) {
        throw Exception("Download is already in progress for $modelName");
      }

      PullModelTask task = PullModelTask(
        modelName: modelName,
        modelService: _modelService,
        handler: progressHandler,
      );
      _updateDownloads(task);
      task.start();
    } catch (e) {
      rethrow;
    }
  }

  retry(PullModelTask pullRequest) {
    try {
      pullRequest.start();
    } catch (e) {
      rethrow;
    }
  }

  bool downloading(String modelName) {
    for (var downloadTask in _downloads) {
      if (downloadTask.modelName.toLowerCase() == modelName.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  removeTask(task) {
    _downloads.remove(task);
    downloads.value = List.from(_downloads);
  }

  _updateDownloads(PullModelTask task) {
    _downloads.add(task);
    downloads.value = _downloads;
  }
}
