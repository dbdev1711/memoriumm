import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/ad_helper.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/result_panel.dart';

class OperationModel {
  final String expression;
  final int result;
  bool isSelected;

  OperationModel({
    required this.expression,
    required this.result,
    this.isSelected = false,
  });
}

class OperationsRecall extends StatefulWidget {
  final GameConfig config;
  final String language;

  const OperationsRecall({
    Key? key,
    required this.config,
    required this.language,
  }) : super(key: key);

  @override
  State<OperationsRecall> createState() => _OperationsRecallState();
}

class _OperationsRecallState extends State<OperationsRecall> {
  List<OperationModel> _operations = [];
  List<OperationModel> _userSelection = [];

  bool _showResultPanel = false;
  String _resultTitle = '';
  String _resultMessage = '';
  Color _resultColor = Colors.green;
  bool _isGameOver = false;
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  final Stopwatch _stopwatch = Stopwatch();

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
      adUnitId: AdHelper.getInterstitialAdId('operations'),
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
          debugPrint('Error carregant anunci d\'operacions: ${err.message}');
        },
      ),
    );
  }

  void _initializeGame() {
    setState(() {
      _operations.clear();
      _userSelection.clear();
      _showResultPanel = false;
      _isGameOver = false;

      _stopwatch.reset();
      _stopwatch.start();

      int count = widget.config.rows <= 2 ? 2 : (widget.config.rows <= 4 ? 4 : 6);
      final random = Random();

      while (_operations.length < count) {
        int n1, n2, res;
        String sym;
        int opType = random.nextInt(4);

        switch (opType) {
          case 0:
            n1 = random.nextInt(10) + 1;
            n2 = random.nextInt(10) + 1;
            sym = '+';
            res = n1 + n2;
            break;
          case 1:
            n1 = random.nextInt(10) + 1;
            n2 = random.nextInt(n1) + 1;
            sym = '-';
            res = n1 - n2;
            break;
          case 2:
            n1 = random.nextInt(10) + 1;
            n2 = random.nextInt(10) + 1;
            sym = '×';
            res = n1 * n2;
            break;
          case 3:
            n1 = random.nextInt(10) + 1;
            List<int> divisors = [];
            for (int i = 1; i <= n1; i++) {
              if (n1 % i == 0) divisors.add(i);
            }
            n2 = divisors[random.nextInt(divisors.length)];
            sym = '÷';
            res = n1 ~/ n2;
            break;
          default:
            res = 0; sym = ''; n1 = 0; n2 = 0;
        }

        if (!_operations.any((e) => e.result == res)) {
          _operations.add(OperationModel(expression: '$n1 $sym $n2', result: res));
        }
      }
      _operations.shuffle();
    });
  }

  Future<void> _saveStats(int timeInMillis) async {
    final prefs = await SharedPreferences.getInstance();
    String levelKey = widget.config.rows <= 2 ? "Facil" : (widget.config.rows <= 4 ? "Mitja" : "Dificil");
    String storageKey = 'time_operations_$levelKey';
    int lastBest = prefs.getInt(storageKey) ?? 99999999;

    if (timeInMillis < lastBest) {
      await prefs.setInt(storageKey, timeInMillis);
    }
  }

  void _handleSelection(OperationModel op) {
    if (_isGameOver) return;

    setState(() {
      if (op.isSelected) {
        op.isSelected = false;
        _userSelection.remove(op);
      }
      else {
        op.isSelected = true;
        _userSelection.add(op);
      }

      if (_userSelection.length == _operations.length) {
        _checkResult();
      }
    });
  }

  void _checkResult() {
    List<OperationModel> sorted = List.from(_operations);
    sorted.sort((a, b) => a.result.compareTo(b.result));

    bool win = true;
    for (int i = 0; i < sorted.length; i++) {
      if (_userSelection[i].result != sorted[i].result) {
        win = false;
        break;
      }
    }

    if (win) {
      _stopwatch.stop();
      _saveStats(_stopwatch.elapsedMilliseconds);
    }
    else {
      _stopwatch.stop();
    }

    final sec = _stopwatch.elapsed.inSeconds.remainder(60);
    final min = _stopwatch.elapsed.inMinutes;
    String timeLabel = widget.language == 'cat' ? 'Temps' : (widget.language == 'esp' ? 'Tiempo' : 'Time');
    String timeStr = min > 0 ? "\n$timeLabel: ${min}m ${sec}s" : "\n$timeLabel: ${sec}s";

    void showResultUI() {
      if (!mounted) return;
      setState(() {
        _isGameOver = true;
        _showResultPanel = true;
        _resultColor = win ? Colors.green : Colors.red;

        if (win) {
          _resultTitle = widget.language == 'cat' ? '🎉 Molt bé!' : (widget.language == 'esp' ? '🎉 ¡Muy bien!' : '🎉 Well done!');
          _resultMessage = (widget.language == 'cat' ? 'Has ordenat correctament!' : (widget.language == 'esp' ? '¡Has ordenado correctamente!' : 'Correctly sorted!')) + timeStr;
        }
        else {
          _resultTitle = '❌ Error';
          _resultMessage = widget.language == 'cat'
              ? 'L\'ordre no és correcte.'
              : (widget.language == 'esp' ? 'El orden no es correcto.' : 'Incorrect order.');
        }
      });
    }

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
    String appBarTitle = widget.language == 'cat' ? 'Operacions' : (widget.language == 'esp' ? 'Operaciones' : 'Operations');
    String instruction = widget.language == 'cat'
        ? 'Ordena de menor a major:'
        : (widget.language == 'esp' ? 'Ordena de menor a mayor:' : 'Sort in ascending:');

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: AppStyles.appBarText),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _initializeGame)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              width: double.infinity,
              color: Colors.blue.shade50,
              child: Text(instruction, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey), textAlign: TextAlign.center),
            ),
            if (_userSelection.isNotEmpty && !_isGameOver)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '${widget.language == 'cat' ? 'Seleccionats' : 'Seleccionados'}: ${_userSelection.length} / ${_operations.length}',
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _operations.length <= 2 ? 1 : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: _operations.length <= 2 ? 2.8 : 1.8,
                  ),
                  itemCount: _operations.length,
                  itemBuilder: (context, index) {
                    final op = _operations[index];
                    int orderIndex = _userSelection.indexOf(op) + 1;
                    return GestureDetector(
                      onTap: () => _handleSelection(op),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: op.isSelected ? Colors.blue.withValues(alpha:0.1): Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: op.isSelected ? Colors.blue : Colors.grey.shade300,
                            width: 3
                          ),
                          boxShadow: [
                            if (!op.isSelected)
                              BoxShadow(color: Colors.black..withValues(alpha:0.05), blurRadius: 5, offset: const Offset(0, 2))
                          ]
                        ),
                        child: Stack(
                          children: [
                            if (op.isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    '$orderIndex',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            Center(
                              child: Text(
                                op.expression,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: op.isSelected ? Colors.blue : Colors.black87
                                )
                              )
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_showResultPanel) ResultPanel(title: _resultTitle, message: _resultMessage, color: _resultColor, onRestart: _initializeGame, language: widget.language),
          ],
        ),
      ),
    );
  }
}