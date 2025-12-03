import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui; // Import para manipulação de imagem
import 'dart:typed_data'; // Import para bytes
import 'package:share_plus/share_plus.dart'; // Import para compartilhar
import 'package:path_provider/path_provider.dart'; // Import para salvar temp
import 'dart:developer';
import 'dart:io';
import '../model/jogador.dart';
import '../repository/jogador_repository.dart';

class JogadorViewModel extends ChangeNotifier {
  final JogadorRepository _repository = JogadorRepository();
  final picker = ImagePicker();
  // 1. Chave global para identificar a área que será transformada em imagem
  final GlobalKey globalKey = GlobalKey();
  bool gerandoImagem = false; // Controle de loading para o botão de exportar

  List<List<Jogador>> _timesSorteados = [];
  List<List<Jogador>> get timesSorteados => _timesSorteados;
  
  File? imagemSelecionada;

  List<Jogador> _jogadores = [];
  List<Jogador> get jogadores => _jogadores;

  bool _carregando = false;
  bool get carregando => _carregando;

  List<Map<String, dynamic>> _historicoSorteios = [];
  List<Map<String, dynamic>> get historicoSorteios => _historicoSorteios;

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

    for(var time in times) {
      time.shuffle();
    }

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
      try {
        // Obter diretório de documentos persistente
        final appDir = await getApplicationDocumentsDirectory();
        final pastaFotos = Directory('${appDir.path}/fotos_jogadores');
        
        // Criar pasta se não existir
        if (!await pastaFotos.exists()) {
          await pastaFotos.create(recursive: true);
          log("Pasta de fotos criada: ${pastaFotos.path}");
        }

        // Copiar arquivo para diretório persistente
        final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final caminhoDestino = '${pastaFotos.path}/$nomeArquivo';
        
        await File(arquivo.path).copy(caminhoDestino);
        imagemSelecionada = File(caminhoDestino);
        
        log("Imagem salva em: $caminhoDestino"); 
        notifyListeners();
      } catch (e, s) {
        log("Erro ao salvar imagem", error: e, stackTrace: s);
      }
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

  Future<File?> gerarImagemDoSorteio() async {
    try {
      gerandoImagem = true;
      notifyListeners();
      log("Iniciando captura da imagem...");

      await Future.delayed(const Duration(milliseconds: 80));

      RenderRepaintBoundary? boundary =
          globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        log("Boundary NÃO encontrado. Tela não renderizada?");
        gerandoImagem = false;
        notifyListeners();
        return null;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/times_sorteados.png');

      await file.writeAsBytes(pngBytes);

      log("Imagem gerada em: ${file.path}");

      return file;
    } catch (e, s) {
      log("Erro ao gerar imagem", error: e, stackTrace: s);
      return null;
    } finally {
      gerandoImagem = false;
      notifyListeners();
    }
  }

  Future<void> compartilharImagem() async {
    final file = await gerarImagemDoSorteio();
    if (file == null) {
      log("Não foi possível gerar a imagem para compartilhar");
      return;
    }

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Times sorteados!",
    );
  }

  // Métodos para histórico de sorteios
  Future<void> carregarHistoricoSorteios() async {
    try {
      _carregando = true;
      notifyListeners();

      _historicoSorteios = await _repository.listarHistoricoSorteios();
      log("Histórico carregado: ${_historicoSorteios.length} sorteios");

      _carregando = false;
      notifyListeners();
    } catch (e, s) {
      log("Erro ao carregar histórico", error: e, stackTrace: s);
      _carregando = false;
      notifyListeners();
    }
  }

  Future<List<List<Jogador>>?> recuperarSorteioDetalhado(int sorteioId) async {
    try {
      log("Recuperando detalhes do sorteio $sorteioId");
      return await _repository.recuperarSorteioById(sorteioId);
    } catch (e, s) {
      log("Erro ao recuperar sorteio detalhado", error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> deletarSorteioDoHistorico(int sorteioId) async {
    try {
      log("Deletando sorteio $sorteioId do histórico");
      await _repository.deletarSorteio(sorteioId);
      
      _historicoSorteios.removeWhere((s) => s['id'] == sorteioId);
      log("Sorteio deletado com sucesso");
      notifyListeners();
    } catch (e, s) {
      log("Erro ao deletar sorteio", error: e, stackTrace: s);
    }
  }
}