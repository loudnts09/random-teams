import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'dart:io';
import '../model/jogador.dart';
import '../repository/jogador_repository.dart';

class JogadorViewModel extends ChangeNotifier {
  final JogadorRepository _repository = JogadorRepository();
  final picker = ImagePicker();
  
  File? imagemSelecionada;

  List<Jogador> _jogadores = [];
  List<Jogador> get jogadores => _jogadores;

  bool _carregando = false;
  bool get carregando => _carregando;

  Future<void> carregarUltimoSorteio() async {
    _carregando = true;
    notifyListeners();
    
    final resultado = await _repository.recuperarUltimoSorteio();
    if (resultado != null) {
      _timesSorteados = resultado;
    }
    
    _carregando = false;
    notifyListeners();
  }

  Future<void> sortear(int numeroTimes) async {
    if (_jogadores.isEmpty) return;

    _carregando = true;
    notifyListeners();

    List<Jogador> pool = List.from(_jogadores);

    pool.sort((a, b) => b.nivel.compareTo(a.nivel));

    List<List<Jogador>> times = List.generate(numeroTimes, (_) => []);

    // algoritmo Snake Draft (1, 2, 2, 1...)
    for (int i = 0; i < pool.length; i++) {

      int indiceTime;
      int rodada = i ~/ numeroTimes;
      
      bool indo = rodada % 2 == 0;
      if (indo) {
        indiceTime = i % numeroTimes;
      } else {
        indiceTime = (numeroTimes - 1) - (i % numeroTimes);
      }

      times[indiceTime].add(pool[i]);
    }

    for(var time in times) time.shuffle();

    _timesSorteados = times;

    await _repository.salvarSorteio(_timesSorteados);

    _carregando = false;
    notifyListeners();
  }

  void removerImagem(){
    imagemSelecionada = null;
    log("imagem removida com sucesso");
    notifyListeners();
  }

  void setImagemParaEdicao(String? caminhoFoto){
    if(caminhoFoto != null){
      imagemSelecionada = File(caminhoFoto);
    }
    else{
      imagemSelecionada = null;
    }
    notifyListeners();
  }

  Future<void> selecionarImagem() async{
    final XFile? arquivo = await picker.pickImage(source: ImageSource.gallery);

    if(arquivo != null){
      imagemSelecionada = File(arquivo.path);
      log("Imagem selecionada: ${arquivo.path}"); 
      notifyListeners();
    }
  }

  Future<void> carregarJogadores() async {
    try{
      log("carregando jogadores");
      _carregando = true;
      notifyListeners();

      _jogadores = await _repository.listar();
    }
    catch(e, s){
      log("erro ao carregar jogadores ", error: e, stackTrace: s);
    }
    finally{
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> adicionarJogador(String nome, int nivel) async {
    if(nome.trim().isEmpty){
      log("o nome não pode estar vazio");
      return;
    }

    try{
      log("adicionando jogadores");
      _carregando = true;
      notifyListeners();

      final novo = Jogador(
        nome: nome,
        foto: imagemSelecionada?.path,
        nivel: nivel
      );
      await _repository.inserir(novo);
      log("jogador inserido com sucesso");
    }
    catch(e, s){
      log("erro ao adicionar jogadores", error: e, stackTrace: s);
    }
    finally{
      _carregando = false;
      notifyListeners();
      await carregarJogadores();
    }
  }

  Future<void> atualizarJogador(Jogador jogador) async {
    if(jogador.nome.trim().isEmpty){
      log("o nome não pode estar vazio");
      return;
    }
    try{
      log("atualizando jogador id=${jogador.id}");
      _carregando = true;
      notifyListeners();
      await _repository.atualizar(jogador);
    }
    catch(e, s){
      log("erro ao atualizar jogador", error: e, stackTrace: s);
    }
    finally{
      _carregando = false;
      notifyListeners();
      await carregarJogadores();
    }
  }

  Future<void> excluirJogador(int id) async {
    try{
      log("excluindo jogador id=$id");
      _carregando = true;
      notifyListeners();
      await _repository.excluir(id);
    }
    catch(e, s){
      log("erro ao excluir jogador", error: e, stackTrace: s);
    }
    finally{
      _carregando = false;
      notifyListeners();
      
      await carregarJogadores();
    }
  }
}