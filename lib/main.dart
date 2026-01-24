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

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
  final String savedLang = prefs.getString('language') ?? 'cat';

  await _initTracking();

  await MobileAds.instance.initialize();

  // CONFIGURACIÓ DE DISPOSITIUS DE PROVA
  RequestConfiguration configuration = RequestConfiguration(
    testDeviceIds: [
      "5683a286-0049-4a00-aec6-1c7bffee701b",
      "a8a55f93-ffc9-4fcc-9d65-cec416f8cc3e",
      "a44d74c2-7899-46fa-bdd4-b5b527843322",
    ],
  );
  await MobileAds.instance.updateRequestConfiguration(configuration);

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memoriumm',
      theme: AppStyles.lightTheme,
      builder: (context, child) {
        final double shortestSide = MediaQuery.of(context).size.shortestSide;
        final bool isTablet = shortestSide >= 600;

        if (!isTablet) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        } else {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        }
        return child!;
      },
      home: UpgradeAlert(
        upgrader: Upgrader(
          languageCode: _getUpgraderCode(),
          messages: _getUpgraderMessages(_getUpgraderCode()),
          durationUntilAlertAgain: const Duration(days: 1),
        ),
        child: isFirstRun ? const Idioma() : const Menu(),
      ),
    );
  }
}

// CLASSES DE MISSATGES (FORA DE LA CLASSE APP)
class CatalaMessages extends UpgraderMessages {
  @override
  String get code => 'ca';

  @override
  String? message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.body:
        return 'Hi ha una nova versió de Memoriumm disponible.';
      case UpgraderMessage.title:
        return 'Actualització disponible';
      case UpgraderMessage.prompt:
        return 'Vols actualitzar ara?';
      case UpgraderMessage.releaseNotes:
        return 'Notes de la versió:';
      case UpgraderMessage.buttonTitleIgnore:
        return 'Ignorar';
      case UpgraderMessage.buttonTitleLater:
        return 'Més tard';
      case UpgraderMessage.buttonTitleUpdate:
        return 'Actualitzar';
      default:
        return super.message(messageKey);
    }
  }
}

class SpanishMessages extends UpgraderMessages {
  @override
  String get code => 'es';

  @override
  String? message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.body:
        return 'Hay una nueva versión de Memoriumm disponible.';
      case UpgraderMessage.title:
        return 'Actualización disponible';
      case UpgraderMessage.prompt:
        return '¿Quieres actualizar ahora?';
      case UpgraderMessage.releaseNotes:
        return 'Notas de la versión:';
      case UpgraderMessage.buttonTitleIgnore:
        return 'Ignorar';
      case UpgraderMessage.buttonTitleLater:
        return 'Más tarde';
      case UpgraderMessage.buttonTitleUpdate:
        return 'Actualizar';
      default:
        return super.message(messageKey);
    }
  }
}

class EnglishMessages extends UpgraderMessages {
  @override
  String get code => 'en';

  @override
  String? message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.body:
        return 'A new version of Memoriumm is available.';
      case UpgraderMessage.title:
        return 'Update Available';
      case UpgraderMessage.prompt:
        return 'Would you like to update now?';
      case UpgraderMessage.releaseNotes:
        return 'Release Notes:';
      case UpgraderMessage.buttonTitleIgnore:
        return 'Ignore';
      case UpgraderMessage.buttonTitleLater:
        return 'Later';
      case UpgraderMessage.buttonTitleUpdate:
        return 'Update Now';
      default:
        return super.message(messageKey);
    }
  }
}