import 'dart:convert';

import 'package:flutter/services.dart';

import 'modelfile_parameter_type.dart';

/// Describes parameters available for customization
class ModelfileParameter {
  final ModelfileParameterType type;
  final String displayName;
  final dynamic defaultValue;

  const ModelfileParameter(
    this.type,
    this.displayName,
    this.defaultValue,
  );

  bool allowMultiple() => type == ModelfileParameterType.stop;

  String? get description => ModelfileParameter.descriptions[type];

  static Map<ModelfileParameterType, String> get descriptions => {
        ModelfileParameterType.mirostat:
            "Enable Mirostat sampling for controlling perplexity. (default: 0, 0 = disabled, 1 = Mirostat, 2 = Mirostat 2.0)",
        ModelfileParameterType.mirostatEta:
            "Influences how quickly the algorithm responds to feedback from the generated text. A lower learning rate will result in slower adjustments, while a higher learning rate will make the algorithm more responsive. (Default: 0.1)",
        ModelfileParameterType.mirostatTau:
            "Controls the balance between coherence and diversity of the output. A lower value will result in more focused and coherent text. (Default: 5.0)",
        ModelfileParameterType.numCtx:
            "Sets the size of the context window used to generate the next token. (Default: 2048)",
        ModelfileParameterType.numGqa:
            "The number of GQA groups in the transformer layer. Required for some models, for example it is 8 for llama2:70b",
        ModelfileParameterType.numGpu:
            "The number of layers to send to the GPU(s). On macOS it defaults to 1 to enable metal support, 0 to disable.",
        ModelfileParameterType.numThread:
            "Sets the number of threads to use during computation. By default, Ollama will detect this for optimal performance. It is recommended to set this value to the number of physical CPU cores your system has (as opposed to the logical number of cores).",
        ModelfileParameterType.repeatLastN:
            "Sets how far back for the model to look back to prevent repetition. (Default: 64, 0 = disabled, -1 = num_ctx)",
        ModelfileParameterType.repeatPenalty:
            "Sets how strongly to penalize repetitions. A higher value (e.g., 1.5) will penalize repetitions more strongly, while a lower value (e.g., 0.9) will be more lenient. (Default: 1.1)",
        ModelfileParameterType.temperature:
            "The temperature of the model. Increasing the temperature will make the model answer more creatively. (Default: 0.8)",
        ModelfileParameterType.seed:
            "Sets the random number seed to use for generation. Setting this to a specific number will make the model generate the same text for the same prompt. (Default: 0)",
        ModelfileParameterType.stop:
            "Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate `stop` parameters in a modelfile.",
        ModelfileParameterType.tfsZ:
            "Tail free sampling is used to reduce the impact of less probable tokens from the output. A higher value (e.g., 2.0) will reduce the impact more, while a value of 1.0 disables this setting. (default: 1)",
        ModelfileParameterType.numPredict:
            "Maximum number of tokens to predict when generating text. (Default: 128, -1 = infinite generation, -2 = fill context)",
        ModelfileParameterType.topK:
            "Reduces the probability of generating nonsense. A higher value (e.g. 100) will give more diverse answers, while a lower value (e.g. 10) will be more conservative. (Default: 40)",
        ModelfileParameterType.topP:
            "Works together with top-k. A higher value (e.g., 0.95) will lead to more diverse text, while a lower value (e.g., 0.5) will generate more focused and conservative text. (Default: 0.9)",
      };

  static fromJson(Map<String, dynamic> json) {
    var value = json['defaultValue'];
    if (value is String && value.isEmpty) {
      value = null;
    }

    return ModelfileParameter(
      ModelfileParameterType.fromString(json['name']),
      json['displayName'],
      value,
    );
  }

  static Future<List<ModelfileParameter>> parameters() async {
    var list = await json();
    var parametersFromDisk = list.map(
      (e) {
        var mp = ModelfileParameter.fromJson(e) as ModelfileParameter;
        return mp;
      },
    ).toList();
    return parametersFromDisk;
  }

  static Future<List<Map<String, dynamic>>> json() async {
    try {
      String data =
          await rootBundle.loadString('assets/json/modelfile-parameters.json');
      return List.from(jsonDecode(data));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
