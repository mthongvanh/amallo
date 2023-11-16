import 'dart:async';

import 'package:amallo/data/models/view_model_property.dart';
import 'package:flutter/material.dart';
import 'package:amallo/services/ollama_client.dart';
import 'package:amallo/services/settings_service.dart';
import 'package:amallo/widgets/loading.dart';

class LocalModelList extends StatefulWidget {
  final LocalModelListViewModel _viewModel = LocalModelListViewModel();

  final Future Function(LocalModel?)? onSelectItem;

  LocalModelList({super.key, this.onSelectItem});

  @override
  State<LocalModelList> createState() => _LocalModelListState();
}

class _LocalModelListState extends State<LocalModelList> {
  @override
  void initState() {
    widget._viewModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        header(),
        Expanded(
          child: ListenableBuilder(
              listenable: widget._viewModel.localModels,
              builder: (ctx, _) {
                List<LocalModel?>? models = widget._viewModel.localModels.value;
                if (models == null) {
                  return const Center(
                    child: LoadingWidget(
                      dimension: 100,
                    ),
                  );
                } else if (models.isEmpty) {
                  return const Center(
                    child: Text('No Models Found'),
                  );
                }
                return ListView.builder(
                    itemCount: widget._viewModel.localModels.value?.length ?? 0,
                    itemBuilder: (ctx, index) {
                      LocalModel? m = models[index];
                      return GestureDetector(
                        onTap: () {
                          widget.onSelectItem?.call(m);
                        },
                        child: ListTile(
                            title: Text(m?.name ?? 'Unknown model name')),
                      );
                    });
              }),
        ),
      ],
    );
  }

  Widget header() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Local Models',
            style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}

class LocalModelListViewModel {
  final localModels = ViewModelProperty<List<LocalModel?>>([]);
  final LocalModelService _service = LocalModelService();

  LocalModelListViewModel();

  init() {
    try {
      _service.getTags().then((value) => localModels.value = value);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class LocalModelService {
  Future<List<LocalModel?>?> getTags() async {
    List<LocalModel?>? data;
    try {
      final host = await SettingService().serverAddress();
      final port = await SettingService().serverPort();
      final useSSL = await SettingService().useTLSSSL();

      var d = await OllamaClient().getTags(
        host: host,
        port: port,
        requireSSL: useSSL,
      );
      data = d.map((value) => LocalModel.fromMap(value)).toList();
    } catch (e) {
      debugPrint(e.toString());
    }
    return data;
  }
}

class LocalModel {
  /// Name of the model: name followed by tag, e.g. "codellama:13b-instruct",
  String name;

  /// "2023-09-09T14:53:54.073649959+02:00",
  String modifiedAt;

  int size;

  /// "digest": "9a874ed1c05682a295220a627c471f635d1e5ab4260f4d55004ebce48da1fb19"
  String digest;

  LocalModel(
    this.name,
    this.digest,
    this.size,
    this.modifiedAt,
  );

  static LocalModel fromMap(map) {
    return LocalModel(
      map["name"] as String,
      map["modified_at"] as String,
      map["size"] as int,
      map["digest"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "modified_at": modifiedAt,
      "size": size,
      "digest": digest,
    };
  }
}
