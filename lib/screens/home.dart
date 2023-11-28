import 'package:amallo/data/models/view_model_property.dart';
import 'package:amallo/extensions/colors.dart';
import 'package:amallo/screens/add_model/add_model.dart';
import 'package:amallo/screens/add_model/create_model/create_model_page.dart';
import 'package:amallo/screens/chats.dart';
import 'package:amallo/screens/conversation.dart';
import 'package:amallo/screens/local_model_list.dart';
import 'package:amallo/screens/model_details/model_details.dart';
import 'package:amallo/screens/settings.dart';
import 'package:amallo/services/screen_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/chat.dart';
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
    // widget.viewModel.init();
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

        var contentRow = Row(
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
                backgroundColor: Colors.transparent,
                body: Navigator(
                  key: _contentNavigatorKey,
                  initialRoute: ConversationPage.routeName,
                  onGenerateRoute: _generateRoute,
                ),
                bottomNavigationBar: screenSize != ScreenSize.extraLarge
                    ? _buildBottomNavigation()
                    : null,
              ),
            ),
          ],
        );

        if (screenSize == ScreenSize.extraLarge) {
          return Row(
            children: [
              _buildNavigationRail(),
              Expanded(child: contentRow),
            ],
          );
        } else {
          return contentRow;
        }
      }),
    );
  }

  Widget buildNavigation(ScreenSize screenSize) {
    if (screenSize == ScreenSize.extraLarge) {
      return _buildNavigationRail();
    } else {
      return _buildBottomNavigation();
    }
  }

  Widget _buildBottomNavigation() {
    return ListenableBuilder(
        listenable: widget.viewModel.selectedIndex,
        builder: (context, _) {
          return BottomNavigationBar(
            backgroundColor: Colors.black38,
            elevation: 0,
            selectedLabelStyle: const TextStyle(color: Colors.white),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            currentIndex: widget.viewModel.selectedIndex.value ?? 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.chat,
                  color: Colors.white,
                ),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.list_outlined,
                  color: Colors.grey,
                ),
                activeIcon: Icon(
                  Icons.list,
                  color: Colors.white,
                ),
                label: 'Models',
              ),
            ],
            onTap: (index) {
              widget.viewModel.selectedIndex.value = index;
              loadNavigationItem(index);
            },
          );
        });
  }

  Widget _buildNavigationRail() {
    return ListenableBuilder(
        listenable: widget.viewModel.selectedIndex,
        builder: (context, _) {
          return NavigationRail(
            backgroundColor: Colors.black38,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('Chat'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  Icons.list_outlined,
                  color: Colors.white,
                ),
                selectedIcon: Icon(Icons.list),
                label: Text('Workspace'),
              ),
            ],
            selectedIndex: widget.viewModel.selectedIndex.value,
            onDestinationSelected: (index) {
              widget.viewModel.selectedIndex.value = index;
              loadNavigationItem(index);
            },
          );
        });
  }

  loadNavigationItem(int index) {
    switch (index) {
      case 0:

        /// load conversations
        _contentNavigatorKey.currentState
            ?.pushReplacementNamed(ConversationPage.routeName);
        break;
      case 1:

        /// load model list
        _contentNavigatorKey.currentState
            ?.pushReplacementNamed(LocalModelList.routeName);
        break;

      default:
        _contentNavigatorKey.currentState
            ?.pushReplacementNamed(ConversationPage.routeName);
    }
  }

  Route _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SettingsPage.routeName:
        {
          return MaterialPageRoute(builder: (ctx) => const SettingsPage());
        }
      case LocalModelList.routeName:
        return MaterialPageRoute(
            builder: (ctx) => LocalModelList(
                  editMode: true,
                  onSelectItem: (item) async {
                    _contentNavigatorKey.currentState?.pushNamed(
                      ModelDetails.routeName,
                      arguments: item?.name,
                    );
                  },
                ));
      case ModelDetails.routeName:
        return MaterialPageRoute(
            builder: (ctx) => ModelDetails(
                  modelTag: settings.arguments as String,
                ));

      case AddModelScreen.routeName:
        return MaterialPageRoute(
          builder: (ctx) => const AddModelScreen(),
        );
      case CreateModelPage.routeName:
        return MaterialPageRoute(
          builder: (ctx) => const CreateModelPage(),
        );
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

  // void showBottomModal(context) {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (ctx) => LocalModelList(
  //             onSelectItem: (LocalModel? model) async {
  //               if (model != null) {
  //                 await SettingService()
  //                     .put(Settings.selectedLocalModelIdentifier, model.name);
  //                 widget.viewModel.scaffoldTitle.value = model.name;
  //               }

  //               Navigator.of(context).pop();
  //             },
  //           ));
  // }
}

class HomeViewModel {
  final ViewModelProperty<Widget> chatListPage = ViewModelProperty<Widget>();
  // final ViewModelProperty<String> scaffoldTitle = ViewModelProperty<String>();
  final ViewModelProperty<int> selectedIndex = ViewModelProperty<int>(0);

  // init() {
  //   scaffoldTitle.bind(Settings.selectedLocalModelIdentifier);
  //   SettingService()
  //       .currentLanguageModel()
  //       .then((value) => scaffoldTitle.value = value);
  // }

  // loadModels() async {
  //   // var currentModel =
  //   //     await SettingService().get(Settings.selectedLocalModelIdentifier);
  //   // if (currentModel == null) {
  //   List<LocalModel?>? models = await LocalModelService().getTags();
  //   var local = models?.lastOrNull;
  //   if (local != null) {
  //     SettingService().put(Settings.selectedLocalModelIdentifier, local.name);
  //   }
  //   // }
  // }
}
