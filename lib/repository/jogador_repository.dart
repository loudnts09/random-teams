import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/jogador.dart';

class JogadorRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jogadores.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE jogadores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> inserir(Jogador jogador) async {
    final db = await database;
    return await db.insert('jogadores', jogador.toMap());
  }

  Future<List<Jogador>> listar() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('jogadores');
    return List.generate(maps.length, (i) => Jogador.fromMap(maps[i]));
  }

  Future<int> atualizar(Jogador jogador) async {
    final db = await database;
    return await db.update(
      'jogadores',
      jogador.toMap(),
      where: 'id = ?',
      whereArgs: [jogador.id],
    );
  }

  Future<int> excluir(int id) async {
    final db = await database;
    return await db.delete(
      'jogadores',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
