import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/jogador.dart';
import 'dart:developer';

class JogadorRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    try{
      log("abrindo banco de dados");
      _database = await _initDB();
      return _database!;
    }
    catch(e, s){
      log("erro ao abrir banco de dados", error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<Database> _initDB() async {
    try{
      log("inicializando o banco de dados");
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'jogadores.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE jogadores (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              foto TEXT,
              nivel INTEGER NOT NULL
            )
          ''');
          await _criarTabelasSorteio(db);
        },
      );
    }
    catch(e, s){
      log("erro ao inicializar o banco", error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> _criarTabelasSorteio(Database db) async {
    await db.execute('''
      CREATE TABLE sorteios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data_hora TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sorteio_itens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sorteio_id INTEGER NOT NULL,
        jogador_id INTEGER NOT NULL,
        numero_time INTEGER NOT NULL,
        FOREIGN KEY(sorteio_id) REFERENCES sorteios(id),
        FOREIGN KEY(jogador_id) REFERENCES jogadores(id)
      )
    ''');
  }

  Future<void> salvarSorteio(List<List<Jogador>> times) async {
    final db = await database;
    
    await db.transaction((txn) async {

      int sorteioId = await txn.insert('sorteios', {
        'data_hora': DateTime.now().toIso8601String()
      });

      for (int i = 0; i < times.length; i++) {
        int numeroTime = i + 1;
        for (var jogador in times[i]) {
          if (jogador.id != null) {
            await txn.insert('sorteio_itens', {
              'sorteio_id': sorteioId,
              'jogador_id': jogador.id,
              'numero_time': numeroTime
            });
          }
        }
      }
    });
    log("Sorteio salvo com sucesso!");
  }

  Future<List<List<Jogador>>?> recuperarUltimoSorteio() async {
    final db = await database;

    final sorteios = await db.query('sorteios', orderBy: 'id DESC', limit: 1);
    if (sorteios.isEmpty) return null;

    int sorteioId = sorteios.first['id'] as int;

    final itens = await db.rawQuery('''
      SELECT j.*, s.numero_time 
      FROM sorteio_itens s
      INNER JOIN jogadores j ON s.jogador_id = j.id
      WHERE s.sorteio_id = ?
      ORDER BY s.numero_time
    ''', [sorteioId]);

    Map<int, List<Jogador>> mapaTimes = {};
    
    for (var item in itens) {
      int time = item['numero_time'] as int;
      Jogador j = Jogador.fromMap(item);
      
      if (!mapaTimes.containsKey(time)) {
        mapaTimes[time] = [];
      }
      mapaTimes[time]!.add(j);
    }

    return mapaTimes.values.toList();
  }

  Future<int> inserir(Jogador jogador) async {
    try{
      log("inserindo jogador: ${jogador.nome}");
      final db = await database;
      return await db.insert('jogadores', jogador.toMap());
    }
    catch(e, s){
      log("erro ao inserir jogador", error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<List<Jogador>> listar() async {
    try {
      log("consultando banco...");
      final db = await database;
      final maps = await db.query('jogadores');

      log("registros encontrados: ${maps.length}");
      return List.generate(maps.length, (i) {
        log("linha lida: ${maps[i]}");
        return Jogador.fromMap(maps[i]);
      });
    } catch (e, s) {
      log("erro ao listar jogadores", error: e, stackTrace: s);
      rethrow;
    }
  }


  Future<int> atualizar(Jogador jogador) async {
    try{
      log("atualizando jogador id=${jogador.id}");
      final db = await database;
      return await db.update(
        'jogadores',
        jogador.toMap(),
        where: 'id = ?',
        whereArgs: [jogador.id],
      );

    } catch (e, s) {
      log("erro ao atualizar jogador", error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<int> excluir(int id) async {
    try{
      log("excluindo jogador id=$id");
      final db = await database;
      return await db.delete(
        'jogadores',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    catch(e, s){
      log("erro ao excluir jogador", error: e, stackTrace: s);
      rethrow;
    }
  }
}
