import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import 'number_recall.dart';

class NumberLevel extends StatelessWidget {
  final GameMode mode;
  final String language;

  const NumberLevel({Key? key, required this.mode, required this.language}) : super(key: key);

  List<GameConfig> _getConfigs() {
    return [
      GameConfig(mode: GameMode.numberRecall, rows: 3, columns: 3,
        levelTitle: language == 'cat' ? 'Fàcil (3x3)' : language == 'esp' ? 'Fácil (3x3)' : 'Easy (3x3)', requiredNumbers: 4),
      GameConfig(mode: GameMode.numberRecall, rows: 4, columns: 4,
        levelTitle: language == 'cat' ? 'Mitjà (4x4)' : language == 'esp' ? 'Medio (4x4)' : 'Medium (4x4)', requiredNumbers: 6),
      GameConfig(mode: GameMode.numberRecall, rows: 5, columns: 5,
        levelTitle: language == 'cat' ? 'Difícil (5x5)' : language == 'esp' ? 'Difícil (5x5)' : 'Hard (5x5)', requiredNumbers: 8),
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
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => NumberRecall(config: config, language: language))),
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