import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {

  static DatabaseService? instance;

  DatabaseService._();

  factory DatabaseService() => instance ??= DatabaseService._();

  init() async {
    await Hive.initFlutter();
  }
  
}