import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'menu.dart';

class Idioma extends StatelessWidget {
  const Idioma({super.key});

  Future<void> _selectLanguage(BuildContext context, String langCode) async {
    final prefs = await SharedPreferences.getInstance();

    // Recuperem l'idioma anterior per desubscriure'ns si cal
    final String? oldLang = prefs.getString('language');
    if (oldLang != null) {
      await FirebaseMessaging.instance.unsubscribeFromTopic('memorium_$oldLang');
    }

    // Guardem el nou idioma
    await prefs.setString('language', langCode);
    await prefs.setBool('isFirstRun', false);

    // Subscripció al nou tòpic segons l'elecció
    await FirebaseMessaging.instance.subscribeToTopic('memorium_$langCode');

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
        child: Image.asset(assetPath, width: 180, height: 100, fit: BoxFit.cover),
      ),
    );
  }
}