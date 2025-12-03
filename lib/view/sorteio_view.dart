import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'dart:io';
import '../viewmodel/jogador_viewmodel.dart';

class SorteioView extends StatefulWidget {
  const SorteioView({super.key});

  @override
  State<SorteioView> createState() => _SorteioViewState();
}

extension OrientationHelper on MediaQueryData {
  bool get isLandscape => orientation == Orientation.landscape;
}

class _SorteioViewState extends State<SorteioView> {
  int _numeroTimes = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("SorteioView: Carregando dados...");
      final vm = Provider.of<JogadorViewModel>(context, listen: false);
      vm.carregarJogadores();
      vm.carregarUltimoSorteio();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<JogadorViewModel>(context);
    final times = viewModel.timesSorteados;
    final isLandscape = MediaQuery.of(context).isLandscape;

    log("_numeroTimes=$_numeroTimes times=${times.length} jogadores=${viewModel.jogadores.length}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sortear Times'),
        actions: [
          if (times.isNotEmpty)
            viewModel.gerandoImagem
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: "Exportar como Imagem",
                    onPressed: () => viewModel.compartilharImagem(),
                  ),
        ],
      ),
      body: isLandscape ? _buildLandscapeLayout(context, viewModel, times) : _buildPortraitLayout(context, viewModel, times),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, JogadorViewModel viewModel, List<List<dynamic>> times) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // --- CONTROLES (não fazem parte da imagem exportada) ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Quantidade de Times:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_numeroTimes > 2) {
                                setState(() => _numeroTimes--);
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '$_numeroTimes',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _numeroTimes++),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: viewModel.carregando
                          ? null
                          : () => viewModel.sortear(_numeroTimes),
                      icon: viewModel.carregando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.shuffle),
                      label: Text(viewModel.carregando ? 'Sorteando...' : 'Sortear Times'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // --- ÁREA QUE SE TRANSFORMA EM IMAGEM ---
          Expanded(
            child: times.isEmpty
                ? const Center(child: Text('Nenhum sorteio feito ainda.'))
                : SingleChildScrollView(
                    child: _buildTeamsContent(context, viewModel, times),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, JogadorViewModel viewModel, List<List<dynamic>> times) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // --- PAINEL DE CONTROLES (LADO ESQUERDO) ---
          SizedBox(
            width: 220,
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text(
                          "Quantidade de Times:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_numeroTimes > 2) {
                                  setState(() => _numeroTimes--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline, size: 24),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '$_numeroTimes',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _numeroTimes++),
                              icon: const Icon(Icons.add_circle_outline, size: 24),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: viewModel.carregando
                                ? null
                                : () => viewModel.sortear(_numeroTimes),
                            icon: viewModel.carregando
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.shuffle, size: 18),
                            label: Text(
                              viewModel.carregando ? 'Sorteando...' : 'Sortear',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // --- ÁREA DOS TIMES (LADO DIREITO) ---
          Expanded(
            child: times.isEmpty
                ? const Center(child: Text('Nenhum sorteio feito ainda.'))
                : SingleChildScrollView(
                    child: _buildTeamsContent(context, viewModel, times),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsContent(BuildContext context, JogadorViewModel viewModel, List<List<dynamic>> times) {
    final isLandscape = MediaQuery.of(context).isLandscape;
    final crossAxisCount = isLandscape ? (times.length > 3 ? 3 : times.length) : 1;

    // Se landscape e vários times, exibe em grid
    if (isLandscape && times.length > 2) {
      return GridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        children: List.generate(times.length, (i) {
          final time = times[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time ${i + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: time.map((jogador) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: jogador.foto != null
                                    ? FileImage(File(jogador.foto!))
                                    : null,
                                child: jogador.foto == null
                                    ? const Icon(Icons.person, size: 14)
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  jogador.nome,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  jogador.nivel,
                                  (index) => const Icon(Icons.star,
                                      size: 8, color: Colors.orange),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    }

    // Modo portrait ou landscape com poucos times - exibe em coluna
    return RepaintBoundary(
      key: viewModel.globalKey,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: List.generate(times.length, (i) {
            final time = times[i];
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
                      children: time.map((jogador) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 39,
                              backgroundImage: jogador.foto != null
                                  ? FileImage(File(jogador.foto!))
                                  : null,
                              child: jogador.foto == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(jogador.nome),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                jogador.nivel,
                                (index) => const Icon(Icons.star,
                                    size: 10, color: Colors.orange),
                              ),
                            ),
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
    );
  }
}

