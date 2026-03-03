import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../database/database_helper.dart';

/// 交易记录状态管理Provider
class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _todayTransactions = [];
  List<TransactionModel> _weekTransactions = [];
  List<TransactionModel> _monthTransactions = [];
  
  bool _isLoading = false;
  int _totalCount = 0;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get todayTransactions => _todayTransactions;
  List<TransactionModel> get weekTransactions => _weekTransactions;
  List<TransactionModel> get monthTransactions => _monthTransactions;
  bool get isLoading => _isLoading;
  int get totalCount => _totalCount;

  // 统计数据
  double get todayIncome => _calculateTotal(_todayTransactions, 'income');
  double get todayExpense => _calculateTotal(_todayTransactions, 'expense');
  double get todayBalance => todayIncome - todayExpense;
  
  double get weekIncome => _calculateTotal(_weekTransactions, 'income');
  double get weekExpense => _calculateTotal(_weekTransactions, 'expense');
  double get weekBalance => weekIncome - weekExpense;
  
  double get monthIncome => _calculateTotal(_monthTransactions, 'income');
  double get monthExpense => _calculateTotal(_monthTransactions, 'expense');
  double get monthBalance => monthIncome - monthExpense;

  /// 计算总计
  double _calculateTotal(List<TransactionModel> transactions, String type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// 初始化加载
  Future<void> initialize() async {
    await loadTodayTransactions();
    await loadWeekTransactions();
    await loadMonthTransactions();
  }

  /// 加载今日交易记录
  Future<void> loadTodayTransactions() async {
    _todayTransactions = await _dbHelper.getTodayTransactions();
    notifyListeners();
  }

  /// 加载本周交易记录
  Future<void> loadWeekTransactions() async {
    _weekTransactions = await _dbHelper.getWeekTransactions();
    notifyListeners();
  }

  /// 加载本月交易记录
  Future<void> loadMonthTransactions() async {
    _monthTransactions = await _dbHelper.getMonthTransactions();
    notifyListeners();
  }

  /// 分页加载历史记录
  Future<void> loadTransactionsPaginated({bool reset = false}) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      if (reset) {
        _transactions = [];
      }

      final newTransactions = await _dbHelper.getTransactionsPaginated(
        offset: _transactions.length,
        limit: 20,
      );

      _transactions.addAll(newTransactions);
      
      // 如果返回的记录少于20条，说明已经加载完所有数据
      if (newTransactions.length < 20) {
        _totalCount = _transactions.length;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 添加交易记录
  Future<void> addTransaction(TransactionModel transaction) async {
    await _dbHelper.insertTransaction(transaction);
    await _refreshAllData();
  }

  /// 更新交易记录
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _dbHelper.updateTransaction(transaction);
    await _refreshAllData();
  }

  /// 删除交易记录
  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    await _refreshAllData();
  }

  /// 刷新所有数据
  Future<void> _refreshAllData() async {
    await Future.wait([
      loadTodayTransactions(),
      loadWeekTransactions(),
      loadMonthTransactions(),
    ]);
    
    // 重置并重新加载历史记录
    _transactions.clear();
    await loadTransactionsPaginated(reset: true);
  }

  /// 获取按分类汇总的数据
  Future<Map<String, double>> getCategoryStatistics(
    String type,
    int year,
    int month,
  ) async {
    return await _dbHelper.getCategoryStatistics(type, year, month);
  }

  /// 获取近6个月的收支对比数据
  Future<List<Map<String, dynamic>>> getMonthlyComparison(int months) async {
    return await _dbHelper.getMonthlyComparison(months);
  }

  /// 获取当月每日支出数据
  Future<List<Map<String, dynamic>>> getDailyExpenseTrend(
    int year,
    int month,
  ) async {
    return await _dbHelper.getDailyExpenseTrend(year, month);
  }

  @override
  void dispose() {
    _dbHelper.close();
    super.dispose();
  }
}
