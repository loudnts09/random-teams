import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_teams/viewmodel/jogador_viewmodel.dart';
import 'view/home_view.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => JogadorViewModel(),
    child: const SorteadorApp()
  ));
}

class SorteadorApp extends StatelessWidget {
  const SorteadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerador de Times',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
