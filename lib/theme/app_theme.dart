import 'package:flutter/material.dart';

class AppTheme {

  static const Color seedColor = Colors.blue;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: seedColor, 
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
    ),

    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: seedColor,
      foregroundColor: Colors.white,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: seedColor, // Fundo Azul
        foregroundColor: Colors.white, // Letra Branca
        iconColor: Colors.white, // Ícone Branco
      ),
    )
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: seedColor, 
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
    ),
    
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: seedColor, // Fundo Azul
        foregroundColor: Colors.white, // Letra Branca
        iconColor: Colors.white, // Ícone Branco
      ),
    )
  );
}