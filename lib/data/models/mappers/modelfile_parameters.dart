import '../../../screens/local_model_list.dart';
import '../modelfile_parameter.dart';
import '../modelfile_parameter_type.dart';

class ModelfileParametersMapper {
  static ModelfileParameters fromParameterType(
      Map<ModelfileParameterType, dynamic> parameters) {
    return ModelfileParameters(
      mirostat: parameters[ModelfileParameterType.mirostat],
      mirostatEta: parameters[ModelfileParameterType.mirostatEta],
      mirostatTau: parameters[ModelfileParameterType.mirostatTau],
      numCtx: parameters[ModelfileParameterType.numCtx],
      numGqa: parameters[ModelfileParameterType.numGqa],
      numGpu: parameters[ModelfileParameterType.numGpu],
      numThread: parameters[ModelfileParameterType.numThread],
      repeatLastN: parameters[ModelfileParameterType.repeatLastN],
      repeatPenalty: parameters[ModelfileParameterType.repeatPenalty],
      temperature: parameters[ModelfileParameterType.temperature],
      seed: parameters[ModelfileParameterType.seed],
      stop: parameters[ModelfileParameterType.stop],
      tfsZ: parameters[ModelfileParameterType.tfsZ],
      numPredict: parameters[ModelfileParameterType.numPredict],
      topK: parameters[ModelfileParameterType.topK],
      topP: parameters[ModelfileParameterType.topP],
    );
  }

  /// Returns the parameter name and customized value
  static Map<String, dynamic> mapFromModelfileParameters(
      List<ModelfileParameter> customizations,
      {required Map<ModelfileParameterType, dynamic> customizationValues}) {
    Map<String, dynamic> parameters = {};
    for (var e in customizations) {
      ModelfileParameterType type = e.type;
      dynamic value = customizationValues[type]?.text;
      parameters[e.type.toString()] = value;
    }

    return parameters;
  }
}
