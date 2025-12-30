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
    }
    else if (Platform.isIOS) {
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
    }
    else {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
  }
}