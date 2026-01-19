import 'package:flutter/material.dart';

class AppStyles {
  static const Color primaryColor = Colors.black;
  static const Color secondaryColor = Colors.teal;
  static const Color accentColor = Colors.amber;
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Color(0xFFFFFBFE);

  static const appName = TextStyle(
    fontSize: 50,
    fontWeight: FontWeight.bold,
    color: Colors.white
  );

  static const idioma = TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.bold,
    color: Colors.black
  );

  static const appBarText = TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.bold,
    color: Colors.white
  );

  static const menuButtonTitle = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: Colors.white
  );

  static const menuButtonDesc = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.white
  );

  static const profileSnackBar = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.white
  );

  static const levelText = TextStyle(
    fontSize: 25,
    color: Colors.white
  );

  static const saveButton = TextStyle(
    fontSize: 18,
    color: Colors.white
  );

  static const resultsProfile = TextStyle(
    fontSize: 35,
    color: Colors.black,
    fontWeight: FontWeight.bold
  );

  static const textButtonDialog = TextStyle(
    fontSize: 18,
    color: Colors.black
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: Colors.yellow,
      surface: surfaceColor,
    ),
    // AppBar
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.blueAccent,
      elevation: 8,
      centerTitle: true,
    ),
    // Botons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    ),
    // Text estils
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    ),
  );

  // Estils específics per botons del joc
  static ButtonStyle gameButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
      minimumSize: const Size(200, 50),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Estil per text de puntuació
  static TextStyle scoreTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      fontWeight: FontWeight.bold,
      color: primaryColor,
      shadows: [
        Shadow(
          offset: const Offset(1, 1),
          blurRadius: 2,
          color: Colors.black26,
        ),
      ],
    );
  }

  static const sizedBoxHeight0 = SizedBox(height: 0);
  static const sizedBoxHeight10 = SizedBox(height: 10);
  static const sizedBoxHeight20 = SizedBox(height: 20);
  static const sizedBoxHeight40 = SizedBox(height: 40);
  static const sizedBoxHeight50 = SizedBox(height: 50);
  static const sizedBoxHeight60 = SizedBox(height: 60);
  static const sizedBoxHeight70 = SizedBox(height: 70);
  static const sizedBoxHeight80 = SizedBox(height: 80);
  static const sizedBoxHeight100 = SizedBox(height: 100);

}
