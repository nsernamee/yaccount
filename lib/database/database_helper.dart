import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

/// 数据库Helper类 - 使用加密SQLite
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  factory DatabaseHelper() => _instance;
  
  DatabaseHelper._internal();

  // 数据库配置
  static const String _databaseName = 'yaccount_encrypted.db';
  static const int _databaseVersion = 1;

  // 获取数据库实例（异步初始化）
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化加密数据库
  Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);

    // 从安全存储获取密码密钥（这里简化处理，实际应从系统密钥链获取）
    final String password = _getDatabasePassword();

    // 打开加密数据库
    final Database db = await openDatabase(
      path,
      version: _databaseVersion,
      password: password,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return db;
  }

  /// 获取数据库加密密钥
  String _getDatabasePassword() {
    // 实际项目中应该从安全存储获取用户设置的密码
    // 这里使用固定密钥作为示例
    return 'yaccount_secure_password_2024';
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 创建交易记录表
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL CHECK(type IN ('expense', 'income')),
        amount REAL NOT NULL CHECK(amount > 0),
        note TEXT,
        category TEXT NOT NULL,
        transaction_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 为日期字段创建索引（性能优化）
    await db.execute('''
      CREATE INDEX idx_transaction_date 
      ON transactions(transaction_date DESC)
    ''');

    // 为类型字段创建索引
    await db.execute('''
      CREATE INDEX idx_transaction_type 
      ON transactions(type)
    ''');

    // 创建预算表
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL CHECK(amount >= 0),
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        UNIQUE(category, year, month)
      )
    ''');

    // 创建应用设置表
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 未来版本升级逻辑
  }

  // ==================== 交易记录 CRUD 操作 ====================

  /// 插入交易记录
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  /// 批量插入交易记录（使用事务优化性能）
  Future<void> insertTransactionsBatch(List<TransactionModel> transactions) async {
    final db = await database;
    final batch = db.batch();
    
    for (var transaction in transactions) {
      batch.insert('transactions', transaction.toMap());
    }
    
    await batch.commit(noResult: true);
  }

  /// 更新交易记录
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// 删除交易记录
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取交易记录
  Future<TransactionModel?> getTransaction(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  /// 获取所有交易记录
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'transaction_date DESC',
    );

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// 分页获取交易记录（性能优化：懒加载）
  Future<List<TransactionModel>> getTransactionsPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    final db = await database;
    
    // 只查询需要的字段，避免 SELECT *
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      columns: ['id', 'type', 'amount', 'note', 'category', 'transaction_date'],
      orderBy: 'transaction_date DESC',
      offset: offset,
      limit: limit,
    );

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// 按日期范围获取交易记录
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'transaction_date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'transaction_date DESC',
    );

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// 获取指定类型的交易记录
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'transaction_date DESC',
    );

    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// 获取今日交易记录
  Future<List<TransactionModel>> getTodayTransactions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getTransactionsByDateRange(startOfDay, endOfDay);
  }

  /// 获取本周交易记录
  Future<List<TransactionModel>> getWeekTransactions() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfDay.add(const Duration(days: 7));

    return getTransactionsByDateRange(startOfDay, endOfWeek);
  }

  /// 获取本月交易记录
  Future<List<TransactionModel>> getMonthTransactions() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

    return getTransactionsByDateRange(startOfMonth, startOfNextMonth);
  }

  /// 获取统计数据
  Future<Map<String, double>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String query = 'SELECT type, SUM(amount) as total FROM transactions';
    List<dynamic> args = [];

    if (startDate != null && endDate != null) {
      query += ' WHERE transaction_date BETWEEN ? AND ?';
      args = [startDate.toIso8601String(), endDate.toIso8601String()];
    }
    
    query += ' GROUP BY type';

    final List<Map<String, dynamic>> results = await db.rawQuery(query, args);

    return {
      for (var row in results) row['type'] as String: (row['total'] as num).toDouble()
    };
  }

  /// 获取按分类汇总的数据（用于饼图）
  Future<Map<String, double>> getCategoryStatistics(
    String type,
    int year,
    int month,
  ) async {
    final db = await database;
    
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE type = ? 
        AND transaction_date >= ? 
        AND transaction_date < ?
      GROUP BY category
      ORDER BY total DESC
    ''', [type, startDate.toIso8601String(), endDate.toIso8601String()]);

    return {
      for (var row in results) row['category'] as String: (row['total'] as num).toDouble()
    };
  }

  /// 获取近6个月的收支对比数据（用于柱状图）
  Future<List<Map<String, dynamic>>> getMonthlyComparison(int months) async {
    final db = await database;
    final now = DateTime.now();
    final List<Map<String, dynamic>> results = [];

    for (int i = 0; i < months; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final monthlyResults = await db.rawQuery('''
        SELECT type, SUM(amount) as total
        FROM transactions
        WHERE transaction_date >= ? AND transaction_date < ?
        GROUP BY type
      ''', [monthDate.toIso8601String(), nextMonth.toIso8601String()]);

      final Map<String, dynamic> monthData = {
        'month': '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}',
        'income': 0.0,
        'expense': 0.0,
      };

      for (var row in monthlyResults) {
        final type = row['type'] as String;
        final total = (row['total'] as num).toDouble();
        monthData[type] = total;
      }

      results.add(monthData);
    }

    return results.reversed.toList();
  }

  /// 获取当月每日支出数据（用于折线图）
  Future<List<Map<String, dynamic>>> getDailyExpenseTrend(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        substr(transaction_date, 1, 10) as date,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as expense,
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as income
      FROM transactions
      WHERE transaction_date >= ? AND transaction_date < ?
      GROUP BY date
      ORDER BY date
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return results.map((row) => {
      'date': row['date'] as String,
      'expense': (row['expense'] as num?)?.toDouble() ?? 0.0,
      'income': (row['income'] as num?)?.toDouble() ?? 0.0,
    }).toList();
  }

  // ==================== 预算 CRUD 操作 ====================

  /// 插入或更新预算
  Future<void> insertOrUpdateBudget(BudgetModel budget) async {
    final db = await database;
    await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取指定月份的预算
  Future<BudgetModel?> getBudget(String category, int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'category = ? AND year = ? AND month = ?',
      whereArgs: [category, year, month],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first);
  }

  /// 获取指定月份的所有预算
  Future<List<BudgetModel>> getBudgetsByMonth(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );

    return maps.map((map) => BudgetModel.fromMap(map)).toList();
  }

  /// 删除预算
  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 计算预算使用率
  Future<Map<String, double>> getBudgetUsage(int year, int month) async {
    final budgets = await getBudgetsByMonth(year, month);
    final Map<String, double> usage = {};

    for (var budget in budgets) {
      final transactions = await getTransactionsByDateRange(
        DateTime(year, month, 1),
        DateTime(year, month + 1, 1),
      );

      double spent = 0.0;
      for (var tx in transactions) {
        if (tx.type == 'expense') {
          if (budget.category == 'total') {
            spent += tx.amount;
          } else if (tx.category == budget.category) {
            spent += tx.amount;
          }
        }
      }

      usage[budget.category] = budget.amount > 0 ? (spent / budget.amount) : 0.0;
    }

    return usage;
  }

  // ==================== 设置操作 ====================

  /// 保存设置
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取设置
  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  /// 关闭数据库连接
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
