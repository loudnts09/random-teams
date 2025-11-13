import 'package:flutter/material.dart';
import '../model/jogador.dart';
import '../repository/jogador_repository.dart';

class JogadorViewModel extends ChangeNotifier {
  final JogadorRepository _repository = JogadorRepository();

  List<Jogador> _jogadores = [];
  List<Jogador> get jogadores => _jogadores;

  bool _carregando = false;
  bool get carregando => _carregando;

  Future<void> carregarJogadores() async {
    _carregando = true;
    notifyListeners();

    _jogadores = await _repository.listar();

    _carregando = false;
    notifyListeners();
  }

  Future<void> adicionarJogador(String nome) async {
    final novo = Jogador(nome: nome);
    await _repository.inserir(novo);
    await carregarJogadores();
  }

  Future<void> atualizarJogador(Jogador jogador) async {
    await _repository.atualizar(jogador);
    await carregarJogadores();
  }

  Future<void> excluirJogador(int id) async {
    await _repository.excluir(id);
    await carregarJogadores();
  }
}