import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Database? _database; // Tornar _database opcional (nullable)

  // Construtor privado
  DatabaseHelper._internal();

  // Método de inicialização
  Future<void> initialize() async {
    if (_database == null) {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'my_database.db');
      _database = await openDatabase(path, version: 1, onCreate: (db, version) {
        // Criação das tabelas
        return db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            preco REAL,
            comprado INTEGER
          );
        ''');
      });
    }
  }

  // Método para obter a instância do banco de dados
  Future<Database> get database async {
    if (_database == null) {
      await initialize(); // Inicializa o banco se ainda não foi inicializado
    }
    return _database!;
  }

  // Inserir um item
  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  // Obter os itens
  Future<List<Item>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  // Atualizar um item
  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Deletar um item
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método para deletar todos os itens
  Future<int> deleteAllItems() async {
    final db = await database;
    return await db.delete('items'); // Deleta todos os itens
  }

}

class Item {
  int? id;
  String nome;
  double preco;
  bool comprado;

  Item({
    this.id,
    required this.nome,
    this.preco = 0.0,
    this.comprado = false,
  });

  // Converter para mapa para salvar no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'comprado': comprado ? 1 : 0,
    };
  }

  // Criar um item a partir de um mapa
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      nome: map['nome'],
      preco: map['preco'],
      comprado: map['comprado'] == 1,
    );
  }
}
