import 'package:flutter/material.dart';
import 'dart:math';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import '../widgets/result_panel.dart';

class OperationsRecall extends StatefulWidget {
  final GameConfig config;
  final String language;

  const OperationsRecall({Key? key, required this.config, required this.language}) : super(key: key);

  @override
  State<OperationsRecall> createState() => _OperationsRecallState();
}

class _OperationsRecallState extends State<OperationsRecall> {
  final TextEditingController _controller = TextEditingController();
  int _currentStep = 0;
  int _score = 0;
  bool _showResult = false;
  late int _num1, _num2, _correctAnswer;
  late String _operationSymbol;

  @override
  void initState() {
    super.initState();
    _generateOperation();
  }

  void _generateOperation() {
    final random = Random();
    _num1 = random.nextInt(10) + 1;
    _num2 = random.nextInt(10) + 1;

    // Tria entre suma i resta
    if (random.nextBool()) {
      _operationSymbol = '+';
      _correctAnswer = _num1 + _num2;
    } else {
      _operationSymbol = '-';
      if (_num1 < _num2) {
        final temp = _num1;
        _num1 = _num2;
        _num2 = temp;
      }
      _correctAnswer = _num1 - _num2;
    }
    _controller.clear();
  }

  void _checkAnswer() {
    int? userAnswer = int.tryParse(_controller.text);
    if (userAnswer == _correctAnswer) {
      _score++;
    }

    if (_currentStep + 1 < widget.config.sequenceLength!) {
      setState(() {
        _currentStep++;
        _generateOperation();
      });
    } else {
      setState(() {
        _showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Traduccions d'interfície
    String labelSolve = widget.language == 'cat' ? 'Resol:' : widget.language == 'esp' ? 'Resuelve:' : 'Solve:';
    String labelNext = widget.language == 'cat' ? 'Següent' : widget.language == 'esp' ? 'Siguiente' : 'Next';
    String labelFinish = widget.language == 'cat' ? 'Finalitzar' : widget.language == 'esp' ? 'Finalizar' : 'Finish';
    String labelStep = widget.language == 'cat' ? 'Operació' : widget.language == 'esp' ? 'Operación' : 'Operation';

    // Missatges del ResultPanel
    String resultTitle = widget.language == 'cat' ? 'Resultat' : widget.language == 'esp' ? 'Resultado' : 'Result';
    String resultMessage = widget.language == 'cat'
        ? 'Has encertat $_score de ${widget.config.sequenceLength} operacions.'
        : widget.language == 'esp'
            ? 'Has acertado $_score de ${widget.config.sequenceLength} operaciones.'
            : 'You got $_score out of ${widget.config.sequenceLength} correct.';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.levelTitle, style: AppStyles.appBarText),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$labelStep: ${_currentStep + 1} / ${widget.config.sequenceLength}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 20),
                Text(labelSolve, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 10),
                Text('$_num1 $_operationSymbol $_num2 = ?',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  autofocus: true,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _checkAnswer,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                  child: Text(_currentStep + 1 < widget.config.sequenceLength! ? labelNext : labelFinish),
                ),
              ],
            ),
          ),
          if (_showResult)
            ResultPanel(
              title: resultTitle,
              message: resultMessage,
              color: _score >= (widget.config.sequenceLength! / 2) ? Colors.green : Colors.orange,
              onRestart: () {
                setState(() {
                  _currentStep = 0;
                  _score = 0;
                  _showResult = false;
                  _generateOperation();
                });
              },
              language: widget.language,
            ),
        ],
      ),
    );
  }
}