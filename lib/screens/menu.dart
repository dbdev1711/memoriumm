import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/app_styles.dart';
import '../models/game_config.dart';
import 'operations_level.dart';
import 'pairs_level.dart';
import 'sequence_level.dart';
import 'number_level.dart';
import 'alphabet_level.dart';
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
    ).then((_) {
      _loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Memoriumm', style: AppStyles.appBarText),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ...GameMode.values.map((mode) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: () => _navigateToModeSelection(context, mode),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 110),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mode.getTitle(_currentLang),
                            style: const TextStyle(
                              fontSize: 24, // Text del títol més gran
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mode.getDescription(_currentLang),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}