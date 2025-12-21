import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/result_panel.dart';
import '../models/card_item.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/card.dart';

class PairsRecall extends StatefulWidget {
  final GameConfig config;
  final String language;

  const PairsRecall({
    Key? key,
    required this.config,
    required this.language,
  }) : super(key: key);

  @override
  State<PairsRecall> createState() => _PairsRecallState();
}

class _PairsRecallState extends State<PairsRecall> {
  List<CardItem> _cards = [];
  List<CardItem> _flippedCards = [];
  int _matchesFound = 0;
  int _totalPairsNeeded = 0;
  bool _showResultPanel = false;
  Color _resultColor = Colors.green;
  String _resultTitle = '';
  String _resultMessage = '';
  bool _isChecking = false;

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
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  String _formatTimeWithUnits(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds.remainder(60);
    return minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';
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

  // MODIFICAT: Funció per guardar el temps segons el nivell
  Future<void> _saveStats(int timeInMillis) async {
    final prefs = await SharedPreferences.getInstance();

    // Determinació del nivell basada en les files
    String levelKey;
    if (widget.config.rows <= 3) {
      levelKey = "Facil";
    } else if (widget.config.rows <= 4) {
      levelKey = "Mitja";
    } else {
      levelKey = "Dificil";
    }

    String storageKey = 'time_parelles_$levelKey';
    int lastBest = prefs.getInt(storageKey) ?? 99999999;

    if (timeInMillis < lastBest) {
      await prefs.setInt(storageKey, timeInMillis);
      print("Nova millor marca en $levelKey (Parelles): $timeInMillis ms");
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

  void _showGamePanel({required bool win}) {
    if (win) {
      _stopwatch.stop();
      _saveStats(_stopwatch.elapsedMilliseconds);
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == 'cat' ? 'Parelles' : 'Pairs', style: AppStyles.appBarText),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _initializeGame)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('$_matchesFound / $_totalPairsNeeded', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.config.columns,
                crossAxisSpacing: 8, mainAxisSpacing: 8,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) => CardWidget(card: _cards[index], onTap: () => _handleCardTap(_cards[index])),
            ),
          ),
          if (_showResultPanel) ResultPanel(title: _resultTitle, message: _resultMessage, color: _resultColor, onRestart: _initializeGame, language: widget.language),
        ],
      ),
    );
  }
}