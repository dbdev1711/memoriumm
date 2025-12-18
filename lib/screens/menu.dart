import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memo/styles/app_styles.dart';
import '../models/game_config.dart';
import 'operations_level.dart';
import 'parelles_level.dart';
import 'sequencia_level.dart';
import 'number_level.dart';
import 'alphabet_level.dart';
import 'profile.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String _currentLang = 'cat'; // Idioma per defecte per evitar errors de null
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Carrega l'idioma seleccionat prèviament per l'usuari
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLang = prefs.getString('language') ?? 'cat';
      _isLoading = false;
    });
  }

  /// Gestiona la navegació passant l'idioma a la següent pantalla
  void _navigateToModeSelection(BuildContext context, GameMode mode) {
    Widget targetScreen;

    switch (mode) {
      case GameMode.classicMatch:
        targetScreen = ParellesLevel(mode: mode, language: _currentLang);
        break;
      case GameMode.sequenceRecall:
        targetScreen = SequenciaLevel(mode: mode, language: _currentLang);
        break;
      case GameMode.numberRecall:
        targetScreen = NumberLevel(mode: mode, language: _currentLang);
        break;
      case GameMode.alphabetRecall:
        targetScreen = AlphabetLevel(mode: mode, language: _currentLang);
        break;
      case GameMode.operations:
        targetScreen = OperationsLevel(mode: mode, language: _currentLang);
        break;
      case GameMode.profile:
        targetScreen = Profile(language: _currentLang);
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Memorium', style: AppStyles.appBarText),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Generem la llista de botons dinàmicament a partir de l'Enum
              ...GameMode.values.map((mode) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () => _navigateToModeSelection(context, mode),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(160, 80),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mode.getTitle(_currentLang),
                          style: AppStyles.menuButtonTitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mode.getDescription(_currentLang),
                          style: AppStyles.menuButtonDesc,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}