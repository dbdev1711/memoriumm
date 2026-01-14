import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AdHelper {
  static const String _kGameCounterKey = 'game_counter_persistent';
  static const int adFrequency = 7;

  static Future<bool> shouldShowAd() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCounter = prefs.getInt(_kGameCounterKey) ?? 0;
    currentCounter++;

    if (currentCounter >= adFrequency) {
      await prefs.setInt(_kGameCounterKey, 0);
      return true;
    } else {
      await prefs.setInt(_kGameCounterKey, currentCounter);
      return false;
    }
  }

  static String getInterstitialAdId(String gameType) {
    if (Platform.isAndroid) {
      switch (gameType) {
        case 'alphabet':
          return 'ca-app-pub-5400203683183472/9505402967';
        case 'numbers':
          return 'ca-app-pub-5400203683183472/8411813144';
        case 'operations':
          return 'ca-app-pub-5400203683183472/8284670697';
        case 'parelles':
          return 'ca-app-pub-5400203683183472/7084281429';
        case 'sequence':
          return 'ca-app-pub-5400203683183472/5139632606';
        default:
          return 'ca-app-pub-5400203683183472/9505402967';
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