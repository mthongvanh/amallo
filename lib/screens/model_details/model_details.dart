import 'package:flutter/material.dart';
import 'package:amallo/widgets/loading.dart';
import 'package:ollama_dart/ollama_dart.dart';

import 'model_details_view_model.dart';

class ModelDetails extends StatefulWidget {
  static const routeName = 'modelDetails';

  final String modelTag;

  const ModelDetails({super.key, required this.modelTag});

  @override
  State<ModelDetails> createState() => _ModelDetailsState();
}

class _ModelDetailsState extends State<ModelDetails> {
  final ModelDetailsViewModel _viewModel = ModelDetailsViewModel();

  @override
  void initState() {
    _viewModel.init(widget.modelTag);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: header(),
          ),
          Expanded(
            child: ListenableBuilder(
                listenable: _viewModel.model,
                builder: (ctx, _) {
                  ModelInfo? model = _viewModel.model.value;
                  if (model == null) {
                    return const Center(
                      child: LoadingWidget(
                        dimension: 100,
                      ),
                    );
                  }
                  //  else if (model.isEmpty) {
                  //   return const Center(
                  //     child: Text('No Models Found'),
                  //   );
                  // }
                  return LayoutBuilder(builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            buildTextRow('Modelfile: ', model.modelfile ?? ''),
                            const SizedBox(
                              height: 32,
                            ),
                            buildTextRow('Template: ', model.template ?? ''),
                            const SizedBox(
                              height: 32,
                            ),
                            buildTextRow(
                                'Parameters: ', model.parameters ?? ''),
                            const SizedBox(
                              height: 32,
                            ),
                            buildTextRow('License: ', model.license ?? ''),
                          ],
                        ),
                      ),
                    );
                  });
                }),
          ),
        ],
      ),
    );
  }

  Row buildTextRow(String label, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 1,
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ],
    );
  }

  Widget header() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(widget.modelTag,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                )),
      ),
    );
  }
}
