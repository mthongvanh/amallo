import 'package:amallo/data/models/view_model_property.dart';
import 'package:amallo/extensions/colors.dart';
import 'package:amallo/screens/chats.dart';
import 'package:amallo/screens/conversation.dart';
import 'package:amallo/screens/local_model_list.dart';
import 'package:amallo/screens/settings.dart';
import 'package:amallo/services/screen_service.dart';
import 'package:amallo/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/chat.dart';
import '../data/models/settings.dart';
import '../services/chat_service.dart';

class Home extends StatefulWidget {
  final HomeViewModel viewModel = HomeViewModel();

  final ScreenService screenService = ScreenService();

  final ChatService _chatService;

  Home(this._chatService, {super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _contentNavigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    widget.viewModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue,
            AppColors.turquoise,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.1, 0.9],
        ),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        ScreenSize screenSize = widget.screenService.getSize(context);

        widget.viewModel.chatListPage.value ??= Chats(
          widget._chatService,
          onSelectChat: (Chat c) {
            _contentNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                ConversationPage.routeName, (settings) => false,
                arguments: {
                  'chatUuid': c.uuid,
                });
          },
        );

        return Row(
          children: [
            /// build chat listing
            (screenSize != ScreenSize.extraLarge
                ? const SizedBox()
                : ListenableBuilder(
                    listenable: widget.viewModel.chatListPage,
                    builder: (ctx, _) {
                      return Flexible(
                          flex: 2,
                          child: widget.viewModel.chatListPage.value ??
                              const SizedBox());
                    })),

            /// build conversation scaffold
            Flexible(
              flex: 5,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.black12,
                  leading: buildCreateConversationButton(),
                  actions: [
                    buildSettingsButton(context),
                  ],
                  title: buildTitle(context),
                ),
                backgroundColor: Colors.transparent,
                body: Navigator(
                  key: _contentNavigatorKey,
                  initialRoute: ConversationPage.routeName,
                  onGenerateRoute: _generateRoute,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  IconButton buildCreateConversationButton() {
    return IconButton(
      onPressed: () {
        _contentNavigatorKey.currentState?.pushNamedAndRemoveUntil(
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

  TextButton buildTitle(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          foregroundColor:
              MaterialStateColor.resolveWith((states) => Colors.white)),
      child: ListenableBuilder(
          listenable: widget.viewModel.scaffoldTitle,
          builder: (context, _) {
            return Text(
              widget.viewModel.scaffoldTitle.value ?? '',
              style: const TextStyle(fontSize: 20),
            );
          }),
      onPressed: () {
        showBottomModal(context);
      },
    );
  }

  Route _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SettingsPage.routeName:
        {
          return MaterialPageRoute(builder: (ctx) => const SettingsPage());
        }
      case ConversationPage.routeName:
      default:
        {
          return MaterialPageRoute(builder: (context) {
            String chatUuid = const Uuid().v4();
            bool archived = false;
            if (settings.arguments != null && settings.arguments is Map) {
              chatUuid = (settings.arguments as Map)['chatUuid'];
              archived = true;
            }

            return ConversationPage(
              chatUuid,
              title: 'something',
              archivedConversation: archived,
            );
          });
        }
    }
  }

  void showBottomModal(context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => LocalModelList(
              onSelectItem: (LocalModel? model) async {
                if (model != null) {
                  await SettingService()
                      .put(Settings.selectedLocalModelIdentifier, model.name);
                  widget.viewModel.scaffoldTitle.value = model.name;
                }

                Navigator.of(context).pop();
              },
            ));
  }
}

class HomeViewModel {
  final ViewModelProperty<Widget> chatListPage = ViewModelProperty<Widget>();
  final ViewModelProperty<String> scaffoldTitle = ViewModelProperty<String>();

  init() {
    scaffoldTitle.bind(Settings.selectedLocalModelIdentifier);
    SettingService()
        .currentLanguageModel()
        .then((value) => scaffoldTitle.value = value);
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
}
