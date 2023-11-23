import 'package:amallo/data/models/message.dart';

import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_highlighter/themes/atom-one-light.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:amallo/widgets/loading.dart';

import '../data/enums/message_source.dart';
import '../data/models/settings.dart';
import '../services/settings_service.dart';
import '../widgets/message_card.dart';
import 'conversation_view_model.dart';
import 'local_model_list.dart';
import 'settings.dart';

class ConversationPage extends StatefulWidget {
  static const String routeName = 'conversation';

  const ConversationPage(
    this._chatUuid, {
    super.key,
    required this.title,
    this.archivedConversation = false,
  });

  final String title;
  final String _chatUuid;
  final bool archivedConversation;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late ConversationViewModel viewModel;

  @override
  void initState() {
    viewModel = ConversationViewModel(widget._chatUuid);
    viewModel.init(widget.archivedConversation);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        leading: buildCreateConversationButton(),
        actions: [
          buildSettingsButton(context),
        ],
        title: buildTitle(context),
      ),
      backgroundColor: Colors.transparent,
      body: ValueListenableBuilder(
          valueListenable: viewModel.busy,
          builder: (context, busyValue, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                buildChatContent(context, busyValue),
                buildPromptInputField(),
              ],
            );
          }),
    );
  }

  Expanded buildChatContent(BuildContext context, bool busyValue) {
    return Expanded(
      child: ListenableBuilder(
        listenable: viewModel.thread,
        builder: (ctx, _) {
          var messages = viewModel.thread.value?.messages;
          if (messages == null || messages.isEmpty) {
            return noDataWidget(context);
          }
          return ListenableBuilder(
              listenable: viewModel.thread.value!,
              builder: (context, snapshot) {
                var updatedMessages = viewModel.thread.value?.messages;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                      reverse: widget.archivedConversation ? false : true,
                      itemCount: updatedMessages?.length,
                      itemBuilder: (ctx, index) {
                        return buildMessage(updatedMessages![index]);
                      }),
                );
              });
        },
      ),
    );
  }

  Center noDataWidget(BuildContext context) {
    return Center(
        child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      color: Colors.black.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ask a question',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ListenableBuilder(
                  listenable: viewModel.selectedLanguageModel,
                  builder: (context, _) {
                    String? model = viewModel.selectedLanguageModel.value;

                    String infoBoxText;
                    if (model == null) {
                      infoBoxText = 'Please choose a model!';

                      return ListenableBuilder(
                          listenable: viewModel.currentLanguageModel,
                          builder: (ctx, _) {
                            String? currentModel =
                                viewModel.currentLanguageModel.value;
                            currentModel ??= 'Unknown model';

                            return Text(
                              currentModel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            );
                          });
                    } else {
                      infoBoxText = model;
                    }

                    return Text(
                      infoBoxText,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    );
                  }),
            ),
          ],
        ),
      ),
    ));
  }

  Row buildMessage(Message message) {
    bool userInput = message.source == MessageSource.userInput.name;

    List<Widget> contentWidgets = [
      const Flexible(flex: 1, child: SizedBox()),
      Flexible(
        flex: 9,
        child: ListenableBuilder(
            listenable: viewModel.incomingMessage,
            builder: (context, _) {
              String messageText;
              if (message.done) {
                messageText = message.text ?? 'Failed to get message';
              } else {
                messageText = viewModel.incomingMessage.value ?? '...';
              }

              return messageText == '...'
                  ? Card(
                      color: Colors.white.withOpacity(0.1),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: LoadingWidget(
                          dimension: 40,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MessageCard(
                          messageText: messageText,
                          conversing: !message.done,
                          incomingMessage: userInput || message.done
                              ? null
                              : viewModel.incomingMessage,
                          date: DateTime.fromMillisecondsSinceEpoch(
                              message.createdOn ?? 0),
                          backgroundColor: userInput
                              ? Colors.blue.withOpacity(0.5)
                              : Colors.white.withOpacity(0.1),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    );
            }),
      ),
    ];

    var r = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          userInput ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: userInput ? contentWidgets : contentWidgets.reversed.toList(),
    );
    return r;
  }

  Container buildPromptInputField() {
    if (widget.archivedConversation) {
      return Container();
    }

    return Container(
      color: const Color.fromARGB(255, 39, 149, 157),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: viewModel.controller,
                autofocus: true,
                minLines: 1,
                maxLines: 8,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (submittedText) {
                  viewModel.generateFromPrompt(submittedText);
                  viewModel.controller.clear();
                },
                // textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: viewModel.exampleQuestion(),
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
              ),
            ),
            IconButton(
              color: Colors.white,
              onPressed: () {
                viewModel.generateFromPrompt();
                viewModel.controller.clear();
              },
              icon: const Icon(Icons.keyboard_return_rounded),
            ),
          ],
        ),
      ),
    );
  }

  TextButton buildTitle(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          foregroundColor:
              MaterialStateColor.resolveWith((states) => Colors.white)),
      child: ListenableBuilder(
          listenable: viewModel.scaffoldTitle,
          builder: (context, _) {
            return Text(
              viewModel.scaffoldTitle.value ?? '',
              style: const TextStyle(fontSize: 20),
            );
          }),
      onPressed: () {
        if (!widget.archivedConversation) {
          showBottomModal(context);
        }
      },
    );
  }

  IconButton buildCreateConversationButton() {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          ConversationPage.routeName,
          (route) => false,
        );
      },
      icon: const Icon(Icons.add),
      color: Colors.white,
    );
  }

  IconButton buildSettingsButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Navigator(
                initialRoute: SettingsPage.routeName,
                onGenerateInitialRoutes: (navigator, initialRoute) {
                  return [
                    MaterialPageRoute(builder: (ctx) => const SettingsPage()),
                  ];
                },
              );
            });
      },
      icon: const Icon(Icons.handyman_outlined),
      color: Colors.white,
    );
  }

  void showBottomModal(context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => LocalModelList(
              onSelectItem: (LocalModel? model) async {
                if (model != null) {
                  await SettingService()
                      .put(Settings.selectedLocalModelIdentifier, model.name);
                  viewModel.scaffoldTitle.value = model.name;
                }

                Navigator.of(context).pop();
              },
            ));
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    var language = 'dart';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }
    return SizedBox(
      // width:
      // MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
      child: HighlightView(
        // The original code to be highlighted
        element.textContent,

        // Specify language
        // It is recommended to give it a value for performance
        language: language,

        // Specify highlight theme
        // All available themes are listed in `themes` folder
        theme: MediaQuery.platformBrightnessOf(context) == Brightness.light
            ? atomOneLightTheme
            : atomOneDarkTheme,

        // Specify padding
        padding: const EdgeInsets.all(8),

        // Specify text style
        textStyle: GoogleFonts.robotoMono(),
      ),
    );
  }
}
