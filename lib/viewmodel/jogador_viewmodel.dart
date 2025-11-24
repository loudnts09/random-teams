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

  Future<void> adicionarJogador(String nome) async {
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
        foto: imagemSelecionada?.path
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