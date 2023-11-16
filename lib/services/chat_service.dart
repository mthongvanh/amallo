import 'dart:async';
import 'dart:convert';

import 'package:amallo/data/models/chat.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/message.dart';

class ChatService {
  static ChatService? instance;

  ChatService._();

  factory ChatService() => instance ??= ChatService._();

  final MessageDAO _messageDAO = MessageDAO();
  final ChatDAO _chatDAO = ChatDAO();

  List<Message> history = [];
  final ValueNotifier<List<Chat>> chats = ValueNotifier([]);

  init() async {
    await loadData();
  }

  Future loadData() async {
    var history = await _messageDAO.loadData();
    if (history is List<dynamic>) {
      this.history = history.map((e) => Message.fromMap(e)).toList();
    }

    var archivedChats = await _chatDAO.loadData();
    if (archivedChats is List<dynamic>) {
      chats.value = archivedChats.map((e) => Chat.fromMap(e)).toList();
    }
    return;
  }

  FutureOr<List<Message?>> addMessage(Message message,
      {bool save = true}) async {
    history.add(message);
    if (save) {
      await saveHistory();
    }
    return history;
  }

  Message? updateMessage(Message message, {bool save = true}) {
    Message? archivedMessage = history
        .where((element) => element.chatUuid == message.chatUuid)
        .firstOrNull;
    if (archivedMessage != null) {
      archivedMessage.finalizeFromJson(message.toJson());
      if (save) {
        saveHistory();
      }
    }
    return archivedMessage;
  }

  FutureOr<XFile?> saveHistory() => _messageDAO.save(history);

  Future<List<Chat?>> addChat(Chat chat, {bool save = true}) async {
    chats.value.add(chat);
    if (save) {
      await saveChats();
    }
    chats.value = List.from(chats.value);
    return chats.value;
  }

  Future<List<Chat?>> removeChat(String chatUuid, {bool save = true}) async {
    chats.value.removeWhere((element) => element.uuid == chatUuid);
    if (save) {
      await saveChats();
    }
    chats.value = List.from(chats.value);
    return chats.value;
  }

  FutureOr<XFile?> saveChats() => _chatDAO.save(chats.value);
}

class MessageDAO extends ModelDAO {
  @override
  String filename() => 'messages.json';
}

class ChatDAO extends ModelDAO {
  @override
  String filename() => 'chats.json';
}

class ModelDAO {
  Future<List?> loadData() async {
    List? data;
    try {
      final path = await savePath();
      final file = XFile(path);
      data = jsonDecode(await file.readAsString());
    } catch (e) {
      debugPrint(e.toString());
    }
    return data;
  }

  FutureOr<XFile?> save(List history) async {
    XFile? file;
    try {
      final path = await savePath();
      final data = const Utf8Encoder().convert(jsonEncode(history));
      file = XFile.fromData(data);
      await file.saveTo(path);
    } catch (e) {
      debugPrint(e.toString());
    }
    return file;
  }

  savePath() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var savePath = "${documentsDirectory.path}/${filename()}";
    return savePath;
  }

  filename() {
    throw ('must implement filename getter');
  }
}
