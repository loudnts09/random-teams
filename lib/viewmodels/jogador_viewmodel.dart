import 'package:flutter/foundation.dart';
import '../models/jogador.dart';
import '../database/database_helper.dart';

class JogadorViewModel extends ChangeNotifier {
  List<Jogador> _jogadores = [];
  final dbHelper = DatabaseHelper.instance;

  List<Jogador> get jogadores => _jogadores;

  Future<void> carregarJogadores() async {
    _jogadores = await dbHelper.listarJogadores();
    debugPrint('Jogadores carregados: ${_jogadores.length}');
    notifyListeners();
  }

  Future<void> adicionarJogador(String nome) async {
    if (nome.trim().isEmpty) {
      debugPrint('Tentativa de adicionar jogador vazio.');
      return;
    }

    final novo = Jogador(nome: nome);
    await dbHelper.inserirJogador(novo);
    debugPrint('Jogador adicionado: $nome');

    await carregarJogadores();
  }

  Future<void> removerJogador(int id) async {
    await dbHelper.deletarJogador(id);
    debugPrint('Jogador removido com ID: $id');

    await carregarJogadores();
  }
}
