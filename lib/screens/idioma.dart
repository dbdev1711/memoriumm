//screens/idioma.dart
import 'package:flutter/material.dart';
import 'package:memo/styles/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu.dart';

class Idioma extends StatelessWidget {
  const Idioma({Key? key}) : super(key: key);

  Future<void> _selectLanguage(BuildContext context, String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    await prefs.setBool('isFirstRun', false);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Menu()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppStyles.sizedBoxHeight40,
            const Text('Idioma:', style: AppStyles.idioma),
            _langButton(context, 'cat', 'assets/cat.png'),
            _langButton(context, 'esp', 'assets/esp.png'),
            _langButton(context, 'eng', 'assets/eng.png'),
          ],
        ),
      ),
    );
  }

  Widget _langButton(BuildContext context, String code, String assetPath) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
      child: GestureDetector(
        onTap: () => _selectLanguage(context, code),
        child: Image.asset(assetPath, width: 200, height: 120, fit: BoxFit.cover),
      ),
    );
  }
}