import 'package:flutter/material.dart';

class SorteioView extends StatefulWidget {
  const SorteioView({super.key});

  @override
  State<SorteioView> createState() => _SorteioViewState();
}

class _SorteioViewState extends State<SorteioView> {
  int _numeroTimes = 3; // valor inicial
  int _jogadoresPorTime = 3; // só como exemplo

  // lista mock de jogadores — mais tarde vamos buscar do ViewModel/DB
  final List<String> _jogadoresMock = [
    'arthur',
    'nathalia',
    'larissa',
    'wal',
    'naiara',
    'heitor',
    'mateus',
    'wesley'
  ];

  List<List<String>> _timesSorteados = [];

  void _sortear() {
    final lista = List<String>.from(_jogadoresMock);
    lista.shuffle();
    final List<List<String>> times = List.generate(_numeroTimes, (_) => []);
    int index = 0;
    for (var jogador in lista) {
      times[index].add(jogador);
      index = (index + 1) % _numeroTimes;
    }
    setState(() => _timesSorteados = times);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sortear Times'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Controle de número de times
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (_numeroTimes > 2) {
                      setState(() => _numeroTimes--);
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text('Times: $_numeroTimes'),
                IconButton(
                  onPressed: () => setState(() => _numeroTimes++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _sortear,
              icon: const Icon(Icons.shuffle),
              label: const Text('Sortear'),
            ),

            const SizedBox(height: 16),

            // Exibição dos times sorteados (mock)
            Expanded(
              child: _timesSorteados.isEmpty
                  ? const Center(child: Text('Nenhum sorteio feito ainda.'))
                  : SingleChildScrollView(
                      child: Column(
                        children: List.generate(_timesSorteados.length, (i) {
                          final time = _timesSorteados[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Time ${i + 1}', style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: time.map((nome) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CircleAvatar(radius: 28, child: Icon(Icons.person)),
                                          const SizedBox(height: 6),
                                          Text(nome),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}