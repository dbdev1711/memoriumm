import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import 'parelles_recall.dart';

class ParellesLevel extends StatelessWidget {
  final GameMode mode;
  final String language;

  const ParellesLevel({Key? key, required this.mode, required this.language}) : super(key: key);

  List<GameConfig> _getConfigs() {
    return [
      GameConfig(mode: GameMode.classicMatch, rows: 4, columns: 4,
        levelTitle: language == 'cat' ? 'Fàcil (4x4)' : language == 'esp' ? 'Fácil (4x4)' : 'Easy (4x4)'),
      GameConfig(mode: GameMode.classicMatch, rows: 6, columns: 6,
        levelTitle: language == 'cat' ? 'Mitjà (6x6)' : language == 'esp' ? 'Medio (6x6)' : 'Medium (6x6)'),
      GameConfig(mode: GameMode.classicMatch, rows: 8, columns: 8,
        levelTitle: language == 'cat' ? 'Difícil (8x8)' : language == 'esp' ? 'Difícil (8x8)' : 'Hard (8x8)'),
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
                  builder: (context) => ParellesRecall(config: config, language: language))),
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 60)),
                child: Text(config.levelTitle, style: AppStyles.levelText),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}