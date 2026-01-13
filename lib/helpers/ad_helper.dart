import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AdHelper {
  // Clau constant per a la memòria
  static const String _kGameCounterKey = 'game_counter_persistent';
  // Nova freqüència de 7 jocs
  static const int adFrequency = 7;

  /// Ara és asíncron per poder llegir de SharedPreferences
  static Future<bool> shouldShowAd() async {
    final prefs = await SharedPreferences.getInstance();

    // Obtenim el valor guardat (si no existeix, és 0)
    int currentCounter = prefs.getInt(_kGameCounterKey) ?? 0;

    currentCounter++;

    if (currentCounter >= adFrequency) {
      // Reiniciem el comptador a la memòria i retornem true
      await prefs.setInt(_kGameCounterKey, 0);
      return true;
    } else {
      // Guardem el nou valor i retornem false
      await prefs.setInt(_kGameCounterKey, currentCounter);
      return false;
    }
  }

  static String getInterstitialAdId(String gameType) {
    if (Platform.isAndroid) {
      switch (gameType) {
        case 'alphabet':
          return 'ca-app-pub-5400203683183472/7703450299';
        case 'numbers':
          return 'ca-app-pub-5400203683183472/1161274431';
        case 'operations':
          return 'ca-app-pub-5400203683183472/4853107436';
        case 'parelles':
          return 'ca-app-pub-5400203683183472/2554247152';
        case 'sequence':
          return 'ca-app-pub-5400203683183472/4022584950';
        default:
          return 'ca-app-pub-3940256099942544/1033173712';
      }
    } else if (Platform.isIOS) {
      switch (gameType) {
        case 'alphabet':
          return 'ca-app-pub-5400203683183472/3667663051';
        case 'numbers':
          return 'ca-app-pub-5400203683183472/5332098517';
        case 'operations':
          return 'ca-app-pub-5400203683183472/7606908064';
        case 'parelles':
          return 'ca-app-pub-5400203683183472/5551590369';
        case 'sequence':
          return 'ca-app-pub-5400203683183472/2925427023';
        default:
          return 'ca-app-pub-5400203683183472/8351113712';
      }
    } else {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
  }
}