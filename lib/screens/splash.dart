import 'dart:async';

import 'package:amallo/screens/home.dart';
import 'package:amallo/services/chat_service.dart';
import 'package:amallo/services/database.dart';
import 'package:amallo/services/settings_service.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashBloc _bloc = SplashBloc();

  @override
  void initState() {
    _bloc.init();
    _bloc.chatStream.listen((event) {
      if (event != null) {
        Future.delayed(const Duration(seconds: 1)).then((value) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Home(event),
            ),
          );
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class SplashBloc {
  final StreamController<ChatService?> _readyController =
      StreamController.broadcast();
  Stream<ChatService?> get chatStream => _readyController.stream;

  init() {
    prepareData();
  }

  prepareData() async {
    var ds = DatabaseService();
    await ds.init();

    var cs = ChatService();
    await cs.init();

    var ss = SettingService();
    await ss.init();

    var server = await ss.serverAddress();

    Uri? host;
    try {
      host = Uri.tryParse(server ?? '');
    } catch (e) {
      debugPrint('invalid server');
    }
    debugPrint("Ollama Client host: $host");

    _readyController.sink.add(cs);
  }
}
