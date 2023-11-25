import 'package:amallo/services/remote_data_service.dart';
import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';

import '../data/models/pull_model_task.dart';

class DownloadModelListItem extends StatefulWidget {
  final PullModelTask _pullModelTask;

  const DownloadModelListItem(this._pullModelTask, {super.key});

  @override
  State<DownloadModelListItem> createState() => _DownloadModelListItemState();
}

class _DownloadModelListItemState extends State<DownloadModelListItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget._pullModelTask.request.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(
          height: 8,
        ),
        buildDownloadStatus(context, widget._pullModelTask.done),
      ],
    );
  }

  Widget buildDownloadStatus(BuildContext context, bool completed) {
    return widget._pullModelTask.done
        ? buildCompletedView(context)
        : buildProgressView(context);
  }

  buildCompletedView(BuildContext context) {
    return widget._pullModelTask.error?.isNotEmpty == true
        ? buildErroView(context)
        : buildSuccessView();
  }

  buildSuccessView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(Icons.check_circle, color: Colors.green),
        const Padding(
          padding: EdgeInsets.only(
            left: 8,
          ),
          child: Text(
            'Completed',
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: _dismiss,
          child: const Text(
            'Dismiss',
          ),
        ),
      ],
    );
  }

  _dismiss() {
    ModelTransferService().removeTask(
      widget._pullModelTask,
    );
  }

  _retry(BuildContext context) {
    try {
      ModelTransferService().retry(widget._pullModelTask);
      setState(() {});
    } catch (e) {
      ScaffoldMessengerState? sm = ScaffoldMessenger.maybeOf(context);
      sm?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error),
              Text(e.toString()),
            ],
          ),
        ),
      );
    }
  }

  buildErroView(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(
          Icons.error_rounded,
          color: Colors.red,
        ),
        Expanded(
          // flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8,
            ),
            child: Text(
              'Error: ${widget._pullModelTask.error ?? 'Uh oh. Failed to download the model.'}',
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            _retry(context);
          },
          icon: const Icon(
            Icons.refresh_rounded,
          ),
        ),
        IconButton(
          onPressed: _dismiss,
          icon: const Icon(
            Icons.delete,
          ),
        ),
      ],
    );
  }

  buildProgressView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: StreamBuilder(
          stream: widget._pullModelTask.stream,
          builder: (ctx, AsyncSnapshot<PullModelResponse> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return buildCompletedView(context);
            } else {
              double progress = 0;
              if (snapshot.hasData) {
                progress = (snapshot.data?.completed ?? 0) /
                    (snapshot.data?.total ?? 1);
              }
              return Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    "${(snapshot.data?.completed ?? 0).toGB()} / ${(snapshot.data?.total ?? 0).toGB()} GB",
                  ),
                ],
              );
            }
          }),
    );
  }
}

extension Size on int {
  String toGB() => (this / 1024e6).toStringAsFixed(2);
}
