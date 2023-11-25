import 'package:ollama_dart/ollama_dart.dart';

import '../../services/remote_data_service.dart';

class PullModelTask {
  PullModelTask._(this.request, this._client);

  factory PullModelTask({
    required PullModelRequest request,
    required OllamaClient client,
    ProgressHandler? handler,
  }) {
    var pmt = PullModelTask._(request, client);
    if (handler != null) {
      pmt.addListener(handler);
    }
    return pmt;
  }

  final PullModelRequest request;
  final OllamaClient _client;

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

  start() {
    try {
      stream = _client
          .pullModelStream(
            request: request,
          )
          .asBroadcastStream();

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
