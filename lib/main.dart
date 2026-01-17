import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:upgrader/upgrader.dart';
import 'screens/menu.dart';
import 'screens/idioma.dart';
import 'styles/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
  final String savedLang = prefs.getString('language') ?? 'cat';

  await _initTracking();
  await MobileAds.instance.initialize();

  runApp(App(isFirstRun: isFirstRun, savedLang: savedLang));
}

Future<void> _initTracking() async {
  await Future.delayed(const Duration(milliseconds: 1000));
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

class App extends StatelessWidget {
  final bool isFirstRun;
  final String savedLang;

  const App({super.key, required this.isFirstRun, required this.savedLang});

  // Mapeig de l'idioma intern de l'app al codi ISO d'Upgrader [cite: 2025-12-30]
  String _getUpgraderCode() {
    switch (savedLang) {
      case 'esp':
        return 'es';
      case 'eng':
        return 'en';
      case 'cat':
      default:
        return 'ca';
    }
  }

  UpgraderMessages _getUpgraderMessages(String code) {
    switch (code) {
      case 'es':
        return SpanishMessages();
      case 'en':
        return EnglishMessages();
      case 'ca':
      default:
        return CatalaMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String langCode = _getUpgraderCode();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memoriumm',
      theme: AppStyles.lightTheme,
      home: UpgradeAlert(
        upgrader: Upgrader(
          languageCode: langCode,
          messages: _getUpgraderMessages(langCode),
          durationUntilAlertAgain: const Duration(days: 1),
        ),
        child: isFirstRun ? const Idioma() : const Menu(),
      ),
    );
  }
}

// UPGRADER
class CatalaMessages extends UpgraderMessages {
  CatalaMessages() : super(code: 'ca');
  @override String get body => 'Hi ha una nova versió de Memoriumm disponible.';
  @override String get title => 'Actualització disponible';
  @override String get prompt => 'Vols actualitzar ara?';
  @override String get releaseNotes => 'Notes de la versió:';
}

class SpanishMessages extends UpgraderMessages {
  SpanishMessages() : super(code: 'es');
  @override String get body => 'Hay una nueva versión de Memoriumm disponible.';
  @override String get title => 'Actualización disponible';
  @override String get prompt => '¿Quieres actualizar ahora?';
  @override String get releaseNotes => 'Notas de la versión:';
}

class EnglishMessages extends UpgraderMessages {
  EnglishMessages() : super(code: 'en');
  @override String get body => 'A new version of Memoriumm is available.';
  @override String get title => 'Update Available';
  @override String get prompt => 'Would you like to update now?';
  @override String get releaseNotes => 'Release Notes:';
}