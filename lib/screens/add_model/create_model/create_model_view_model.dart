import 'package:amallo/data/models/view_model_property.dart';
import 'package:amallo/screens/local_model_list.dart';
import 'package:flutter/widgets.dart';
import 'package:ollama_dart/ollama_dart.dart';

import '../../../data/enums/modelfile_customization.dart';
import '../../../data/models/modelfile_parameter_type.dart';

class CreateModelViewModel {
  init() {
    debugPrint('initCalled');
  }

  final ViewModelProperty<Set<ModelfileCustomization>> customizations =
      ViewModelProperty({});

  final ViewModelProperty<bool> busy = ViewModelProperty(false);

  /// Call the API to create a new Modelfile using required fields and
  /// optional customizations that have been both selected and contain a value
  Future<void> createModelfile() async {
    if (busy.value == true) {
      return Future.value(null);
    }

    List<String> requiredComponents = [
      modelNameController.text,
      modelSourceController.text,
    ];

    if (requiredComponents.where((element) => element.isEmpty).isNotEmpty) {
      throw Exception('The model name and source are both required');
    }

    bool appendLicense =
        modelLicenseController.text.toLowerCase().startsWith('license') ==
            false;

    bool appendFrom =
        modelSourceController.text.toLowerCase().startsWith('from') == false;

    String modelfile = [
      (appendFrom)
          ? "FROM ${modelSourceController.text}"
          : modelSourceController.text,
      if (customizations.value?.contains(ModelfileCustomization.template) ??
          false)
        modelTemplateController.text,
      // if (customizations.value?.contains(ModelfileCustomization.system) ?? false) modelSystemController.text,
      if (customizations.value?.contains(ModelfileCustomization.parameters) ??
          false)
        modelParameterController.text,
      if (customizations.value?.contains(ModelfileCustomization.adapter) ??
          false)
        modelAdapterController.text,
      if (customizations.value?.contains(ModelfileCustomization.license) ??
          false)
        (appendLicense && modelLicenseController.text.isNotEmpty)
            ? "LICENSE ${modelLicenseController.text}"
            : modelLicenseController.text,
    ].join("\n");

    try {
      busy.value = true;
      CreateModelResponse response = await LocalModelService().createModel(
        modelNameController.text.trim(),
        modelfile.trim(),
      );
      if (response.status == CreateModelStatus.success) {
        debugPrint('created model success');
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    } finally {
      busy.value = false;
    }
  }

  bool clearState() {
    modelNameController.text = '';
    modelSourceController.text = '';
    modelTemplateController.text = '';
    modelSystemController.text = '';
    modelParameterController.text = '';
    modelAdapterController.text = '';
    modelLicenseController.text = '';

    customizations.value = {};

    modelSourceShowExample.value = false;
    modelSourceExample.value = '';
    modelLicenseExample.value = '';
    modelParametersSelected.value = {};

    return true;
  }

  updateCustomizations(
    ModelfileCustomization customization, {
    bool? add = false,
  }) {
    Set<ModelfileCustomization> localCustomizations =
        Set.from(customizations.value ?? {});
    if (localCustomizations.contains(customization) == false || add == true) {
      localCustomizations.add(customization);
    } else {
      localCustomizations.remove(customization);
    }
    customizations.value = localCustomizations;
  }

  ///
  /// Text Editing Controllers for Customizable Fields
  ///

  final TextEditingController modelNameController = TextEditingController();
  final TextEditingController modelSourceController = TextEditingController();
  final TextEditingController modelTemplateController = TextEditingController();
  final TextEditingController modelParameterController =
      TextEditingController();
  final TextEditingController modelSystemController = TextEditingController();
  final TextEditingController modelAdapterController = TextEditingController();
  final TextEditingController modelLicenseController = TextEditingController();

  final submitButtonText = 'Create Model';

  ///
  /// Model Name Section
  ///

  final modelNameFieldLabel = 'Model Name';
  final modelNameDescription = 'The model identifier';
  final modelNamePlaceholder = 'e.g. mario, mistral, alfred';

  ///
  /// Model Source Section
  ///

  final modelSourceFieldLabel = 'FROM (required)';
  final modelSourceDescription = 'Defines the base model to use.';
  final modelSourcePlaceholder = 'FROM llama2';
  final modelSourceAccessoryButton = 'Select from List';
  final ViewModelProperty<bool> modelSourceShowExample =
      ViewModelProperty(true);
  final ViewModelProperty<String> modelSourceExample = ViewModelProperty('');
  final ViewModelProperty<String> modelSourceSelectedName =
      ViewModelProperty('');
  String buildModelfileExampleTitle() =>
      "Modelfile for ${modelSourceSelectedName.value}:";
  void loadSourceExample(modelName) {
    LocalModelService().modelInfo(modelName).then(
          (value) => modelSourceExample.value = value.modelfile,
        );
  }

  final optionalModelfileCustomizations = 'Optional Customizations';

  ///
  /// Model Template Section
  ///

  final modelTemplateFieldLabel = 'TEMPLATE';
  final modelTemplateDescription =
      "TEMPLATE of the full prompt template to be passed into the model. It may include (optionally) a system prompt and a user's prompt. This is used to create a full custom prompt, and syntax may be model specific. You can usually find the template for a given model in the readme for that model.\n\nSYSTEM\nThe SYSTEM instruction specifies the system prompt to be used in the template, if applicable.";
  final modelTemplatePlaceholder = """
TEMPLATE \"\"\"
{{- if .First }}
### System:
{{ .System }}
{{- end }}

### User:
{{ .Prompt }}

### Response:
\"\"\"

SYSTEM \"\"\"<system message>\"\"\"
""";

  final modelTemplateVariableDescription = """
#### Template Variables
- `{{ .System }}` - The system prompt used to specify custom behavior, this must also be set in the Modelfile as an instruction.
- `{{ .Prompt }}` - The incoming prompt, this is not specified in the model file and will be set based on input.
- `{{ .First }}` - A boolean value used to render specific template information for the first generation of a session.
""";
  final modelTemplateAccessoryButton = 'Copy from Model';
  void loadTemplateExample(modelName) {
    LocalModelService().modelInfo(modelName).then(
          (value) => modelTemplateController.text =
              value.template?.isNotEmpty ?? true
                  ? "TEMPLATE \"\"\"\n${value.template}\n\"\"\""
                  : modelTemplatePlaceholder,
        );
  }

  ///
  /// Model Adapter Section
  ///

  final modelAdapterFieldLabel = 'ADAPTER';
  final modelAdapterDescription =
      'The ADAPTER instruction specifies the LoRA adapter to apply to the base model. The value of this instruction should be an absolute path or a path relative to the Modelfile and the file must be in a GGML file format. The adapter should be tuned from the base model otherwise the behaviour is undefined.';
  final modelAdapterPlaceholder = 'ADAPTER ./ollama-lora.bin';

  ///
  /// Model License Section
  ///

  final modelLicenseFieldLabel = 'LICENSE';
  final modelLicenseDescription =
      'The LICENSE instruction allows you to specify the legal license under which the model used with this Modelfile is shared or distributed.';
  final ViewModelProperty<String> modelLicenseExample = ViewModelProperty('');
  void loadLicenseExample(modelName) {
    LocalModelService().modelInfo(modelName).then(
          (value) => modelLicenseController.text = value.license ?? '',
        );
  }

  ///
  /// Model Parameter Section
  ///

  final modelParameterFieldLabel = 'PARAMETERS';
  final modelParameterDescription =
      'The PARAMETER instruction defines a parameter that can be set when the model is run.';
  String modelParameterPlaceholder = 'PARAMETER <parameter_name> <value>';
  final modelParameterAccessoryButton = 'Add Parameters';
  final ViewModelProperty<Map<ModelfileParameterType, dynamic>>
      modelParametersSelected = ViewModelProperty({});

  /// Calls API to pull PARAMETER list from the local modelfile
  ///
  /// The API returns a [String] joined by newline characters without the PARAMETER
  /// keyword, so we need to insert the PARAMETER keyword before each parameter entry
  /// before we compile our Modelfile
  void loadParameterExample(modelName) {
    LocalModelService().modelInfo(modelName).then(
      (value) {
        String exampleParameters = '';
        if (value.parameters?.isNotEmpty == true) {
          exampleParameters += value.parameters ?? '';
          List<String> params = exampleParameters
              .split("\n")
              .map(
                /// remove whitespace around the parameter identifier and its value
                /// e.g. "stop        <start_user>" -> "stop <start_user>"
                (e) => e
                    .split(" ")
                    .map((e) => e.trim())
                    .where((element) => element.isNotEmpty)
                    .join(" "),
              )
              .where((element) => element.isNotEmpty)
              .toList();
          List<String> replaced = params.map((e) => 'PARAMETER $e').toList();
          exampleParameters = replaced.join("\n");
        }

        modelParameterController.text = modelParameterController.text.isNotEmpty
            ? modelParameterController.text
            : exampleParameters;
      },
    );
  }

  buildModelfileParameters() {
    String modelParameters = '';
    modelParametersSelected.value?.forEach((key, value) {
      modelParameters = "${modelParameters}PARAMETER ${key.value} $value\n";
    });
    modelParameterController.text = modelParameters;
    bool hasCustomValue = modelParameters.isNotEmpty;
    updateCustomizations(
      ModelfileCustomization.parameters,
      add: hasCustomValue,
    );
  }
}
