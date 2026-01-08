import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import '../screens/menu.dart';
import '../screens/idioma.dart';
import 'styles/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Es recomana inicialitzar les preferències el més aviat possible
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  // L'ordre és important: primer el tracking, després els anuncis
  await _initTracking();

  // Inicialització de Google Ads
  await MobileAds.instance.initialize();
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ["69B5C8BFFA8C4CC0CA334A51DA5028DA"],
    ),
  );

  runApp(MyApp(isFirstRun: isFirstRun));
}

Future<void> _initTracking() async {
  // Apple recomana esperar un moment a que l'app estigui activa
  // per assegurar que el diàleg de permís es mostri correctament.
  await Future.delayed(const Duration(milliseconds: 1000));

  final status = await AppTrackingTransparency.trackingAuthorizationStatus;

  if (status == TrackingStatus.notDetermined) {
    // Això mostra el pop-up nadiu d'iOS
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

class MyApp extends StatelessWidget {
  final bool isFirstRun;
  const MyApp({Key? key, required this.isFirstRun}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memoriumm',
      theme: AppStyles.lightTheme,
      home: isFirstRun ? const Idioma() : const Menu(),
    );
  }
}