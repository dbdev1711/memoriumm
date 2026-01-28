import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/menu.dart';
import 'screens/idioma.dart';
import 'styles/app_styles.dart';

// Handler per a missatges en segon pla
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase background error: $e");
  }
}

void main() async {
  // 1. Inicialització essencial de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase: Inicialització bàsica sense bloquejar
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("Firebase initialization skipped: $e");
  }

  // 3. Preferències locals (molt ràpid)
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
  final String savedLang = prefs.getString('language') ?? 'cat';

  // 4. LLANÇAMENT DE LA UI: Això elimina la pantalla en blanc a iOS
  runApp(App(isFirstRun: isFirstRun, savedLang: savedLang));

  // 5. Serveis asíncrons: Es carreguen mentre l'usuari ja veu l'app
  _initializeServicesAsync();
}

/// Executa les peticions pesades sense congelar el fil principal
Future<void> _initializeServicesAsync() async {
  // A. Permisos de notificacions (no demanats a Android, bloquejaven iOS)
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    debugPrint("Messaging permission error: $e");
  }

  // B. Tracking Transparency (el retard d'1s ara no afecta l'arrencada)
  await _initTracking();

  // C. AdMob: Inicialització amb la limitació d'anuncis activa
  try {
    await MobileAds.instance.initialize();
    RequestConfiguration configuration = RequestConfiguration(
      testDeviceIds: [
        "5683a286-0049-4a00-aec6-1c7bffee701b",
        "a8a55f93-ffc9-4fcc-9d65-cec416f8cc3e",
        "a44d74c2-7899-46fa-bdd4-b5b527843322",
      ],
    );
    await MobileAds.instance.updateRequestConfiguration(configuration);
  } catch (e) {
    debugPrint("AdMob error: $e");
  }
}

Future<void> _initTracking() async {
  // Esperem un segon perquè la UI ja estigui muntada
  await Future.delayed(const Duration(milliseconds: 1000));
  try {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  } catch (e) {
    debugPrint("Tracking error: $e");
  }
}

class App extends StatelessWidget {
  final bool isFirstRun;
  final String savedLang;

  const App({super.key, required this.isFirstRun, required this.savedLang});

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
      home: isFirstRun ? const Idioma() : const Menu(),
    );
  }
}