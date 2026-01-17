import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/app_styles.dart';
import '../models/game_config.dart';
import 'operations_level.dart';
import 'pairs_level.dart';
import 'sequence_level.dart';
import 'number_level.dart';
import 'profile.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String _currentLang = 'cat';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLang = prefs.getString('language') ?? 'cat';
      _isLoading = false;
    });
  }

  void _navigateToModeSelection(BuildContext context, GameMode mode) {
    Widget targetScreen;

    switch (mode) {
      case GameMode.classicMatch:
        targetScreen = PairsLevel(mode: mode, language: _currentLang);
        break;
      case GameMode.sequenceRecall:
        targetScreen = SequenceLevel(mode: mode, language: _currentLang);
        break;
      case GameMode.numberRecall:
        targetScreen = NumberLevel(mode: mode, language: _currentLang);
        break;
      case GameMode.operations:
        targetScreen = OperationsLevel(mode: mode, language: _currentLang);
        break;
      case GameMode.profile:
        targetScreen = Profile(language: _currentLang);
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    ).then((_) {
      _loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final modes = GameMode.values.where((m) => m.name != 'alphabetRecall').toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Memoriumm', style: AppStyles.appBarText),
        centerTitle: true,
      ),
      body: SafeArea(
        child: MediaQuery(
          // Forcem que la mida del text ignori la configuració del sistema
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: modes.map((mode) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToModeSelection(context, mode),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                mode.getTitle(_currentLang),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                mode.getDescription(_currentLang),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}