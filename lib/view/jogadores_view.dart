import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/jogador_viewmodel.dart';
import '../model/jogador.dart';
import 'dart:developer';

class JogadoresView extends StatefulWidget {
  const JogadoresView({super.key});

  @override
  State<JogadoresView> createState() => _JogadoresViewState();
}

class _JogadoresViewState extends State<JogadoresView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("carregando jogadores na JogadoresView");
      Provider.of<JogadorViewModel>(context, listen: false).carregarJogadores();
    });
  }

  // Popup para adicionar/editar jogador
  void _abrirDialogo(BuildContext context, {Jogador? jogadorExistente}) {
    final TextEditingController controller =
        TextEditingController(text: jogadorExistente?.nome ?? '');

    log("abrindo diálogo para ${jogadorExistente == null ? 'adicionar' : 'editar'} jogador");

    showDialog(
      context: context,
      builder: (dialogContext){
        return AlertDialog(
          title: Text(
              jogadorExistente == null ? 'Adicionar Jogador' : 'Editar Jogador'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                log("cancelando diálogo de ${jogadorExistente == null ? 'adição' : 'edição'} de jogador");
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nome = controller.text.trim();
                if (nome.isNotEmpty) {
                  final viewModel =
                      Provider.of<JogadorViewModel>(dialogContext, listen: false);

                  if (jogadorExistente == null) {
                    log("adicionar jogador -> $nome");
                    await viewModel.adicionarJogador(nome);
                  } else {
                      log("jogador -> ${jogadorExistente.nome} sendo atualizado para $nome");
                    await viewModel.atualizarJogador(
                      Jogador(id: jogadorExistente.id, nome: nome),
                    );
                  }
                  log("fechar dialogo após ação");
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(jogadorExistente == null ? 'Adicionar' : 'Salvar'),
            ),
          ],
        );
      }
    );
  }

  // Popup de confirmação para exclusão
  void _confirmarExclusao(BuildContext context, Jogador jogador) {
    log("confirmar a exclusão do jogador ${jogador.nome} de id ${jogador.id}");
    showDialog(
      context: context,
      builder: (dialogContext){
        return AlertDialog(
          title: const Text('Excluir jogador'),
          content: Text('Deseja realmente excluir "${jogador.nome}"?'),
          actions: [
            TextButton(
              onPressed: () {
                log("exclusão do jogador ${jogador.nome} de id ${jogador.id} cancelada");
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final viewModel =
                    Provider.of<JogadorViewModel>(dialogContext, listen: false);
                log("excluindo ${jogador.nome}");
                await viewModel.excluirJogador(jogador.id!);
                log("jogador ${jogador.id} excluído");
                Navigator.pop(dialogContext);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    log("JogadoresView build chamado");
    final viewModel = Provider.of<JogadorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar jogadores'),
        centerTitle: false,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          log("botão de adicionar pressionado em JogadoresView");
          _abrirDialogo(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: viewModel.carregando
            ? const Center(child: CircularProgressIndicator())
            : viewModel.jogadores.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum jogador adicionado ainda.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: viewModel.jogadores.length,
                    itemBuilder: (context, index) {
                      final jogador = viewModel.jogadores[index];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(jogador.nome),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  log("botão de editar jogador ${jogador.nome} pressionado em JogadoresView");
                                  _abrirDialogo(context, jogadorExistente: jogador);
                                }
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  log("botão de excluir jogador ${jogador.nome} pressionado em JogadoresView");
                                  _confirmarExclusao(context, jogador);
                                }
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
