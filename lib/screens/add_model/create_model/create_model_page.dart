import 'package:amallo/screens/add_modelfile_parameter/add_modelfile_parameter.dart';
import 'package:amallo/screens/local_model_list.dart';
import 'package:amallo/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/enums/modelfile_customization.dart';
import '../../../data/models/modelfile_parameter_type.dart';
import '../../../widgets/create_model_field.dart';
import '../create_model/create_model_view_model.dart';

class CreateModelPage extends StatefulWidget {
  static const routeName = 'createModel';

  const CreateModelPage({super.key});

  @override
  State<CreateModelPage> createState() => _CreateModelPageState();
}

class _CreateModelPageState extends State<CreateModelPage> {
  final CreateModelViewModel _viewModel = CreateModelViewModel();

  @override
  void initState() {
    _viewModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ListenableBuilder(
                  listenable: _viewModel.customizations,
                  builder: (context, _) => buildContent(
                    context,
                  ),
                ),
              ),
            ),
          ],
        ),
        ListenableBuilder(
            listenable: _viewModel.busy,
            builder: (context, _) {
              return (_viewModel.busy.value ?? false)
                  ? Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black26,
                            ),
                            padding: const EdgeInsets.all(32),
                            width: 150,
                            height: 150,
                            child: const CircularProgressIndicator(
                              strokeWidth: 8,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox();
            }),
      ],
    );
  }

  Widget buildContent(BuildContext context) {
    return ListView(
      children: [
        buildModelNameSection(context),
        buildModelSourceSection(context),
        const SizedBox(
          height: 0,
        ),
        ElevatedButton(
          onPressed: () async {
            ScaffoldMessengerState? scaffoldState =
                ScaffoldMessenger.maybeOf(context);
            try {
              NavigatorState? state = Navigator.maybeOf(context);
              await _viewModel.createModelfile();
              state?.pop();
            } catch (e) {
              displayMessage(
                scaffoldState,
                message: e.toString(),
              );
            }
          },
          child: Text(_viewModel.submitButtonText),
        ),
        const SizedBox(
          height: 60,
        ),
        Text(
          _viewModel.optionalModelfileCustomizations,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.left,
        ),
        const SizedBox(
          height: 16,
        ),
        buildTemplateSection(context),
        const SizedBox(
          height: 16,
        ),
        buildParameterSection(context),
        const SizedBox(
          height: 16,
        ),
        buildAdapterSection(context),
        const SizedBox(
          height: 16,
        ),
        buildLicenseSection(context),
      ],
    );
  }

  CreateModelField buildModelNameSection(BuildContext context) {
    return CreateModelField(
        fieldLabel: _viewModel.modelNameFieldLabel,
        description: _viewModel.modelNameDescription,
        valueCustomizationBuilder: (localCtx) {
          return TextField(
            controller: _viewModel.modelNameController,
            smartDashesType: SmartDashesType.disabled,
            decoration: InputDecoration(
              hintText: _viewModel.modelNamePlaceholder,
            ),
          );
        });
  }

  CreateModelField buildModelSourceSection(BuildContext context) {
    return CreateModelField(
      fieldLabel: _viewModel.modelSourceFieldLabel,
      description: _viewModel.modelSourceDescription,
      valueCustomizationBuilder: (localCtx) {
        return modelSourceEditor(context);
      },
    );
  }

  CreateModelField buildTemplateSection(BuildContext context) {
    return CreateModelField(
      optional: true,
      selected: _viewModel.customizations.value
              ?.contains(ModelfileCustomization.template) ==
          true,
      fieldLabel: _viewModel.modelTemplateFieldLabel,
      description: _viewModel.modelTemplateDescription,
      valueCustomizationBuilder: (localCtx) {
        return modelTemplateEditor(context);
      },
      onSelect: (selected) {
        _viewModel.updateCustomizations(ModelfileCustomization.template);
      },
    );
  }

  CreateModelField buildParameterSection(BuildContext context) {
    return CreateModelField(
      optional: true,
      selected: _viewModel.customizations.value
              ?.contains(ModelfileCustomization.parameters) ==
          true,
      fieldLabel: _viewModel.modelParameterFieldLabel,
      description: _viewModel.modelParameterDescription,
      valueCustomizationBuilder: (localCtx) {
        return modelParameterEditor(context);
      },
      onSelect: (selected) {
        _viewModel.updateCustomizations(ModelfileCustomization.parameters);
      },
    );
  }

  CreateModelField buildAdapterSection(BuildContext context) {
    return CreateModelField(
      optional: true,
      selected: _viewModel.customizations.value
              ?.contains(ModelfileCustomization.adapter) ==
          true,
      fieldLabel: _viewModel.modelAdapterFieldLabel,
      description: _viewModel.modelAdapterDescription,
      valueCustomizationBuilder: (localCtx) {
        return modelAdapterEditor(context);
      },
      onSelect: (selected) {
        _viewModel.updateCustomizations(ModelfileCustomization.adapter);
      },
    );
  }

  CreateModelField buildLicenseSection(BuildContext context) {
    return CreateModelField(
      optional: true,
      selected: _viewModel.customizations.value
              ?.contains(ModelfileCustomization.license) ==
          true,
      fieldLabel: _viewModel.modelLicenseFieldLabel,
      description: _viewModel.modelLicenseDescription,
      valueCustomizationBuilder: (localCtx) {
        return modelLicenseEditor(context);
      },
      onSelect: (selected) {
        _viewModel.updateCustomizations(ModelfileCustomization.license);
      },
    );
  }

  Column modelSourceEditor(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _viewModel.modelSourceController,
                smartDashesType: SmartDashesType.disabled,
                decoration: InputDecoration(
                  hintText: _viewModel.modelSourcePlaceholder,
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessengerState? state =
                    ScaffoldMessenger.maybeOf(context);
                loadModelList(context, (model) {
                  if (model != null) {
                    _viewModel.modelSourceController.text =
                        'FROM ${model.name}';
                    _viewModel.modelSourceSelectedName.value = model.name;
                    try {
                      _viewModel.loadSourceExample(
                        model.name,
                      );
                      _viewModel.loadParameterExample(
                        model.name,
                      );
                    } catch (e) {
                      displayMessage(
                        state,
                        message: e.toString(),
                      );
                    }
                  }
                  Navigator.of(context).pop();
                  return Future.value(null);
                });
              },
              child: Text(
                _viewModel.modelSourceAccessoryButton,
              ),
            ),
          ],
        ),
        ListenableBuilder(
            listenable: _viewModel.modelSourceShowExample,
            builder: (context, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListenableBuilder(
                    listenable: _viewModel.modelSourceExample,
                    builder: (ctx, _) {
                      if (_viewModel.modelSourceExample.value?.isNotEmpty ==
                          true) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _viewModel.buildModelfileExampleTitle(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _viewModel.modelSourceShowExample.value =
                                      !(_viewModel
                                              .modelSourceShowExample.value ??
                                          true);
                                },
                                icon: Icon(
                                  _viewModel.modelSourceShowExample.value ==
                                          true
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                  if (_viewModel.modelSourceShowExample.value == true)
                    ListenableBuilder(
                      listenable: _viewModel.modelSourceExample,
                      builder: (ctx, _) {
                        if (_viewModel.modelSourceExample.value?.isNotEmpty ==
                            true) {
                          return Card(
                            color: Colors.black26,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Text(
                                _viewModel.modelSourceExample.value ?? '',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                ],
              );
            }),
      ],
    );
  }

  Column modelTemplateEditor(BuildContext context) {
    return Column(
      children: [
        Markdown(
          shrinkWrap: true,
          styleSheet: CodeStyleSheet(),
          data: _viewModel.modelTemplateVariableDescription,
        ),
        const SizedBox(
          height: 12,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              loadModelList(context, (model) {
                if (model != null) {
                  try {
                    _viewModel.loadTemplateExample(
                      model.name,
                    );
                  } catch (e) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString(),
                        ),
                      ),
                    );
                  }
                }
                Navigator.of(context).pop();
                return Future.value(null);
              });
            },
            child: Text(
              _viewModel.modelTemplateAccessoryButton,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
              child: Card(
                // margin: EdgeInsets.zero,
                color: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: TextField(
                    minLines: 5,
                    maxLines: 50,
                    controller: _viewModel.modelTemplateController,
                    smartDashesType: SmartDashesType.disabled,
                    decoration: InputDecoration(
                      hintText: _viewModel.modelTemplatePlaceholder,
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.robotoMono(fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column modelParameterEditor(BuildContext context) {
    return Column(
      children: [
        Markdown(
          shrinkWrap: true,
          styleSheet: CodeStyleSheet(),
          data: _viewModel.modelParameterDescription,
        ),
        const SizedBox(
          height: 12,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () async {
              var result = await showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return AddModelfileParameter(
                    _viewModel.modelParametersSelected.value ?? {},
                  );
                },
              );

              if (result is Map<ModelfileParameterType, dynamic>) {
                _viewModel.modelParametersSelected.value = result;
                _viewModel.buildModelfileParameters();
              }
            },
            child: Text(
              _viewModel.modelParameterAccessoryButton,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
              child: Card(
                // margin: EdgeInsets.zero,
                color: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: TextField(
                    minLines: 5,
                    maxLines: 50,
                    controller: _viewModel.modelParameterController,
                    smartDashesType: SmartDashesType.disabled,
                    decoration: InputDecoration(
                      hintText: _viewModel.modelParameterPlaceholder,
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.robotoMono(fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column modelAdapterEditor(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _viewModel.modelAdapterController,
          smartDashesType: SmartDashesType.disabled,
          decoration: InputDecoration(
            hintText: _viewModel.modelAdapterPlaceholder,
          ),
        ),
      ],
    );
  }

  Column modelLicenseEditor(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
              child: Card(
                // margin: EdgeInsets.zero,
                color: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: TextField(
                    minLines: 5,
                    maxLines: 50,
                    controller: _viewModel.modelLicenseController,
                    smartDashesType: SmartDashesType.disabled,
                    decoration: const InputDecoration(
                      // hintText: _viewModel.modelTemplatePlaceholder,
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.robotoMono(fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  loadModelList(
      BuildContext context, Future Function(LocalModel?)? onSelectItem) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return LocalModelList(
            editMode: false,
            onSelectItem: onSelectItem,
          );
        });
  }

  displayMessage(
    ScaffoldMessengerState? scaffoldState, {
    required String message,
  }) {
    scaffoldState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }
}
