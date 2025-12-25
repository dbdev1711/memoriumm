import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/ad_helper.dart';
import '../models/card_item.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/card.dart';
import '../widgets/result_panel.dart';

class AlphabetRecall extends StatefulWidget {
  final GameConfig config;
  final String language;

  const AlphabetRecall({Key? key, required this.config, required this.language}) : super(key: key);

  @override
  State<AlphabetRecall> createState() => _AlphabetRecallState();
}

class _AlphabetRecallState extends State<AlphabetRecall> {
  List<CardItem> _cards = [];
  List<String> _alphabetSequence = [];
  String _currentLetter = 'A';
  int _gameState = 0;
  bool _showResultPanel = false;
  String _resultTitle = '';
  String _resultMessage = '';
  Color _resultColor = Colors.green;
  final Stopwatch _stopwatch = Stopwatch();
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _loadAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.getInterstitialAdId('alphabet'),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadAd();
            },
          );
          if (mounted) {
            setState(() {
              _interstitialAd = ad;
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (err) {
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
          debugPrint('Error carregant anunci alfabètic: ${err.message}');
        },
      ),
    );
  }

  void _initializeGame() {
    setState(() {
      _cards.clear();
      _currentLetter = 'A';
      _gameState = 0;
      _showResultPanel = false;
      _stopwatch.reset();

      int total = widget.config.rows * widget.config.columns;
      int req = min(widget.config.requiredNumbers, 26);

      _alphabetSequence = List.generate(req, (i) => String.fromCharCode('A'.codeUnitAt(0) + i));

      List<int> idxs = List.generate(total, (i) => i)..shuffle();
      for (int i = 0; i < total; i++) {
        int pos = idxs.indexOf(i);
        _cards.add(CardItem(
          id: i,
          content: pos < req ? _alphabetSequence[pos] : '',
          isFlipped: pos < req
        ));
      }
    });

    int s = widget.config.rows <= 3 ? 2 : (widget.config.rows <= 4 ? 4 : 6);
    Future.delayed(Duration(seconds: s), () {
      if (mounted) {
        setState(() {
          _cards = _cards.map((c) => c.copyWith(isFlipped: false)).toList();
          _gameState = 1;
          _stopwatch.start();
        });
      }
    });
  }

  void _handleCardTap(CardItem card) {
    if (_gameState != 1 || card.isFlipped) return;

    if (card.content == _currentLetter) {
      setState(() {
        _cards[_cards.indexOf(card)] = card.copyWith(isFlipped: true, isMatched: true);
        if (_currentLetter == _alphabetSequence.last) {
          _stopwatch.stop();
          _finish(true);
        } else {
          _currentLetter = String.fromCharCode(_currentLetter.codeUnitAt(0) + 1);
        }
      });
    } else {
      _stopwatch.stop();
      _finish(false);
    }
  }

  Future<void> _finish(bool win) async {
    String timeStr = "";
    if (win) {
      final ms = _stopwatch.elapsedMilliseconds;
      final prefs = await SharedPreferences.getInstance();

      String levelKey = widget.config.rows <= 3 ? "Facil" : (widget.config.rows <= 4 ? "Mitja" : "Dificil");
      String storageKey = 'time_alphabet_$levelKey';

      int? currentBest = prefs.getInt(storageKey);
      if (currentBest == null || ms < currentBest) {
        await prefs.setInt(storageKey, ms);
      }

      int totalSeconds = _stopwatch.elapsed.inSeconds;
      int minTime = totalSeconds ~/ 60;
      int secTime = totalSeconds % 60;

      String label = widget.language == 'cat' ? 'Temps' : (widget.language == 'esp' ? 'Tiempo' : 'Time');
      timeStr = minTime > 0 ? "\n$label: ${minTime}m ${secTime}s" : "\n$label: ${secTime}s";
    }

    // Aquesta funció mostra la UI final
    void showResultUI() {
      if (!mounted) return;
      setState(() {
        _gameState = 2;
        _cards = _cards.map((c) => c.copyWith(isFlipped: true)).toList();
        _showResultPanel = true;
        _resultColor = win ? Colors.green : Colors.red;

        if (win) {
          _resultTitle = widget.language == 'cat' ? '🏆 Molt bé!' : widget.language == 'esp' ? '🏆 ¡Muy bien!' : '🏆 Well done!';
          _resultMessage = (widget.language == 'cat' ? 'Lletres ordenades!' : widget.language == 'esp' ? '¡Letras ordenadas!' : 'Letters sorted!') + timeStr;
        } else {
          _resultTitle = '❌ Error!';
          _resultMessage = (widget.language == 'cat' ? 'Era la lletra' : widget.language == 'esp' ? 'Era la letra' : 'It was letter') + ' $_currentLetter';
        }
      });
    }

    // Lògica de control de l'anunci: només si està carregat i el comptador diu que toca
    if (_isAdLoaded && _interstitialAd != null && AdHelper.shouldShowAd()) {
      _interstitialAd!.show().then((_) {
        showResultUI();
        _isAdLoaded = false;
        _interstitialAd = null;
      });
    } else {
      showResultUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == 'cat' ? 'Alfabètic' : widget.language == 'esp' ? 'Alfabético' : 'Alphabet',
          style: AppStyles.appBarText
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _gameState == 0 ? null : _initializeGame
          )
        ],
      ),
      body: Column(
        children: [
          AppStyles.sizedBoxHeight20,
          if (!_showResultPanel)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                _gameState == 0
                  ? (widget.language == 'cat' ? 'Memoritza les lletres' : widget.language == 'esp' ? 'Memoriza las letras' : 'Remember the letters')
                  : '${widget.language == 'cat' ? 'Troba la' : widget.language == 'esp' ? 'Encuentra la' : 'Get'} '
                    '$_currentLetter',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.config.columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, i) => CardWidget(
                card: _cards[i],
                onTap: () => _handleCardTap(_cards[i]),
                isNumberMode: false,
              ),
            ),
          ),

          if (_showResultPanel)
            ResultPanel(
              title: _resultTitle,
              message: _resultMessage,
              color: _resultColor,
              onRestart: _initializeGame,
              language: widget.language,
            ),
        ],
      ),
    );
  }
}