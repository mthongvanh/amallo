import 'package:flutter/widgets.dart';
import 'package:ollama_dart/ollama_dart.dart';

import '../data/models/pull_model_task.dart';

typedef ProgressHandler = void Function(
    int? completed, int? total, String status);

enum TransfersSortType {
  ascending,
  descending,
}

class ModelTransferService {
  static ModelTransferService? instance;

  final OllamaClient _client;

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

  ModelTransferService._(this._client);

  factory ModelTransferService([OllamaClient? client]) {
    return instance ??= ModelTransferService._(client ?? OllamaClient());
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
        request: PullModelRequest(
          name: modelName,
        ),
        client: _client,
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
      if (downloadTask.request.name.toLowerCase() == modelName.toLowerCase()) {
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
