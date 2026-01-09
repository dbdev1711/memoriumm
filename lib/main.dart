import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:upgrader/upgrader.dart';
import '../screens/menu.dart';
import '../screens/idioma.dart';
import 'styles/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  await _initTracking();

  await MobileAds.instance.initialize();
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ["69B5C8BFFA8C4CC0CA334A51DA5028DA"],
    ),
  );

  runApp(App(isFirstRun: isFirstRun));
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
  const App({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memoriumm',
      theme: AppStyles.lightTheme,
      home: UpgradeAlert(
        upgrader: Upgrader(
          languageCode: 'ca',
          messages: UpgraderMessages(code: 'ca'),
          durationUntilAlertAgain: const Duration(days: 1),
        ),
        child: isFirstRun ? const Idioma() : const Menu(),
      ),
    );
  }
}