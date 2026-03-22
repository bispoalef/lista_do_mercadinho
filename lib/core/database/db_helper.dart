import 'package:lista_do_mercadinho/features/compras/models/compra.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<List<Map<String, dynamic>>> getHistoricoCompras() async {
    final db = await instance.database;
    return await db.query('compras', orderBy: 'data DESC');
  }

  Future<void> salvarCompra(Compra compra) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      await txn.insert('compras', compra.toMap());
      for (var item in compra.itens) {
        await txn.insert('itens', {
          'id': item.id,
          'compra_id': compra.id,
          'nome': item.nome,
          'preco': item.preco,
          'quantidade': item.quantidade,
        });
      }
    });
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('compras_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE compras (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        valorTotal REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE itens (
        id TEXT PRIMARY KEY,
        compra_id TEXT NOT NULL,
        nome TEXT NOT NULL,
        preco REAL NOT NULL,
        quantidade INTEGER NOT NULL,
        FOREIGN KEY (compra_id) REFERENCES compras (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getItensFrequentes() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT nome, preco, quantidade, COUNT(nome) as frequencia 
      FROM itens 
      GROUP BY nome 
      ORDER BY frequencia DESC 
      LIMIT 10
    ''');
  }

  Future<List<Map<String, dynamic>>> getEstatisticasMensais(String ano) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT strftime('%m', data) as mes, SUM(valorTotal) as totalMes, AVG(valorTotal) as mediaMes
      FROM compras 
      WHERE strftime('%Y', data) = ?
      GROUP BY mes
      ORDER BY mes ASC
    ''',
      [ano],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
