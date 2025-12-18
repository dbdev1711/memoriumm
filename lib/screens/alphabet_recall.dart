import 'package:flutter/material.dart';
import 'dart:math';

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
  String _currentLetterToFind = 'A';
  int _gameState = 0;

  bool _showResultPanel = false;
  String _resultTitle = '';
  String _resultMessage = '';
  Color _resultColor = Colors.green;

  late Duration _memorizationTime;

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
      _alphabetSequence.clear();
      _currentLetterToFind = 'A';
      _gameState = 0;
      _showResultPanel = false;

      int totalCells = widget.config.rows * widget.config.columns;
      int requiredLetters = widget.config.requiredNumbers;

      if (requiredLetters > 26 || requiredLetters > totalCells) {
        requiredLetters = min(26, totalCells);
      }

      _alphabetSequence = List.generate(
        requiredLetters,
        (index) => String.fromCharCode('A'.codeUnitAt(0) + index),
      );

      List<int> availableIndices = List.generate(totalCells, (index) => index);
      availableIndices.shuffle(Random());
      List<int> letterIndices = availableIndices.sublist(0, requiredLetters);

      for (int i = 0; i < totalCells; i++) {
        bool isLetterCard = letterIndices.contains(i);
        String content = isLetterCard
            ? _alphabetSequence[letterIndices.indexOf(i)]
            : '';
        _cards.add(CardItem(
          id: i,
          content: content,
          isFlipped: isLetterCard,
          isMatched: false,
        ));
      }
    });

    _startMemorizationTimer();
  }

  void _startMemorizationTimer() {
    Future.delayed(_memorizationTime, () {
      if (!mounted) return;
      setState(() {
        _cards =
            _cards.map((card) => card.copyWith(isFlipped: false)).toList();
        _gameState = 1;
      });
    });
  }

  String _getNextLetter(String current) {
    if (current.isEmpty) return 'A';
    int code = current.codeUnitAt(0);
    return String.fromCharCode(code + 1);
  }

  void _handleCardTap(CardItem card) {
    if (_gameState != 1 || card.isFlipped || card.isMatched) return;

    if (card.content == _currentLetterToFind) {
      setState(() {
        _cards[_cards.indexOf(card)] =
            card.copyWith(isFlipped: true, isMatched: true);

        String nextLetter = _getNextLetter(_currentLetterToFind);
        if (_alphabetSequence.contains(nextLetter)) {
          _currentLetterToFind = nextLetter;
        } else {
          _gameState = 2;
          _revealAllCards();
          _showGamePanel(true);
        }
      });
    } else {
      setState(() {
        _cards[_cards.indexOf(card)] = card.copyWith(isFlipped: true);
        _gameState = 2;
        _revealAllCards();
        _showGamePanel(false);
      });
    }
  }

  void _revealAllCards() {
    _cards = _cards.map((c) => c.copyWith(isFlipped: true)).toList();
  }

  void _showGamePanel(bool win) {
    setState(() {
      _showResultPanel = true;
      _resultColor = win ? Colors.green : Colors.red;

      if (win) {
        _resultTitle = widget.language == 'cat' ? '🏆 Enhorabona!' : widget.language == 'esp' ? '🏆 ¡Enhorabuena!' : '🏆 Congratulations!';
        _resultMessage = widget.language == 'cat'
            ? 'Has memoritzat ${widget.config.requiredNumbers} lletres correctament!'
            : widget.language == 'esp'
              ? '¡Has memorizado ${widget.config.requiredNumbers} letras correctamente!'
              : 'You memorized ${widget.config.requiredNumbers} letters correctly!';
      } else {
        _resultTitle = widget.language == 'cat' ? '❌ Error!' : widget.language == 'esp' ? '❌ ¡Error!' : '❌ Error!';
        _resultMessage = widget.language == 'cat'
            ? 'Has fallat. La lletra correcta era $_currentLetterToFind.'
            : widget.language == 'esp'
              ? 'Has fallado. La letra correcta era $_currentLetterToFind.'
              : 'Wrong guess. The correct letter was $_currentLetterToFind.';
      }
    });
  }

  String _getGameStateText() {
    if (_gameState == 0) {
      return widget.language == 'cat' ? 'Memoritzant (${_memorizationTime.inSeconds}s)...' :
             widget.language == 'esp' ? 'Memorizando (${_memorizationTime.inSeconds}s)...' : 'Memorizing (${_memorizationTime.inSeconds}s)...';
    }
    if (_gameState == 1) {
      return widget.language == 'cat' ? 'Clica la lletra: $_currentLetterToFind' :
             widget.language == 'esp' ? 'Pulsa la letra: $_currentLetterToFind' : 'Tap the letter: $_currentLetterToFind';
    }
    if (_gameState == 2) {
      return widget.language == 'cat' ? 'Joc finalitzat' : widget.language == 'esp' ? 'Juego finalizado' : 'Game finished';
    }
    return '...';
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = widget.language == 'cat' ? 'Alfabètic' : widget.language == 'esp' ? 'Alfabético' : 'Alphabet';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: AppStyles.appBarText),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _gameState == 0 ? null : _initializeGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _getGameStateText(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.config.columns,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return CardWidget(
                    key: ValueKey(card.id),
                    card: card,
                    onTap: () => _handleCardTap(card),
                    isNumberMode: true,
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
              language: widget.language, // Recorda passar l'idioma també al ResultPanel si el vols traduir
            ),
        ],
      ),
    );
  }
}