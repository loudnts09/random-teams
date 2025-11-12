import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/jogador.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jogadores.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE jogadores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL
      )
    ''');
  }

  Future<int> inserirJogador(Jogador jogador) async {
    final db = await instance.database;
    return await db.insert('jogadores', jogador.toMap());
  }

  Future<List<Jogador>> listarJogadores() async {
    final db = await instance.database;
    final result = await db.query('jogadores');
    return result.map((map) => Jogador.fromMap(map)).toList();
  }

  Future<int> deletarJogador(int id) async {
    final db = await instance.database;
    return await db.delete('jogadores', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}