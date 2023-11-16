import 'package:flutter/material.dart';

import '../data/models/chat.dart';
import '../services/chat_service.dart';

class Chats extends StatelessWidget {
  final ChatService _chatService;

  final Function(Chat) onSelectChat;

  const Chats(this._chatService, {required this.onSelectChat, super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _chatService.chats,
        builder: (context, value, _) {
          /// reverse the order so newer questions are at the top
          value.sort((a, b) => (b.createdOn ?? 0).compareTo(a.createdOn ?? 0));
          return Container(
            color: Colors.black12,
            child: ListView.builder(
                itemCount: value.length,
                itemBuilder: (ctx, index) {
                  var item = value[index];
                  return Dismissible(
                    key: Key(item.uuid),
                    // Provide a function that tells the app
                    // what to do after an item has been swiped away.
                    onDismissed: (direction) {
                      // Remove the item from the data source.
                      _chatService.removeChat(item.uuid);

                      // Then show a snackbar.
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Conversation "${item.title}" dismissed')));
                    },
                    background: Container(color: Colors.red),
                    child: GestureDetector(
                      onTap: () {
                        if (value.isNotEmpty) {
                          debugPrint(value[index].title);
                          onSelectChat(value[index]);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          value.isEmpty
                              ? 'nothing yet!'
                              : value[index].title?.trim() ?? 'Untitled',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white),
                          maxLines: 2,
                        ),
                      ),
                    ),
                  );
                }),
          );
        });
  }
}
