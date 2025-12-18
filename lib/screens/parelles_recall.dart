import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

import '../widgets/result_panel.dart';
import '../models/card_item.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/card.dart';

class ParellesRecall extends StatefulWidget {
  final GameConfig config;
  final String language; // Afegit

  const ParellesRecall({
    Key? key,
    required this.config,
    required this.language, // Afegit
  }) : super(key: key);

  @override
  State<ParellesRecall> createState() => _ParellesRecallState();
}

class _ParellesRecallState extends State<ParellesRecall> {
  List<CardItem> _cards = [];
  List<CardItem> _flippedCards = [];
  int _matchesFound = 0;
  int _totalPairsNeeded = 0;
  bool _showResultPanel = false;
  Color _resultColor = Colors.green;
  String _resultTitle = '';
  String _resultMessage = '';
  bool _isChecking = false;

  final Duration _flipDelay = const Duration(milliseconds: 600);
  late Duration _memorizationTime;

  final List<String> _baseCardContents = const [
    '🍎', '🍊', '🍇', '🍉', '🍓', '🥝', '🍍', '🥭',
    '🍒', '🥥', '🥑', '🥦', '🌶️', '🌽', '🍄', '🍆',
    '🧅', '🥔', '🥕', '🫑', '🥒', '🥜', '🌰', '🍞',
    '🥐', '🍕', '🌮', '🍔', '🍟', '🧀', '🥚', '🥓',
  ];

  @override
  void initState() {
    super.initState();
    _setupTimerDuration();
    _initializeGame();
  }

  void _setupTimerDuration() {
    if (widget.config.rows <= 3) {
      _memorizationTime = const Duration(seconds: 2);
    } else if (widget.config.rows <= 4) {
      _memorizationTime = const Duration(seconds: 4);
    } else {
      _memorizationTime = const Duration(seconds: 6);
    }
  }

  void _initializeGame() {
    setState(() {
      _cards.clear();
      _flippedCards.clear();
      _matchesFound = 0;
      _isChecking = false;
      _showResultPanel = false;

      int totalSquares = widget.config.rows * widget.config.columns;
      _totalPairsNeeded = totalSquares ~/ 2;

      int pairsToUse = _totalPairsNeeded;
      if (pairsToUse > _baseCardContents.length) {
        pairsToUse = _baseCardContents.length;
      }

      List<String> shuffledEmojis = List<String>.from(_baseCardContents)
        ..shuffle();
      List<String> selectedContent = shuffledEmojis.take(pairsToUse).toList();

      List<String> fullList = [...selectedContent, ...selectedContent];
      fullList.shuffle(Random());

      for (int i = 0; i < fullList.length; i++) {
        _cards.add(CardItem(id: i, content: fullList[i]));
      }
    });
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

  void _revealAllCards() {
    setState(() {
      _cards = _cards.map((c) => c.copyWith(isFlipped: true)).toList();
    });
  }

  void _showGamePanel({required bool win}) {
    _revealAllCards();
    setState(() {
      _showResultPanel = true;
      _resultColor = win ? Colors.green : Colors.red;

      if (win) {
        _resultTitle = widget.language == 'cat' ? '🎉 Felicitats!' : widget.language == 'esp' ? '🎉 ¡Felicidades!' : '🎉 Congratulations!';
        _resultMessage = widget.language == 'cat'
            ? 'Has completat el nivell amb èxit!'
            : widget.language == 'esp'
                ? '¡Has completado el nivel con éxito!'
                : 'You have successfully completed the level!';
      } else {
        _resultTitle = widget.language == 'cat' ? '❌ Error!' : widget.language == 'esp' ? '❌ ¡Error!' : '❌ Error!';
        _resultMessage = widget.language == 'cat'
            ? 'Torna-ho a provar.'
            : widget.language == 'esp'
                ? 'Vuelve a intentarlo.'
                : 'Try again.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = widget.language == 'cat' ? 'Parelles' : widget.language == 'esp' ? 'Parejas' : 'Pairs';
    String pairsText = widget.language == 'cat' ? 'Parelles' : widget.language == 'esp' ? 'Parejas' : 'Pairs';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: AppStyles.appBarText),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isChecking ? null : _initializeGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              '$pairsText: $_matchesFound / $_totalPairsNeeded',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.config.columns,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return CardWidget(
                    key: ValueKey(_cards[index].id),
                    card: _cards[index],
                    onTap: () => _handleCardTap(_cards[index]),
                  );
                },
              ),
            ),
          ),
          if (_showResultPanel)
            ResultPanel(
              title: _resultTitle,
              message: _resultMessage,
              color: _resultColor,
              onRestart: _initializeGame,
              language: widget.language, // Passat al ResultPanel
            ),
        ],
      ),
    );
  }
}