import 'dart:async';

import 'package:amallo/data/models/view_model_property.dart';
import 'package:amallo/screens/add_model/add_model.dart';
import 'package:flutter/material.dart';
import 'package:amallo/widgets/loading.dart';
import 'package:ollama_dart/ollama_dart.dart';

class LocalModelList extends StatefulWidget {
  static const routeName = 'LocalModelList';

  final bool editMode;

  final Future Function(LocalModel?)? onSelectItem;

  const LocalModelList({
    super.key,
    this.onSelectItem,
    required this.editMode,
  });

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
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Try adding a model!'),
                      SizedBox(
                        height: 32,
                      ),
                      Image(
                        height: 250,
                        width: 250,
                        image: AssetImage(
                          'assets/images/cyborg-llama.png',
                        ),
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    return Future.delayed(const Duration(seconds: 1), () {
                      _viewModel.getTags();
                    });
                  },
                  child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                                trailing: buildTrailing(m),
                              ),
                              Divider(
                                height: 0.5,
                                color: Colors.grey.withOpacity(0.35),
                              ),
                            ],
                          ),
                        );
                      }),
                );
              }),
        ),
      ],
    );
  }

  buildTrailing(LocalModel? m) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          m?.sizeOnDisk ?? 'Unknown size',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (widget.editMode)
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: _viewModel.destinationController,
                                  decoration: const InputDecoration(
                                    label: Text(
                                      'Copy Name',
                                    ),
                                  ),
                                  smartDashesType: SmartDashesType.disabled,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(ctx, rootNavigator: true).pop();
                                  _performCopy(
                                    ctx,
                                    source: m?.name,
                                    destination:
                                        _viewModel.destinationController.text,
                                  );
                                },
                                child: const Text('Yes')),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(ctx, rootNavigator: true).pop();
                                },
                                child: const Text('No')),
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
        if (widget.editMode)
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
                              Navigator.of(ctx, rootNavigator: true).pop();
                              _performDelete(
                                ctx,
                                modelName: m?.name,
                              );
                            },
                            child: const Text('Yes')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(ctx, rootNavigator: true).pop();
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
      child: AppBar(
        // padding: const EdgeInsets.all(16.0),
        title: const Text(
          'Models',
        ),
        backgroundColor: Colors.transparent,
        actions: widget.editMode
            ? [
                _addNew(),
              ]
            : null,
      ),
    );
  }

  _addNew() {
    return IconButton(
      onPressed: _presentCreateNewModal,
      icon: const Icon(Icons.add_circle_outline),
    );
  }

  _presentCreateNewModal() async {
    Navigator.of(context)
        .pushNamed(
          AddModelScreen.routeName,
        )
        .then(
          (value) => _viewModel.getTags(),
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

class ModelfileParameters {
  ModelfileParameters({
    this.mirostat = 0,
    this.mirostatEta = 0.1,
    this.mirostatTau = 5.0,
    this.numCtx = 2048,
    this.numGqa,
    this.numGpu,
    this.numThread,
    this.repeatLastN = 64,
    this.repeatPenalty = 1.1,
    this.temperature = 0.8,
    this.seed = 0,
    this.stop,
    this.tfsZ = 1,
    this.numPredict = 128,
    this.topK = 40,
    this.topP = 0.9,
  });

  ///Enable Mirostat sampling for controlling perplexity. (default: 0, 0 = disabled, 1 = Mirostat, 2 = Mirostat 2.0)
  final int? mirostat;

  ///Influences how quickly the algorithm responds to feedback from the generated text. A lower learning rate will result in slower adjustments, while a higher learning rate will make the algorithm more responsive. (Default: 0.1)
  final double? mirostatEta;

  ///Controls the balance between coherence and diversity of the output. A lower value will result in more focused and coherent text. (Default: 5.0)
  final double? mirostatTau;

  ///Sets the size of the context window used to generate the next token. (Default: 2048)
  final int? numCtx;

  ///The number of GQA groups in the transformer layer. Required for some models, for example it is 8 for llama2:70b
  final int? numGqa;

  ///The number of layers to send to the GPU(s). On macOS it defaults to 1 to enable metal support, 0 to disable.
  final int? numGpu;

  ///Sets the number of threads to use during computation. By default, Ollama will detect this for optimal performance. It is recommended to set this value to the number of physical CPU cores your system has (as opposed to the logical number of cores).
  final int? numThread;

  ///Sets how far back for the model to look back to prevent repetition. (Default: 64, 0 = disabled, -1 = num_ctx)
  final int? repeatLastN;

  ///Sets how strongly to penalize repetitions. A higher value (e.g., 1.5) will penalize repetitions more strongly, while a lower value (e.g., 0.9) will be more lenient. (Default: 1.1)
  final double? repeatPenalty;

  ///The temperature of the model. Increasing the temperature will make the model answer more creatively. (Default: 0.8)
  final double? temperature;

  ///Sets the random number seed to use for generation. Setting this to a specific number will make the model generate the same text for the same prompt. (Default: 0)
  final int? seed;

  ///Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate `stop` parameters in a modelfile.
  final String? stop;

  ///Tail free sampling is used to reduce the impact of less probable tokens from the output. A higher value (e.g., 2.0) will reduce the impact more, while a value of 1.0 disables this setting. (default: 1)
  final double? tfsZ;

  ///Maximum number of tokens to predict when generating text. (Default: 128, -1 = infinite generation, -2 = fill context)
  final int? numPredict;

  ///Reduces the probability of generating nonsense. A higher value (e.g. 100) will give more diverse answers, while a lower value (e.g. 10) will be more conservative. (Default: 40)
  final int? topK;

  ///Works together with top-k. A higher value (e.g., 0.95) will lead to more diverse text, while a lower value (e.g., 0.5) will generate more focused and conservative text. (Default: 0.9)
  final double? topP;
}
