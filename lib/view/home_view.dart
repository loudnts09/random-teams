import 'package:flutter/material.dart';
import 'jogadores_view.dart';
import 'sorteio_view.dart';
import 'dart:developer';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    log("HomeView build chamado");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerador de times'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  log("botão de gerenciar jogadores pressionado");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JogadoresView()),
                  );
                },
                icon: const Icon(Icons.group),
                label: const Text('Gerenciar Jogadores'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  log("botão de sortear times pressionado");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SorteioView()),
                  );
                },
                icon: const Icon(Icons.shuffle),
                label: const Text('Sortear Times'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
