import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memo/screens/menu.dart';
import 'package:memo/screens/idioma.dart';
import 'styles/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  runApp(App(isFirstRun: isFirstRun));
}

class App extends StatelessWidget {
  final bool isFirstRun;
  const App({Key? key, required this.isFirstRun}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memorium',
      theme: AppStyles.lightTheme,
      home: isFirstRun ? const Idioma() : const Menu()
    );
  }
}