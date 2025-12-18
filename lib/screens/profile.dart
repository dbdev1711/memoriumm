import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/app_styles.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key, required this.language}) : super(key: key);
  final String language;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _nomController = TextEditingController();
  String _selectedLanguage = 'cat';

  // Map per guardar els resultats dels jocs
  Map<String, int> _results = {
    'alphabet': 0,
    'number': 0,
    'operations': 0,
    'parelles': 0,
    'sequencia': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  // Carrega idioma, nom i resultats des de SharedPreferences
  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'cat';
      _nomController.text = prefs.getString('user_name') ?? '';

      // Carreguem les puntuacions (0 si no existeixen)
      _results['alphabet'] = prefs.getInt('score_alphabet') ?? 0;
      _results['number'] = prefs.getInt('score_number') ?? 0;
      _results['operations'] = prefs.getInt('score_operations') ?? 0;
      _results['parelles'] = prefs.getInt('score_parelles') ?? 0;
      _results['sequencia'] = prefs.getInt('score_sequencia') ?? 0;
    });
  }

  // Desa nom i idioma localment
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('user_name', _nomController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_selectedLanguage == 'cat' ? 'Guardat!' : '¡Guardado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = _selectedLanguage == 'cat' ? 'El meu Perfil' : _selectedLanguage == 'esp' ? 'Mi Perfil' : 'My Profile';
    final String gamesTitle = _selectedLanguage == 'cat' ? 'Rècords Personals' : 'Récords Personales';

    return Scaffold(
      appBar: AppBar(title: Text(title, style: AppStyles.appBarText), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // SECCIÓ DADES PERSONALS
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nomController,
                      decoration: InputDecoration(
                        labelText: _selectedLanguage == 'cat' ? 'Nom' : 'Nombre',
                        prefixIcon: const Icon(Icons.edit),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: InputDecoration(labelText: _selectedLanguage == 'cat' ? 'Idioma' : 'Idioma'),
                      items: const [
                        DropdownMenuItem(value: 'cat', child: Text('Català')),
                        DropdownMenuItem(value: 'esp', child: Text('Español')),
                        DropdownMenuItem(value: 'eng', child: Text('English')),
                      ],
                      onChanged: (val) => setState(() => _selectedLanguage = val!),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveSettings,
                      child: Text(_selectedLanguage == 'cat' ? 'Guardar Canvis' : 'Guardar Cambios'),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // SECCIÓ RESULTATS JOCS
            Text(gamesTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const Divider(),
            _buildResultTile('Alphabet Recall', _results['alphabet']!, Icons.abc),
            _buildResultTile('Number Recall', _results['number']!, Icons.numbers),
            _buildResultTile('Operations', _results['operations']!, Icons.calculate),
            _buildResultTile('Parelles', _results['parelles']!, Icons.extension),
            _buildResultTile('Seqüència', _results['sequencia']!, Icons.repeat),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(String gameName, int score, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(gameName),
      trailing: Text(
        '$score',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }
}