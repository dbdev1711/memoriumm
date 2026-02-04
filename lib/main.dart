import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/menu.dart';
import 'screens/idioma.dart';
import 'styles/app_styles.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Background Messaging Error: $e");
  }
}

void main() async {
  // Capturem errors del framework de Flutter
  FlutterError.onError = (details) {
    debugPrint("⚠️ FLUTTER ERROR: ${details.exception}");
    debugPrint("STACK: ${details.stack}");
  };

  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("🚀 INICIANT APLICACIÓ...");

  try {
    debugPrint("⚙️ CONFIGURANT FIREBASE...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ FIREBASE INICIALITZAT");

    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    await FirebaseAnalytics.instance.logAppOpen();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e, stack) {
    debugPrint("❌ ERROR FATAL FIREBASE: $e");
    debugPrint("STACKTRACE: $stack");
  }

  try {
    debugPrint("📂 LLEGINT PREFERÈNCIES...");
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
    final String savedLang = prefs.getString('language') ?? 'cat';
    debugPrint("✅ PREFERÈNCIES CARREGADES (FirstRun: $isFirstRun)");

    runApp(App(isFirstRun: isFirstRun, savedLang: savedLang));
  } catch (e) {
    debugPrint("❌ ERROR PREFERÈNCIES O RUNAPP: $e");
  }

  _initializeAdsOnly();
}

Future<void> _initializeAdsOnly() async {
  try {
    debugPrint("📺 INICIANT ADMOB...");
    await MobileAds.instance.initialize();
    RequestConfiguration configuration = RequestConfiguration(
      testDeviceIds: [
        "5683a286-0049-4a00-aec6-1c7bffee701b",
        "a8a55f93-ffc9-4fcc-9d65-cec416f8cc3e",
        "a44d74c2-7899-46fa-bdd4-b5b527843322",
      ],
    );
    await MobileAds.instance.updateRequestConfiguration(configuration);
    debugPrint("✅ ADMOB OK");
  } catch (e) {
    debugPrint("❌ ERROR ADMOB: $e");
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
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
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