import 'package:flutter/widgets.dart';

import '../../data/models/modelfile_parameter.dart';
import '../../data/models/modelfile_parameter_type.dart';
import '../../data/models/view_model_property.dart';
import '../local_model_list.dart';

class AddModelfileParameterViewModel {
  bool _initialized = false;
  bool get initialized => _initialized;

  ModelfileParameters parameters = ModelfileParameters();
  init(Map<ModelfileParameterType, dynamic> parameters) {
    _initialized = true;
    loadModelfileParameters();
    loadSelectedCustomizations(parameters);
    controllers = loadTextEditingControllers(parameters);
  }

  final ViewModelProperty<List<ModelfileParameterType>> selectedCustomizations =
      ViewModelProperty([]);

  updateSelectedCustomizations(ModelfileParameter parameter) {
    List<ModelfileParameterType> local =
        List.from(selectedCustomizations.value ?? []);
    if (local.contains(parameter.type) == true) {
      local.remove(parameter.type);
    } else {
      local.add(parameter.type);
    }
    selectedCustomizations.value = local;
  }

  loadSelectedCustomizations(Map<ModelfileParameterType, dynamic> parameters) {
    selectedCustomizations.value = parameters.keys.toList();
  }

  /// Returns the parameter type and customized value
  Map<ModelfileParameterType, dynamic> mapFromModelfileParameters(
      [List<ModelfileParameterType>? customizations]) {
    customizations ??= selectedCustomizations.value ?? [];
    Map<ModelfileParameterType, dynamic> parameters = {};
    for (var e in customizations) {
      ModelfileParameterType type = e;
      dynamic value = controllers[type]?.text;
      parameters[e] = value;
    }
    return parameters;
  }

  Map<ModelfileParameterType, TextEditingController> controllers = {};

  loadTextEditingControllers(Map<ModelfileParameterType, dynamic> parameters) {
    Map<ModelfileParameterType, TextEditingController> controllers = {};
    for (var type in ModelfileParameterType.values) {
      controllers[type] = TextEditingController(
        text: parameters[type],
      );
    }
    return controllers;
  }

  loadModelfileParameters() async {
    modelfileParameters.value = await ModelfileParameter.parameters();
  }

  final ViewModelProperty<List<ModelfileParameter>> modelfileParameters =
      ViewModelProperty([]);

  final pageTitle = 'Modelfile Parameters';
  final accessoryButtonText = 'Save Customizations';
}
