import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'expense.dart';

class DatabaseManipulation {
  Future<Database> database;

  DatabaseManipulation(String dbName, int version) : database = open(dbName, version);

  static Future<Database> open(String path, int v_) async {
    return openDatabase(
      join(await getDatabasesPath(), path),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE expenses(id INTEGER PRIMARY KEY, item TEXT, amount REAL, date DATETIME)',
        );
      },
      version: v_,
    );
  }

  // insert an expense
  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // retrieve all expenses
  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'],
        item: maps[i]['item'],
        amount: maps[i]['amount'],
        date: DateTime.now(),
      );
    });
  }
}