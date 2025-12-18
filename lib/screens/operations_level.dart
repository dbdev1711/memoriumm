import 'package:flutter/material.dart';
import '../models/game_config.dart';
import '../styles/app_styles.dart';
import 'operations_recall.dart';

class OperationsLevel extends StatelessWidget {
  final GameMode mode;
  final String language;

  const OperationsLevel({Key? key, required this.mode, required this.language}) : super(key: key);

  List<GameConfig> _getConfigs() {
    return [
      GameConfig(mode: GameMode.operations, sequenceLength: 4,
        levelTitle: language == 'cat' ? 'Fàcil (4 op.)' : language == 'esp' ? 'Fácil (4 op.)' : 'Easy (4 op.)'),
      GameConfig(mode: GameMode.operations, sequenceLength: 6,
        levelTitle: language == 'cat' ? 'Mitjà (6 op.)' : language == 'esp' ? 'Medio (6 op.)' : 'Medium (6 op.)'),
      GameConfig(mode: GameMode.operations, sequenceLength: 8,
        levelTitle: language == 'cat' ? 'Difícil (8 op.)' : language == 'esp' ? 'Difícil (8 op.)' : 'Hard (8 op.)'),
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
                  builder: (context) => OperationsRecall(config: config, language: language))),
                style: ElevatedButton.styleFrom(minimumSize: const Size(250, 60)),
                child: Text(config.levelTitle, style: AppStyles.levelText),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}