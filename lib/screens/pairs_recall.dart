import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/ad_helper.dart';
import '../widgets/result_panel.dart';
import '../models/card_item.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/card.dart';

class PairsRecall extends StatefulWidget {
  final GameConfig config;
  final String language;

  const PairsRecall({
    super.key,
    required this.config,
    required this.language,
  });

  @override
  State<PairsRecall> createState() => _PairsRecallState();
}

class _PairsRecallState extends State<PairsRecall> {
  final List<CardItem> _cards = [];
  final List<CardItem> _flippedCards = [];
  int _matchesFound = 0;
  int _totalPairsNeeded = 0;
  bool _showResultPanel = false;
  Color _resultColor = Colors.green;
  String _resultTitle = '';
  String _resultMessage = '';
  bool _isChecking = false;

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  final Stopwatch _stopwatch = Stopwatch();
  final Duration _flipDelay = const Duration(milliseconds: 600);

  final List<String> _baseCardContents = const [
    '🍎', '🍊', '🍇', '🍉', '🍓', '🥝', '🍍', '🥭',
    '🍒', '🥥', '🥑', '🥦', '🌶️', '🌽', '🍄', '🍆',
    '🧅', '🥔', '🥕', '🫑', '🥒', '🥜', '🌰', '🍞',
    '🥐', '🍕', '🌮', '🍔', '🍟', '🧀', '🥚', '🥓',
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _loadAd();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.getInterstitialAdId('parelles'),
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
          debugPrint('Error carregant anunci: ${err.message}');
        },
      ),
    );
  }

  void _initializeGame() {
    setState(() {
      _cards.clear();
      _flippedCards.clear();
      _matchesFound = 0;
      _isChecking = false;
      _showResultPanel = false;
      _stopwatch.reset();
      _stopwatch.start();

      int totalSquares = widget.config.rows * widget.config.columns;
      _totalPairsNeeded = totalSquares ~/ 2;

      List<String> shuffledEmojis = List<String>.from(_baseCardContents)..shuffle();
      List<String> selectedContent = shuffledEmojis.take(_totalPairsNeeded).toList();

      List<String> fullList = [...selectedContent, ...selectedContent];
      fullList.shuffle(Random());

      for (int i = 0; i < fullList.length; i++) {
        _cards.add(CardItem(id: i, content: fullList[i]));
      }
    });
  }

  Future<void> _saveStats(int timeInMillis) async {
    final prefs = await SharedPreferences.getInstance();
    String levelKey = widget.config.rows <= 3 ? "Facil" : (widget.config.rows <= 4 ? "Mitja" : "Dificil");
    String storageKey = 'time_parelles_$levelKey';
    int lastBest = prefs.getInt(storageKey) ?? 99999999;

    if (timeInMillis < lastBest) {
      await prefs.setInt(storageKey, timeInMillis);
    }
  }

  void _handleCardTap(CardItem card) {
    if (_isChecking || card.isFlipped || card.isMatched || _flippedCards.length >= 2) return;

    setState(() {
      int index = _cards.indexOf(card);
      _cards[index] = card.copyWith(isFlipped: true);
      _flippedCards.add(_cards[index]);

      if (_flippedCards.length == 2) {
        _isChecking = true;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    final card1 = _flippedCards[0];
    final card2 = _flippedCards[1];

    if (card1.content == card2.content) {
      Timer(_flipDelay, () {
        if (!mounted) return;
        setState(() {
          int index1 = _cards.indexWhere((c) => c.id == card1.id);
          int index2 = _cards.indexWhere((c) => c.id == card2.id);

          _cards[index1] = _cards[index1].copyWith(isMatched: true);
          _cards[index2] = _cards[index2].copyWith(isMatched: true);

          _matchesFound++;
          _flippedCards.clear();
          _isChecking = false;

          if (_matchesFound == _totalPairsNeeded) {
            _showGamePanel(win: true);
          }
        });
      });
    } else {
      Timer(_flipDelay, () {
        if (!mounted) return;
        setState(() {
          int index1 = _cards.indexWhere((c) => c.id == card1.id);
          int index2 = _cards.indexWhere((c) => c.id == card2.id);

          _cards[index1] = _cards[index1].copyWith(isFlipped: false);
          _cards[index2] = _cards[index2].copyWith(isFlipped: false);

          _flippedCards.clear();
          _isChecking = false;
        });
      });
    }
  }

  Future<void> _showGamePanel({required bool win}) async {
    if (win) {
      _stopwatch.stop();
      _saveStats(_stopwatch.elapsedMilliseconds);
    }

    void displayResult() {
      if (!mounted) return;
      setState(() {
        _showResultPanel = true;
        _resultColor = win ? Colors.green : Colors.red;

        if (win) {
          String finalTime = _formatTimeWithUnits(_stopwatch.elapsed);
          _resultTitle = widget.language == 'cat' ? '🎉 Felicitats!' : widget.language == 'esp' ? '🎉 ¡Felicidades!' : '🎉 Congratulations!';
          String timeLabel = widget.language == 'cat' ? 'Temps' : widget.language == 'esp' ? 'Tiempo' : 'Time';
          _resultMessage = '${widget.language == 'cat' ? 'Has completat el nivell!' : widget.language == 'esp' ? '¡Has completado el nivel!'
              : 'Level completed!'}\n$timeLabel: $finalTime';
        } else {
          _resultTitle = '❌ Error!';
          _resultMessage = '...';
        }
      });
    }

    bool canShowAd = await AdHelper.shouldShowAd();

    if (_isAdLoaded && _interstitialAd != null && canShowAd) {
      _interstitialAd!.show().then((_) {
        displayResult();
        _isAdLoaded = false;
        _interstitialAd = null;
      });
    } else {
      displayResult();
    }
  }

  String _formatTimeWithUnits(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds.remainder(60);
    return minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == 'cat' ? 'Parelles' : 'Pairs', style: AppStyles.appBarText),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _initializeGame)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('$_matchesFound / $_totalPairsNeeded', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double gridPadding = 12.0;
                  const double gridSpacing = 8.0;

                  final double width = constraints.maxWidth - (gridPadding * 2);
                  final double height = constraints.maxHeight - (gridPadding * 2);

                  final double totalHorizontalSpacing = gridSpacing * (widget.config.columns - 1);
                  final double totalVerticalSpacing = gridSpacing * (widget.config.rows - 1);

                  final double cellWidth = (width - totalHorizontalSpacing) / widget.config.columns;
                  final double cellHeight = (height - totalVerticalSpacing - 12) / widget.config.rows;

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(gridPadding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.config.columns,
                      crossAxisSpacing: gridSpacing,
                      mainAxisSpacing: gridSpacing,
                      childAspectRatio: cellWidth / cellHeight,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) => CardWidget(
                      card: _cards[index],
                      onTap: () => _handleCardTap(_cards[index])
                    ),
                  );
                },
              ),
            ),
            if (_showResultPanel)
              ResultPanel(
                title: _resultTitle,
                message: _resultMessage,
                color: _resultColor,
                onRestart: _initializeGame,
                language: widget.language
              ),
          ],
        ),
      ),
    );
  }
}