import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

import '../models/card_item.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/card.dart';
import '../widgets/result_panel.dart';

class NumberRecall extends StatefulWidget {
  final GameConfig config;
  final String language; // Afegit

  const NumberRecall({Key? key, required this.config, required this.language}) : super(key: key);

  @override
  State<NumberRecall> createState() => _NumberRecallState();
}

class _NumberRecallState extends State<NumberRecall> {
  List<CardItem> _cards = [];
  List<int> _numberSequence = [];
  int _currentNumberToFind = 1;
  int _gameState = 0; // 0 = Memorització, 1 = Jugant, 2 = Finalitzat

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
      _numberSequence.clear();
      _currentNumberToFind = 1;
      _showResultPanel = false;
      _gameState = 0;

      int totalCells = widget.config.rows * widget.config.columns;
      int requiredNumbers = widget.config.requiredNumbers;

      if (requiredNumbers > totalCells) {
        requiredNumbers = totalCells;
      }

      _numberSequence = List.generate(requiredNumbers, (index) => index + 1);
      List<int> availableIndices = List.generate(totalCells, (index) => index);
      availableIndices.shuffle(Random());

      List<int> numberIndices = availableIndices.sublist(0, requiredNumbers);

      for (int i = 0; i < totalCells; i++) {
        bool isNumberCard = numberIndices.contains(i);
        String content = isNumberCard
            ? _numberSequence[numberIndices.indexOf(i)].toString()
            : '';
        _cards.add(CardItem(
          id: i,
          content: content,
          isFlipped: isNumberCard,
          isMatched: false,
        ));
      }
    });

    _startMemorizationTimer();
  }

  void _startMemorizationTimer() {
    Timer(_memorizationTime, () {
      if (!mounted) return;
      setState(() {
        _cards = _cards.map((card) => card.copyWith(isFlipped: false)).toList();
        _gameState = 1;
      });
    });
  }

  void _handleCardTap(CardItem card) {
    if (_gameState != 1 || card.isFlipped || card.isMatched) return;

    if (card.content == _currentNumberToFind.toString()) {
      setState(() {
        int index = _cards.indexOf(card);
        _cards[index] = card.copyWith(isFlipped: true, isMatched: true);
        _currentNumberToFind++;
        if (_currentNumberToFind > widget.config.requiredNumbers) {
          _gameState = 2;
          _revealAllCards();
          _showGamePanel(true);
        }
      });
    }
    else {
      setState(() {
        int index = _cards.indexOf(card);
        _cards[index] = card.copyWith(isFlipped: true);
        _gameState = 2;
        _revealAllCards();
        _showGamePanel(false);
      });
    }
  }

  void _revealAllCards() {
    setState(() {
      _cards = _cards.map((card) => card.copyWith(isFlipped: true)).toList();
    });
  }

  void _showGamePanel(bool win) {
    setState(() {
      _showResultPanel = true;
      _resultColor = win ? Colors.green : Colors.red;

      if (win) {
        _resultTitle = widget.language == 'cat' ? '🏆 Memòria Completa!' : widget.language == 'esp' ? '🏆 ¡Memoria Completa!' : '🏆 Perfect Memory!';
        _resultMessage = widget.language == 'cat'
            ? 'Has memoritzat els números correctament.'
            : widget.language == 'esp'
              ? 'Has memorizado los números correctamente.'
              : 'You have memorized the numbers correctly.';
      } else {
        _resultTitle = widget.language == 'cat' ? '❌ Error!' : widget.language == 'esp' ? '❌ ¡Error!' : '❌ Error!';
        _resultMessage = widget.language == 'cat'
            ? 'El número correcte era el $_currentNumberToFind.'
            : widget.language == 'esp'
              ? 'El número correcto era el $_currentNumberToFind.'
              : 'The correct number was $_currentNumberToFind.';
      }
    });
  }

  String _getGameStateText() {
    if (_gameState == 0) {
      return widget.language == 'cat' ? 'Memoritzant (${_memorizationTime.inSeconds}s)...' :
             widget.language == 'esp' ? 'Memorizando (${_memorizationTime.inSeconds}s)...' : 'Memorizing (${_memorizationTime.inSeconds}s)...';
    }
    if (_gameState == 1) {
      return widget.language == 'cat' ? 'Busca el número: $_currentNumberToFind' :
             widget.language == 'esp' ? 'Busca el número: $_currentNumberToFind' : 'Find the number: $_currentNumberToFind';
    }
    if (_gameState == 2) {
      return widget.language == 'cat' ? 'Joc finalitzat' : widget.language == 'esp' ? 'Juego finalizado' : 'Game finished';
    }
    return '...';
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = widget.language == 'cat' ? 'Numèric' : widget.language == 'esp' ? 'Numérico' : 'Numbers';

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
          Container(
            padding: const EdgeInsets.all(20.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _gameState == 0
                  ? Colors.orange.shade50
                  : Colors.blue.shade50,
            ),
            child: Text(
              _getGameStateText(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _gameState == 0
                    ? Colors.orange.shade900
                    : Colors.blue.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: IgnorePointer(
                ignoring: _gameState == 0 || _gameState == 2,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.config.columns,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
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