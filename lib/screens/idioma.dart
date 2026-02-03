import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'menu.dart';

class Idioma extends StatelessWidget {
  const Idioma({super.key});

  Future<void> _selectLanguage(BuildContext context, String langCode) async {
    final prefs = await SharedPreferences.getInstance();

    final String? oldLang = prefs.getString('language');
    if (oldLang != null) {
      await FirebaseMessaging.instance.unsubscribeFromTopic('memorium_$oldLang');
    }

    await prefs.setString('language', langCode);
    await prefs.setBool('isFirstRun', false);
    await FirebaseMessaging.instance.subscribeToTopic('memorium_$langCode');

    if (context.mounted) {
      await _showPrePrompt(context, langCode);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Menu()),
      );
    }
  }

  Future<void> _showPrePrompt(BuildContext context, String lang) async {
    String title = "Notificacions";
    String content = "T'agradaria rebre avisos importants?\nPrem 'Permetre' en el següent missatge.";
    String button = "ENTÈS";

    if (lang == 'esp') {
      title = "Notificaciones";
      content = "¿Te gustaría recibir avisos importantes?\nPulsa 'Permitir' en el siguiente mensaje.";
      button = "ENTENDIDO";
    } else if (lang == 'eng') {
      title = "Notifications";
      content = "Would you like to receive important alerts?\nTap 'Allow' on the next screen.";
      button = "GOT IT";
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(button),
          ),
        ],
      ),
    );

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      debugPrint("------------------------------------------");
      debugPrint("TOKEN FCM GENERAT ($lang): $token");
      debugPrint("------------------------------------------");
    }

    await _requestTracking();
  }

  Future<void> _requestTracking() async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint("Error ATT: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
        onTap: () => _selectLanguage(context, code),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(assetPath, width: 180, height: 100, fit: BoxFit.cover),
        ),
      ),
    );
  }
}