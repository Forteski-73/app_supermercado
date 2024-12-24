import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Item {
  int? id;
  String nome;
  double preco;
  bool comprado;

  Item({this.id, required this.nome, this.preco = 0.0, this.comprado = false});

  // Converte o item para Map para inserção/atualização no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'comprado': comprado ? 1 : 0, // Convertendo bool para int para o banco
    };
  }

  // Construtor para criar um Item a partir de um Map (depois de buscar no banco)
  Item.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        nome = map['nome'],
        preco = map['preco'],
        comprado = map['comprado'] == 1;
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  late Database _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'itens.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE itens(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT,
          preco REAL,
          comprado INTEGER
        )
      ''');
    });
  }

  // Insere um item no banco
  Future<void> insertItem(Item item) async {
    final db = await database;
    await db.insert('itens', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Atualiza um item no banco
  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update('itens', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  // Recupera todos os itens
  Future<List<Item>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('itens');
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }
}
