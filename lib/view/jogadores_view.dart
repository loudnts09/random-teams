import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/jogador_viewmodel.dart';
import '../model/jogador.dart';
import 'dart:developer';
import 'dart:io';

class JogadoresView extends StatefulWidget {
  const JogadoresView({super.key});

  @override
  State<JogadoresView> createState() => _JogadoresViewState();
}

class _JogadoresViewState extends State<JogadoresView> {
  
  int _nivelJogador = 1;

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

    final viewModel = Provider.of<JogadorViewModel>(context, listen: false);
    viewModel.setImagemParaEdicao(jogadorExistente?.foto);

    setState(() {
      _nivelJogador = jogadorExistente?.nivel ?? 1;
    });
    showDialog(
      context: context,
      builder: (dialogContext){
        final viewModel = Provider.of<JogadorViewModel>(dialogContext, listen: false);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                  jogadorExistente == null ? 'Adicionar Jogador' : 'Editar Jogador'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async{
                          await viewModel.selecionarImagem();
                          setStateDialog(() {});
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: viewModel.imagemSelecionada != null ? FileImage(viewModel.imagemSelecionada!) : null,
                          child: viewModel.imagemSelecionada == null ? const Icon(Icons.camera_alt, size: 30) : null,
                        ),
                      ),
                      if (viewModel.imagemSelecionada != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton.icon(
                          onPressed: () {
                            viewModel.removerImagem(); 
                            setStateDialog(() {}); 
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text(
                            "Remover foto", 
                            style: TextStyle(color: Colors.red),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16,),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                  ),
                  Text('Definir nível do jogador: '),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 30,
                        onPressed: () {
                          if (_nivelJogador > 1) {
                            setStateDialog(() {
                              _nivelJogador--;
                              log("decrementou _nivelJogador -> $_nivelJogador");
                            });
                          }
                          else{ 
                            log("tentativa de decrementar abaixo de 1 ignorada");
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                      ),
                      Text('$_nivelJogador'),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                      ),
                      IconButton(
                        iconSize: 30,
                        onPressed: () {
                          if(_nivelJogador < 5){
                            setStateDialog(() {
                              _nivelJogador++;
                              log("incrementou _nivelJogador -> $_nivelJogador");
                            });
                          }
                          else{ 
                            log("tentativa de incrementar acima de 5 ignorada");
                          }
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    log("cancelando diálogo de ${jogadorExistente == null ? 'adição' : 'edição'} de jogador");
                    viewModel.setImagemParaEdicao(null);
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
                        await viewModel.adicionarJogador(nome, _nivelJogador);
                      } else {
                          log("jogador -> ${jogadorExistente.nome} sendo atualizado para $nome");
                        await viewModel.atualizarJogador(
                          Jogador(
                            id: jogadorExistente.id,
                            nome: nome,
                            foto: viewModel.imagemSelecionada?.path,
                            nivel: _nivelJogador
                          ),
                        );
                      }
                      log("fechar dialogo após ação");
                      viewModel.setImagemParaEdicao(null);
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
                          leading: CircleAvatar(
                            backgroundImage: jogador.foto != null ? FileImage(File(jogador.foto!)) : null,
                            child: jogador.foto == null ? const Icon(Icons.person) : null,
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
