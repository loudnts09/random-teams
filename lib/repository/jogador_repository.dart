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
              foto TEXT
            )
          ''');
        },
      );
    }
    catch(e, s){
      log("erro ao inicializar o banco", error: e, stackTrace: s);
      rethrow;
    }
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
