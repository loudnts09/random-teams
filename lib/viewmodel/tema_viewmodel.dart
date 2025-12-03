import 'package:flutter/material.dart';
import 'dart:developer';

class TemaViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;

  void alterarTema(ThemeMode novoTema) {
    _themeMode = novoTema;
    log("Tema alterado para: ${novoTema.toString()}");
    notifyListeners();
  }

  void ativarTemaClaro() {
    alterarTema(ThemeMode.light);
  }

  void ativarTemaEscuro() {
    alterarTema(ThemeMode.dark);
  }

  void ativarTemaSistema() {
    alterarTema(ThemeMode.system);
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      alterarTema(ThemeMode.light);
    } else {
      alterarTema(ThemeMode.dark);
    }
  }
}
