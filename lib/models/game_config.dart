enum GameMode {
  classicMatch,
  sequenceRecall,
  numberRecall,
  operations,
  //alphabetRecall,
  profile;

  static const Map<GameMode, Map<String, String>> _titles = {
    GameMode.classicMatch: {
      'cat': 'Parelles',
      'esp': 'Parejas',
      'eng': 'Pairs',
    },
    GameMode.sequenceRecall: {
      'cat': 'Seqüència',
      'esp': 'Secuencia',
      'eng': 'Sequence',
    },
    GameMode.numberRecall: {
      'cat': 'Numèric',
      'esp': 'Numérico',
      'eng': 'Numbers',
    },
    GameMode.operations: {
      'cat': 'Operacions',
      'esp': 'Operaciones',
      'eng': 'Operations',
    },
    /*GameMode.alphabetRecall: {
      'cat': 'Alfabètic',
      'esp': 'Alfabético',
      'eng': 'Alphabet',
    },*/
    GameMode.profile: {
      'cat': 'Perfil',
      'esp': 'Perfil',
      'eng': 'Profile',
    },
  };

  static const Map<GameMode, Map<String, String>> _descriptions = {
    GameMode.classicMatch: {
      'cat': 'Troba les parelles',
      'esp': 'Encuentra las parejas',
      'eng': 'Get the pairs',
    },
    GameMode.sequenceRecall: {
      'cat': 'Repeteix l\'ordre',
      'esp': 'Repite el orden',
      'eng': 'Repeat the order',
    },
    GameMode.numberRecall: {
      'cat': 'Recorda els números',
      'esp': 'Recuerda los números',
      'eng': 'Remember the numbers',
    },
    GameMode.operations: {
      'cat': 'Calcula i ordena',
      'esp': 'Calcula y ordena',
      'eng': 'Calculate and sort',
    },
    /*GameMode.alphabetRecall: {
      'cat': 'Recorda les lletres',
      'esp': 'Recuerda las letras',
      'eng': 'Remember the letters',
    },*/
    GameMode.profile: {
      'cat': 'Configuració i resultats',
      'esp': 'Configuración y resultados',
      'eng': 'Results and configuration',
    },
  };

  String getTitle(String lang) => _titles[this]?[lang] ?? _titles[this]?['eng'] ?? '';
  String getDescription(String lang) => _descriptions[this]?[lang] ?? _descriptions[this]?['eng'] ?? '';
}

class GameConfig {
  final GameMode mode;
  final int rows;
  final int columns;
  final String levelTitle;
  final int requiredPairs;
  final int sequenceLength;
  final int requiredNumbers;

  const GameConfig({
    required this.mode,
    this.rows = 4,
    this.columns = 4,
    this.levelTitle = 'Nivell Personalitzat',
    this.requiredPairs = 8,
    this.sequenceLength = 4,
    this.requiredNumbers = 4,
  }) : assert(rows > 0 && columns > 0);

  int get totalCards => rows * columns;
}