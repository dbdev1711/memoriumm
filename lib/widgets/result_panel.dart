import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../screens/menu.dart';

class ResultPanel extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final VoidCallback onRestart;
  final VoidCallback? onBackToLevels;
  final String language; // Afegim el paràmetre d'idioma

  const ResultPanel({
    Key? key,
    required this.title,
    required this.message,
    required this.color,
    required this.onRestart,
    required this.language, // Ara és obligatori
    this.onBackToLevels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definició de traduccions internes per als botons
    final Map<String, Map<String, String>> translations = {
      'menu': {
        'cat': 'Menú',
        'esp': 'Menú',
        'eng': 'Menu',
      },
      'levels': {
        'cat': 'Nivells',
        'esp': 'Niveles',
        'eng': 'Levels',
      },
      'restart': {
        'cat': 'Reinicia',
        'esp': 'Reiniciar',
        'eng': 'Restart',
      },
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ajusta l'espai al contingut
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botó Menú
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Menu()),
                    (route) => false, // Neteja la pila de navegació
                  );
                },
                child: Text(
                  translations['menu']![language] ?? 'Menu',
                  style: AppStyles.textButtonDialog,
                ),
              ),
              const SizedBox(width: 8),
              // Botó Nivells
              TextButton(
                onPressed: onBackToLevels ?? () => Navigator.pop(context),
                child: Text(
                  translations['levels']![language] ?? 'Levels',
                  style: AppStyles.textButtonDialog,
                ),
              ),
              const SizedBox(width: 8),
              // Botó Reinicia
              TextButton(
                onPressed: onRestart,
                child: Text(
                  translations['restart']![language] ?? 'Restart',
                  style: AppStyles.textButtonDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}