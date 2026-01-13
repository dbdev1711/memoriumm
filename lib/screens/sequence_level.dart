import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import 'sequence_recall.dart';

class SequenceLevel extends StatelessWidget {
  final GameMode mode;
  final String language;

  const SequenceLevel({super.key, required this.mode, required this.language});

  List<GameConfig> _getConfigs() {
    return [
      GameConfig(mode: GameMode.sequenceRecall, rows: 3, columns: 3,
        levelTitle: language == 'cat' ? 'Fàcil (3x3)' : language == 'esp' ? 'Fácil (3x3)' : 'Easy (3x3)', sequenceLength: 3),
      GameConfig(mode: GameMode.sequenceRecall, rows: 4, columns: 4,
        levelTitle: language == 'cat' ? 'Mitjà (4x4)' : language == 'esp' ? 'Medio (4x4)' : 'Medium (4x4)', sequenceLength: 5),
      GameConfig(mode: GameMode.sequenceRecall, rows: 5, columns: 5,
        levelTitle: language == 'cat' ? 'Difícil (5x5)' : language == 'esp' ? 'Difícil (5x5)' : 'Hard (5x5)', sequenceLength: 7),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(language == 'cat' ? 'Nivell' : language == 'esp' ? 'Nivel' : 'Level', style: AppStyles.appBarText),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _getConfigs().map((config) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => SequenceRecall(config: config, language: language))),
                style: ElevatedButton.styleFrom(minimumSize: const Size(280, 60)),
                child: Text(config.levelTitle, style: AppStyles.levelText),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}