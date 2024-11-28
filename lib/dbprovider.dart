import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'food_item.dart';

class SQLiteDbProvider {
  SQLiteDbProvider._();

  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "FoodOrdering.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE food_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            cost REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE order_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            target_cost REAL,
            selected_items TEXT
          )
        ''');
      },
    );
  }

  Future<void> resetOrderPlansTable() async {
    final db = await database;

    // Drop the existing table if it exists
    await db.execute('DROP TABLE IF EXISTS order_plans');

    // Recreate the table
    await db.execute('''
    CREATE TABLE order_plans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      target_cost REAL,
      selected_items TEXT
    )
  ''');
  }


  Future<void> populateFoodItems() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM food_items'));
    if (count == 0) {
      final foodItems = [
        {'name': 'pizza', 'cost': 20.99},
        {'name': 'bunger', 'cost': 5.99},
        {'name': 'shawarma', 'cost': 10.99},
        {'name': 'sushi', 'cost': 7.99},
        {'name': 'tacos', 'cost': 8.99},
        {'name': 'nihari', 'cost': 15.99},
        {'name': 'naan', 'cost': 4.99},
        {'name': 'hotdog', 'cost': 3.99},
        {'name': 'glizzy', 'cost': 3.99},
        {'name': 'soup', 'cost': 4.99},
        {'name': 'salad', 'cost': 5.99},
        {'name': 'bread', 'cost': 2.00},
        {'name': 'coke', 'cost': 1.99},
        {'name': 'donut', 'cost': 1.00},
        {'name': 'ice cap', 'cost': 2.50},
        {'name': 'cookies', 'cost': 3.99},
        {'name': 'water', 'cost': 1.99},
        {'name': 'ramen', 'cost': 0.99},
        {'name': 'chips', 'cost': 4.99},
        {'name': 'fries', 'cost': 3.99},
      ];

      for (var item in foodItems) {
        await db.insert('food_items', item);
      }
    }
  }

  Future<int> insertFoodItem(FoodItem foodItem) async {
    final db = await database;
    return await db.insert('food_items', foodItem.toMap());
  }



  Future<List<FoodItem>> getAllFoodItems() async {
    final db = await database;
    final results = await db.query('food_items');
    return results.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<int> saveOrderPlan(String date, double targetCost, String selectedItems) async {
    final db = await database;
    return await db.insert('order_plans', {
      'date': date,
      'target_cost': targetCost,
      'selected_items': selectedItems,
    });
  }

  Future<List<Map<String, dynamic>>> getOrderPlanByDate(String date) async {
    final db = await database;
    return await db.query(
      'order_plans',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<List<Map<String, dynamic>>> getAllOrderPlans() async {
    final db = await database;
    return await db.query('order_plans');
  }

  Future<int> updateOrderPlan(int id, String date, double targetCost, String selectedItems) async {
    final db = await database;

    return await db.update(
      'order_plans',
      {
        'date': date,
        'target_cost': targetCost,
        'selected_items': selectedItems,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteOrderPlan(int id) async {
    final db = await database;
    return await db.delete(
      'order_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
