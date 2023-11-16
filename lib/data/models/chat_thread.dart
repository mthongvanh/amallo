import 'package:flutter/foundation.dart';

import 'message.dart';

class ChatThread extends ChangeNotifier {
  final List<Message> messages = [];

  load(List<Message> collection) {
    messages.clear();
    messages.addAll(collection);
    notifyListeners();
  }

  add(Message message) {
    messages.insert(0, message);
    notifyListeners();
  }
}