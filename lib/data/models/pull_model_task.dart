import 'package:amallo/screens/local_model_list.dart';
import 'package:ollama_dart/ollama_dart.dart';

import '../../services/remote_data_service.dart';

class PullModelTask {
  PullModelTask._(this.modelName, this._modelService);

  factory PullModelTask({
    required String modelName,
    required LocalModelService modelService,
    ProgressHandler? handler,
  }) {
    var pmt = PullModelTask._(modelName, modelService);
    if (handler != null) {
      pmt.addListener(handler);
    }
    return pmt;
  }

  // final PullModelRequest request;
  final String modelName;
  final LocalModelService _modelService;

  late DateTime _createdOn;
  DateTime get createdOn => _createdOn;

  bool get done => _done;
  bool _done = false;

  String? _errorMessage;
  String? get error => _errorMessage;

  int _completed = 0;
  int get completed => _completed;

  int? _total;
  int get total => _total ?? 1;

  late Stream<PullModelResponse> stream;

  final List<ProgressHandler> listeners = [];

  start() async {
    try {
      stream = await _modelService.pullModelStream(
        modelName,
      );
      stream = stream.asBroadcastStream();

      stream.listen(
        (event) {
          _completed = event.completed ?? 0;
          _total = event.total ?? 1;
          // _status = event.status.toString();

          // debugPrint('PullModelResponse status for ${request.name}: $status');

          for (var element in listeners) {
            element.call(
              _completed,
              _total,
              event.status.toString(),
            );
          }
        },
        onError: (e) {
          _errorMessage = e.toString().isNotEmpty
              ? e.toString()
              : 'An error occurred. Please check your network connection.';
        },
        onDone: () {
          _done = done;
          _cleanup(true);
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  addListener(ProgressHandler onData) {
    if (!listeners.contains(onData)) {
      listeners.add(onData);
    }
  }

  _cleanup(done) {
    listeners.removeWhere((element) => true);
  }
}
