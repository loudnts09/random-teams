import 'package:flutter/material.dart';
import 'views/home_view.dart';

void main() {
  runApp(const SorteadorApp());
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
