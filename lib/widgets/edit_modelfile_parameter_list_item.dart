import 'package:flutter/material.dart';

import '../data/models/modelfile_parameter.dart';
import '../screens/add_modelfile_parameter/add_modelfile_parameter_view_model.dart';
import 'edit_model_parameter.dart';

class EditModelfileParameterListItem extends StatelessWidget {
  const EditModelfileParameterListItem({
    super.key,
    required AddModelfileParameterViewModel viewModel,
    required this.index,
    required this.valueCustomizationBuilder,
  }) : _viewModel = viewModel;

  final AddModelfileParameterViewModel _viewModel;
  final int index;
  final WidgetBuilder valueCustomizationBuilder;

  @override
  Widget build(BuildContext context) {
    ModelfileParameter? parameter =
        _viewModel.modelfileParameters.value?[index];
    if (parameter == null) {
      return const Text('Unknown parameter!');
    }
    return ListenableBuilder(
        listenable: _viewModel.selectedCustomizations,
        builder: (context, _) {
          return EditModelParameter(
            optional: true,
            selected: _viewModel.selectedCustomizations.value
                    ?.contains(parameter.type) ==
                true,
            parameterLabel: parameter.displayName,
            description: parameter.description ?? 'Unknown description',
            valueCustomizationBuilder: (ctx) {
              return TextField(
                controller: _viewModel.controllers[parameter.type],
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "${parameter.defaultValue ?? ''}",
                ),
              );
            },
            onSelect: (selected) {
              return _viewModel.updateSelectedCustomizations(parameter);
            },
          );
        });
  }
}
