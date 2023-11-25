import 'package:amallo/data/models/view_model_property.dart';
import 'package:amallo/screens/local_model_list.dart';
import 'package:ollama_dart/ollama_dart.dart';

class ModelDetailsViewModel {
  final ViewModelProperty model = ViewModelProperty<ModelInfo?>();

  late String modelTag;

  init(String modelTag) {
    this.modelTag = modelTag;
    _loadModel(onData: (value) {
      if (value?.isNotEmpty ?? false) {
        for (LocalModel? element in value ?? []) {
          if (element?.name == modelTag) {
            OllamaClient()
                .showModelInfo(request: ModelInfoRequest(name: modelTag))
                .then((ModelInfo value) {
              model.value = value;
            });
          }
        }
      }
    });
  }

  _loadModel({Function(List<LocalModel?>?)? onData}) async {
    LocalModelService().getTags().then((value) => onData?.call(value));
  }
}
