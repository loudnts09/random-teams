import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/jogador_viewmodel.dart';
import 'dart:developer';

class SorteioView extends StatefulWidget {
  const SorteioView({super.key});

  @override
  State<SorteioView> createState() => _SorteioViewState();
}

class _SorteioViewState extends State<SorteioView> {
  int _numeroTimes = 2;

  List<List<String>> _timesSorteados = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("SorteioView build chamado carregando jogadores");
      Provider.of<JogadorViewModel>(context, listen: false).carregarJogadores();
    });
  }

  void _sortear() {
    final viewModel = Provider.of<JogadorViewModel>(context, listen: false);

    log("iniciando (jogadores= ${viewModel.jogadores.length}, times ${_numeroTimes}");

    if (viewModel.jogadores.isEmpty) {
      log("nenhum jogador cadastrado. abortando sorteio");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum jogador cadastrado!')),
      );
      return;
    }

    // cria lista de nomes
    final lista = viewModel.jogadores.map((j) => j.nome).toList();

    lista.shuffle();
    log("lista embaralhada");

    final List<List<String>> times = List.generate(_numeroTimes, (_) => []);
    int index = 0;

    for (var nome in lista) {
      times[index].add(nome);
      index = (index + 1) % _numeroTimes;
    }
    
    log("times gerados (tamanhos=${times.map((t) => t.length).toList()})");

    setState(() {
      _timesSorteados = times;
    });

    log("setState aplicado, _timesSorteados.length=${_timesSorteados.length}");
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<JogadorViewModel>(context);

    log("_numeroTimes=$_numeroTimes _timesSorteados=${_timesSorteados.length} jogadores=${viewModel.jogadores.length}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sortear Times'),
        centerTitle: false,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (_numeroTimes > 2) {
                      setState(() {
                        _numeroTimes--;
                        log("decrementou _numeroTimes -> $_numeroTimes");
                      });
                    }
                    else{ 
                      log("tentativa de decrementar abaixo de 2 ignorada");
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text('Times: $_numeroTimes'),
                IconButton(
                  onPressed: () => setState(() {
                     _numeroTimes++;
                      log("incrementou _numeroTimes -> $_numeroTimes");
                    }),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            ElevatedButton.icon(
              onPressed: (){
                log("botão de sortear pressionado");
                _sortear();
              },
              icon: const Icon(Icons.shuffle),
              label: const Text('Sortear'),
            ),

            const SizedBox(height: 16),

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
                                  Text(
                                    'Time ${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: time.map((nome) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CircleAvatar(
                                            radius: 28,
                                            child: Icon(Icons.person),
                                          ),
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
