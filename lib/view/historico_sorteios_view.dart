import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'dart:io';
import '../viewmodel/jogador_viewmodel.dart';

class HistoricoSorteiosView extends StatefulWidget {
  const HistoricoSorteiosView({super.key});

  @override
  State<HistoricoSorteiosView> createState() => _HistoricoSorteiosViewState();
}

class _HistoricoSorteiosViewState extends State<HistoricoSorteiosView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("Carregando histórico de sorteios");
      Provider.of<JogadorViewModel>(context, listen: false)
          .carregarHistoricoSorteios();
    });
  }

  void _mostrarDetalhes(BuildContext context, int sorteioId) async {
    log("Mostrando detalhes do sorteio $sorteioId");
    final viewModel = Provider.of<JogadorViewModel>(context, listen: false);
    final times = await viewModel.recuperarSorteioDetalhado(sorteioId);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Detalhes do Sorteio'),
          content: SingleChildScrollView(
            child: times == null || times.isEmpty
                ? const Text('Nenhum dado disponível')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(times.length, (i) {
                      final time = times[i];
                      return Column(
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
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: time.map((jogador) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: jogador.foto != null
                                        ? FileImage(File(jogador.foto!))
                                        : null,
                                    child: jogador.foto == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      jogador.nome,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                log("Fechando detalhes do sorteio");
                Navigator.pop(dialogContext);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmarDelecao(BuildContext context, int sorteioId, DateTime dataHora) {
    log("Confirmando deleção do sorteio $sorteioId");
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Deletar Sorteio'),
          content: Text(
              'Deseja realmente deletar o sorteio de ${dataHora.day}/${dataHora.month}/${dataHora.year} às ${dataHora.hour}:${dataHora.minute.toString().padLeft(2, '0')}?'),
          actions: [
            TextButton(
              onPressed: () {
                log("Deleção cancelada");
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                log("Deletando sorteio $sorteioId");
                final viewModel =
                    Provider.of<JogadorViewModel>(dialogContext, listen: false);
                await viewModel.deletarSorteioDoHistorico(sorteioId);
                log("Sorteio deletado");
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Deletar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    log("HistoricoSorteiosView build chamado");
    final viewModel = Provider.of<JogadorViewModel>(context);
    final historico = viewModel.historicoSorteios;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Sorteios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: viewModel.carregando
            ? const Center(child: CircularProgressIndicator())
            : historico.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum sorteio realizado ainda.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: historico.length,
                    itemBuilder: (context, index) {
                      final sorteio = historico[index];
                      final sorteioId = sorteio['id'] as int;
                      final dataHora =
                          DateTime.parse(sorteio['data_hora'] as String);

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.history, color: Colors.blue),
                          title: Text(
                            'Sorteio #$sorteioId',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${dataHora.day}/${dataHora.month}/${dataHora.year} às ${dataHora.hour}:${dataHora.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info, color: Colors.blue),
                                onPressed: () {
                                  log("Visualizando detalhes do sorteio $sorteioId");
                                  _mostrarDetalhes(context, sorteioId);
                                },
                                tooltip: 'Ver detalhes',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  log("Tentando deletar sorteio $sorteioId");
                                  _confirmarDelecao(context, sorteioId, dataHora);
                                },
                                tooltip: 'Deletar sorteio',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
