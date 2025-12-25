import 'dart:io';

class AdHelper {

  static int _gameCounter = 0;
  static const int adFrequency = 4;

  static bool shouldShowAd() {
    _gameCounter++;
    if (_gameCounter >= adFrequency) {
      _gameCounter = 0;
      return true;
    }
    return false;
  }

  static String getInterstitialAdId(String gameType) {
    if (Platform.isAndroid) {
      switch (gameType) {
        case 'alphabet':
          return 'ca-app-pub-5335679604691429/4097455197';
        case 'numbers':
          return 'ca-app-pub-5335679604691429/6034171635';
        case 'operations':
          return 'ca-app-pub-5335679604691429/6452155798';
        case 'parelles':
          return 'ca-app-pub-5335679604691429/8966638495';
        case 'sequence':
          return 'ca-app-pub-5335679604691429/5139074123';
        default:
          return 'ca-app-pub-3940256099942544/1033173712';
      }
    }
    else {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
  }
}