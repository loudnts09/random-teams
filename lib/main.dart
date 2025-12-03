import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_teams/theme/app_theme.dart';
import 'package:random_teams/viewmodel/jogador_viewmodel.dart';
import 'package:random_teams/viewmodel/tema_viewmodel.dart';
import 'view/home_view.dart';
import 'dart:developer';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    log("FlutterError", error: details.exception, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log("Erro de plataforma", error: error, stackTrace: stack);
    return true;
  };
  log("iniciando app");
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => JogadorViewModel()),
      ChangeNotifierProvider(create: (_) => TemaViewModel()),
    ],
    child: const SorteadorApp()
  ));
}

class SorteadorApp extends StatelessWidget {
  const SorteadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final temaViewModel = Provider.of<TemaViewModel>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerenciador de Times',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: temaViewModel.themeMode,
      home: const HomeView(),
    );
  }
}
