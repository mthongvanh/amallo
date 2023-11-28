import 'package:flutter/material.dart';

import '../../data/models/modelfile_parameter.dart';
import '../../data/models/modelfile_parameter_type.dart';
import '../../widgets/edit_modelfile_parameter_list_item.dart';
import 'add_modelfile_parameter_view_model.dart';

class AddModelfileParameter extends StatelessWidget {
  AddModelfileParameter(this.selectedParameters, {super.key});

  final _viewModel = AddModelfileParameterViewModel();
  final Map<ModelfileParameterType, dynamic> selectedParameters;

  @override
  Widget build(BuildContext context) {
    if (!_viewModel.initialized) {
      _viewModel.init(selectedParameters);
    }

    return Column(
      children: [
        header(context),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: ListenableBuilder(
                listenable: _viewModel.modelfileParameters,
                builder: (ctx, _) {
                  if (_viewModel.modelfileParameters.value?.isNotEmpty ==
                      false) {
                    return const SizedBox();
                  }
                  return ListView.builder(
                    itemBuilder: ((context, index) {
                      return EditModelfileParameterListItem(
                        viewModel: _viewModel,
                        index: index,
                        valueCustomizationBuilder: (ctx) {
                          ModelfileParameter? parameter =
                              _viewModel.modelfileParameters.value?[index];
                          return TextField(
                            controller: _viewModel.controllers[parameter?.type],
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: "${parameter?.defaultValue ?? ''}",
                            ),
                          );
                        },
                      );
                    }),
                    itemCount: _viewModel.modelfileParameters.value?.length,
                  );
                }),
          ),
        ),
      ],
    );
  }

  Widget header(BuildContext context) {
    return Center(
      child: AppBar(
        title: Text(
          _viewModel.pageTitle,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          _applyCustomizations(context),
        ],
      ),
    );
  }

  TextButton _applyCustomizations(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        if (_viewModel.selectedCustomizations.value?.isEmpty == true) {
          showAdaptiveDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog.adaptive(
                  content: const Text('No customizations were found.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx, rootNavigator: true).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              });
        }
        Navigator.of(context).pop(
          _viewModel.mapFromModelfileParameters(),
        );
      },
      icon: const Icon(
        Icons.check_circle,
      ),
      label: Text(
        _viewModel.accessoryButtonText,
      ),
    );
  }
}
