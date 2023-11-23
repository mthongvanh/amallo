import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:ollama_api_client/ollama_api_client.dart';

import '../data/enums/message_source.dart';
import '../data/models/chat.dart';
import '../data/models/chat_thread.dart';
import '../data/models/message.dart';
import '../data/models/settings.dart';
import '../data/models/view_model_property.dart';
import '../services/chat_service.dart';
import '../services/settings_service.dart';
import 'local_model_list.dart';

class ConversationViewModel {
  final String chatUuid;

  final OllamaClient client = OllamaClient();

  final ViewModelProperty<ChatThread> thread = ViewModelProperty(ChatThread());

  final ValueNotifier<bool> busy = ValueNotifier(false);
  final TextEditingController controller = TextEditingController();

  final ViewModelProperty<String> currentLanguageModel =
      ViewModelProperty<String>();

  final ViewModelProperty<String?> selectedLanguageModel =
      ViewModelProperty<String?>();

  final ViewModelProperty<String?> incomingMessage =
      ViewModelProperty<String?>();

  final ViewModelProperty<String> scaffoldTitle = ViewModelProperty<String>();

  Stream<GenerateResponse>? _response;

  Message? _currentMessage;

  bool _didSaveChat = false;
  bool conversing = false;

  ConversationViewModel(this.chatUuid);

  init(bool archivedConversation) async {
    if (archivedConversation) {
      List<Message> messages = ChatService()
          .history
          .where((element) => element.chatUuid == chatUuid)
          .toList();
      thread.value?.load(messages);

      Message? generatedMessage = messages
          .map((element) =>
              (element.model?.isNotEmpty ?? false) ? element : null)
          .toList()
          .first;
      if (generatedMessage?.model?.isNotEmpty ?? false) {
        scaffoldTitle.value = messages.first.model;
      }
    } else {
      await currentLanguageModel.bind(Settings.selectedLocalModelIdentifier);
      SettingService()
          .currentLanguageModel()
          .then((value) => currentLanguageModel.value = value);

      await scaffoldTitle.bind(Settings.selectedLocalModelIdentifier);
      SettingService()
          .currentLanguageModel()
          .then((value) => scaffoldTitle.value = value);
    }
  }

  Future generateFromPrompt([promptText]) async {
    String prompt = promptText ?? controller.text;
    if (busy.value || prompt.isEmpty) {
      return;
    }

    List? messageContext;
    await addMessage(
      _createMessage(
        MessageSource.userInput,
        prompt,
        modelName: selectedLanguageModel.value ?? scaffoldTitle.value,
      ),
    );

    /// continue/begin a new conversation
    Message m;
    if (!_didSaveChat) {
      m = beginConversation(prompt);
    } else {
      Message? lastGeneratedMessage = ChatService()
          .history
          .where((element) => element.source == MessageSource.generated.name)
          .lastOrNull;
      if (lastGeneratedMessage != null) {
        messageContext = lastGeneratedMessage.context;
      }
      m = continueConversation();
    }
    await addMessage(m);

    busy.value = true;

    try {
      OllamaApiResult<Stream<GenerateResponse>?> result =
          await client.generateStreamed(
        GenerateRequestParams(
          prompt: prompt,
          context: messageContext,
          model: selectedLanguageModel.value,
        ),
      );

      if (result.success) {
        bool didStartResponse = false;
        _response = result.data;
        _response?.listen((value) async {
          /// reset the placeholder text on receiving the initial response
          if (!didStartResponse) {
            didStartResponse = true;
            _currentMessage?.text = '';
          }

          _handleResponseGeneration(value);
        });
      } else {}
    } catch (e) {
      debugPrint('error: ${e.toString()}');
      busy.value = false;
    }
  }

  void _handleResponseGeneration(GenerateResponse generated) {
    /// begin processing the incoming text
    if (!generated.done) {
      /// append text to message
      String currentText = _currentMessage?.text ?? '';
      _currentMessage?.text = currentText + generated.response;
      incomingMessage.value = _currentMessage?.text;
    } else {
      /// update the message with final statistics and context
      _currentMessage?.finalize(
        context: generated.context,
        totalDuration: generated.totalDuration,
        evalCount: generated.evalCount,
        evalDuration: generated.evalDuration,
      );

      if (_currentMessage != null) {
        ChatService().updateMessage(
          _currentMessage!,
          save: true,
        );
      }

      _currentMessage = null;
      busy.value = false;
    }
  }

  /// creates a chat entry and updates the conversation state
  /// to indicate that a conversation has begun
  Message beginConversation(String chatTitle) {
    ChatService().addChat(Chat.fromMap({
      'title': chatTitle.trim(),
      'createdOn': DateTime.now().millisecondsSinceEpoch,
      'uuid': chatUuid,
    }));

    /// setup the initial state for a new conversation
    _didSaveChat = true;
    selectedLanguageModel.value = currentLanguageModel.value;
    conversing = true;
    _currentMessage = null;

    return continueConversation();
  }

  /// creates a new AI-generated message
  Message continueConversation([String? text]) {
    Message message = _createMessage(MessageSource.generated, text ?? '...');
    _currentMessage = message;
    return message;
  }

  addMessage(Message m) async {
    thread.value?.add(m);
    await ChatService().addMessage(m);
  }

  Message _createMessage(MessageSource type, String message,
      {String? modelName, context, Map<String, dynamic>? summary}) {
    return Message.fromMap({
      "source": type == MessageSource.userInput
          ? MessageSource.userInput.name
          : MessageSource.generated.name,
      "text": message,
      "chatUuid": chatUuid,
      "createdOn": DateTime.now().millisecondsSinceEpoch,
      "context": context,
      "model": modelName ?? summary?["model"],
      "total_duration": summary?["total_duration"] ?? 0,
      "eval_count": summary?["eval_count"] ?? 0,
      "eval_duration": summary?["eval_duration"] ?? 0,
    });
  }

  loadModels() async {
    // var currentModel =
    //     await SettingService().get(Settings.selectedLocalModelIdentifier);
    // if (currentModel == null) {
    List<LocalModel?>? models = await LocalModelService().getTags();
    var local = models?.lastOrNull;
    if (local != null) {
      SettingService().put(Settings.selectedLocalModelIdentifier, local.name);
    }
    // }
  }

  String exampleQuestion() {
    /// Here are 20 fun questions you could ask a generative AI:
    var questions = [
      "What is your favorite joke, and can you tell it to me?",
      "If you could be any fictional character, who would you choose and why?",
      "What is the most creative thing you've ever generated? Can you show me?",
      "What do you think of when I say the word \"spring\"?",
      "If you could travel anywhere in the world right now, where would you go and what would you do?",
      "What is your favorite type of music, and can you generate a song for me in that style?",
      "Can you generate a haiku or other short poem for me?",
      "If you could have any superpower, what would it be and why?",
      "Can you generate a story for me about a character who learns to overcome their fears?",
      "What do you think is the most challenging thing about being an AI, and how do you handle it?",
      "If you could have dinner with any historical figure, who would it be and why?",
      "Can you generate a piece of artwork for me, such as a painting or sculpture?",
      "What is your favorite type of exercise, and can you recommend some exercises for me to try?",
      "If you could have any animal as a pet, what would it be and why?",
      "Can you generate a piece of music for me that incorporates elements from different cultures or time periods?",
      "What is your favorite type of cuisine, and can you recommend some dishes or restaurants for me to try?",
      "If you could have any fictional world or character as a friend, who would it be and why?",
      "Can you generate a piece of writing for me that incorporates elements from different cultures or time periods?",
      "What is your favorite type of hobby or activity, and can you recommend some things for me to try?",
      "If you could have any type of supernatural ability, what would it be and why?"
    ];
    return questions[Random().nextInt(questions.length)];
  }
}
