// lib/models/game_config.dart

enum GameMode {
  classicMatch,
  sequenceRecall,
  numberRecall,
  operations,
  alphabetRecall,
  profile;

  // Diccionari de títols per idioma
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
    GameMode.alphabetRecall: {
      'cat': 'Alfabètic',
      'esp': 'Alfabético',
      'eng': 'Alphabet',
    },
    GameMode.profile: {
      'cat': 'Perfil',
      'esp': 'Perfil',
      'eng': 'Profile',
    },
  };

  // Diccionari de descripcions per idioma
  static const Map<GameMode, Map<String, String>> _descriptions = {
    GameMode.classicMatch: {
      'cat': 'Troba totes les parelles iguals.',
      'esp': 'Encuentra todas las parejas iguales.',
      'eng': 'Find all the matching pairs.',
    },
    GameMode.sequenceRecall: {
      'cat': 'Repeteix l\'ordre correcte.',
      'esp': 'Repite el orden correcto.',
      'eng': 'Repeat the correct order.',
    },
    GameMode.numberRecall: {
      'cat': 'Recorda els números per ordre.',
      'esp': 'Recuerda los números por orden.',
      'eng': 'Remember numbers in order.',
    },
    GameMode.operations: {
      'cat': 'Calcula i ordena ascendentment.',
      'esp': 'Calcula y ordena ascendentemente.',
      'eng': 'Calculate and sort ascending.',
    },
    GameMode.alphabetRecall: {
      'cat': 'Recorda les lletres per ordre.',
      'esp': 'Recuerda las letras por orden.',
      'eng': 'Remember letters in order.',
    },
    GameMode.profile: {
      'cat': 'Estadístiques i configuració.',
      'esp': 'Estadísticas y configuración.',
      'eng': 'Statistics and settings.',
    },
  };

  // Mètodes auxiliars per obtenir el text segons l'idioma actiu
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