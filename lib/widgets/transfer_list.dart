import 'package:flutter/material.dart';

import '../data/models/pull_model_task.dart';
import '../services/remote_data_service.dart';
import 'download_model_list_item.dart';
import 'loading.dart';

class TransferList extends StatelessWidget {
  const TransferList(this.showDownloads, {super.key});

  final bool showDownloads;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ModelTransferService().downloads,
        builder: (ctx, downloads, _) {
          List<PullModelTask> transfers = downloads;
          return transfers.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: LoadingWidget(
                    dimension: 200,
                    assetName: LottieAnimations.chilipaca.path,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.downloading_outlined,
                          ),
                        ),
                        Text(
                          showDownloads ? 'Downloads' : 'Uploads',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: transfers.length,
                      itemBuilder: (ctx, index) {
                        return DownloadModelListItem(transfers[index]);
                      },
                      separatorBuilder: (_, __) => const Divider(
                        height: 8,
                        thickness: 1,
                        color: Colors.white30,
                      ),
                    )
                  ],
                );
        });
  }
}
