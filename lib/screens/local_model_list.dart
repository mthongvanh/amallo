import 'dart:async';

import 'package:amallo/data/models/view_model_property.dart';
import 'package:flutter/material.dart';
import 'package:amallo/widgets/loading.dart';
import 'package:ollama_dart/ollama_dart.dart';

class LocalModelList extends StatefulWidget {
  static const routeName = 'LocalModelList';

  final Future Function(LocalModel?)? onSelectItem;

  const LocalModelList({super.key, this.onSelectItem});

  @override
  State<LocalModelList> createState() => _LocalModelListState();
}

class _LocalModelListState extends State<LocalModelList> {
  final LocalModelListViewModel _viewModel = LocalModelListViewModel();

  @override
  void initState() {
    _viewModel.init();
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
              listenable: _viewModel.localModels,
              builder: (ctx, _) {
                List<LocalModel?>? models = _viewModel.localModels.value;
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
                    itemCount: _viewModel.localModels.value?.length ?? 0,
                    itemBuilder: (ctx, index) {
                      LocalModel? m = models[index];
                      return GestureDetector(
                        onTap: () {
                          widget.onSelectItem?.call(m);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text(
                                m?.name ?? 'Unknown model name',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    m?.sizeOnDisk ?? 'Unknown size',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 24.0),
                                    child: IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return Material(
                                                color: Colors.transparent,
                                                child: AlertDialog.adaptive(
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          'To make a copy of ${m?.name ?? 'this model'}, please enter a name without spaces or special characters.',
                                                        ),
                                                      ),
                                                      // TextField(
                                                      //   controller: _viewModel
                                                      //       .sourceController,
                                                      //   decoration:
                                                      //       const InputDecoration(
                                                      //     label: Text(
                                                      //       'Source Model',
                                                      //     ),
                                                      //   ),
                                                      //   smartDashesType:
                                                      //       SmartDashesType
                                                      //           .disabled,
                                                      // ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: TextField(
                                                          controller: _viewModel
                                                              .destinationController,
                                                          decoration:
                                                              const InputDecoration(
                                                            label: Text(
                                                              'Copy Name',
                                                            ),
                                                          ),
                                                          smartDashesType:
                                                              SmartDashesType
                                                                  .disabled,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(ctx,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop();
                                                          _performCopy(
                                                            ctx,
                                                            source: m?.name,
                                                            destination: _viewModel
                                                                .destinationController
                                                                .text,
                                                          );

                                                        },
                                                        child:
                                                            const Text('Yes')),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(ctx,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('No')),
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                      icon: const Icon(
                                        Icons.copy,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (ctx) {
                                            return AlertDialog.adaptive(
                                              content: Text(
                                                  'Are you sure that you want to delete ${m?.name ?? 'this model'}?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(ctx,
                                                              rootNavigator:
                                                                  true)
                                                          .pop();
                                                      _performDelete(
                                                        ctx,
                                                        modelName: m?.name,
                                                      );
                                                    },
                                                    child: const Text('Yes')),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(ctx,
                                                              rootNavigator:
                                                                  true)
                                                          .pop();
                                                    },
                                                    child: const Text('No')),
                                              ],
                                            );
                                          });
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 0.5,
                              color: Colors.grey.withOpacity(0.35),
                            ),
                          ],
                        ),
                      );
                    });
              }),
        ),
      ],
    );
  }

  void _performDelete(BuildContext localContext, {String? modelName}) {
    ScaffoldMessengerState? messenger = ScaffoldMessenger.of(localContext);
    try {
      _viewModel.delete(modelName).then((value) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text("${modelName ?? 'Model'} has been deleted"),
            ),
          );
        }
      });
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  void _performCopy(BuildContext localContext,
      {String? source, String? destination}) {
    ScaffoldMessengerState? messenger = ScaffoldMessenger.of(localContext);
    try {
      _viewModel.copy(source, destination).then((value) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                "Created a new model: $destination has been created from $source",
              ),
            ),
          );
        }
      });
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  showAlertDialog(context, alert) {
    showDialog(
        context: context,
        builder: (ctx) {
          return alert;
        });
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

  final TextEditingController sourceController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  LocalModelListViewModel();

  init() {
    getTags();
  }

  Future<void> getTags() async {
    try {
      List<LocalModel?>? models = await _service.getTags();
      localModels.value = models;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> delete(String? modelName) async {
    if (modelName == null || modelName.isEmpty) {
      throw Exception('model name is required');
    }

    try {
      await _service.deleteModel(modelName);
      await getTags();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> copy(String? source, String? destination) async {
    if ([source, destination]
        .where((element) => element == null || element.isEmpty)
        .isNotEmpty) {
      throw Exception("A source and destination model are required");
    } else if (source!.trim().toLowerCase() ==
        destination!.trim().toLowerCase()) {
      throw Exception("The names must be different");
    }

    try {
      await _service.copyModel(source, destination: destination);
      await getTags();
      sourceController.text = '';
      destinationController.text = '';
    } catch (e) {
      rethrow;
    }
  }
}

class LocalModelService {
  Future<List<LocalModel?>?> getTags() async {
    List<LocalModel?>? data;
    try {
      ModelsResponse result = await OllamaClient().listModels();
      if (result.models?.isNotEmpty ?? false) {
        data = result.models!.map((Model tagModel) {
          return LocalModel(
            tagModel.name ?? '',
            '',
            tagModel.size ?? 0,
            tagModel.modifiedAt ?? '',
          );
        }).toList();
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
    return data;
  }

  Future deleteModel(String modelName) async {
    try {
      await OllamaClient()
          .deleteModel(request: DeleteModelRequest(name: modelName));
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future copyModel(String source, {required String destination}) async {
    try {
      await OllamaClient().copyModel(
          request: CopyModelRequest(
        source: source,
        destination: destination,
      ));
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
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

  String get sizeOnDisk => "${(size / 1024e6).toStringAsFixed(1)} GB";
}
