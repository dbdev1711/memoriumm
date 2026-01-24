import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/menu.dart';
import 'screens/idioma.dart';
import 'styles/app_styles.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
  final String savedLang = prefs.getString('language') ?? 'cat';

  await _initTracking();
  await MobileAds.instance.initialize();

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