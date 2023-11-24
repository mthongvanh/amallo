import 'package:amallo/extensions/colors.dart';
import 'package:amallo/screens/splash.dart';
import 'package:amallo/utils/utils.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: MouseTouchScrollBehavior(),
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        colorScheme: ColorScheme.dark(primary: AppColors.turquoise),
      ),
      home: const Scaffold(
        body: SplashScreen(),
      ),
    );
  }
}
