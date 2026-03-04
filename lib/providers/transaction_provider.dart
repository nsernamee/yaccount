import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

/// 交易数据Provider
class TransactionProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 20;

  // 统计数据缓存
  Map<String, double> _todayStats = {};
  Map<String, double> _weekStats = {};
  Map<String, double> _monthStats = {};

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  Map<String, double> get todayStats => _todayStats;
  Map<String, double> get weekStats => _weekStats;
  Map<String, double> get monthStats => _monthStats;

  /// 初始化并加载数据
  Future<void> initialize() async {
    await loadTransactions();
    await loadStatistics();
  }

  /// 加载交易记录（分页）
  Future<void> loadTransactions({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 0;
      _transactions = [];
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newTransactions = await _db.getTransactions(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (newTransactions.length < _pageSize) {
        _hasMore = false;
      }

      _transactions.addAll(newTransactions);
      _currentPage++;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载更多（分页加载）
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    await loadTransactions();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadTransactions(refresh: true);
    await loadStatistics();
  }

  /// 加载统计数据
  Future<void> loadStatistics() async {
    final now = DateTime.now();

    // 今日统计
    final today = DateTime(now.year, now.month, now.day);
    _todayStats = await _db.getStatistics(
      startDate: today,
      endDate: now,
    );

    // 本周统计
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    _weekStats = await _db.getStatistics(
      startDate: weekStart,
      endDate: now,
    );

    // 本月统计
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    _monthStats = await _db.getStatistics(
      startDate: monthStart,
      endDate: monthEnd,
    );

    notifyListeners();
  }

  /// 添加交易记录
  Future<void> addTransaction({
    required double amount,
    required String type,
    required String category,
    String? note,
    DateTime? date,
  }) async {
    final transaction = TransactionModel(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      category: category,
      note: note,
      date: date ?? DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _db.insertTransaction(transaction);
    await refresh();
  }

  /// 更新交易记录
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _db.updateTransaction(transaction);
    await refresh();
  }

  /// 删除交易记录
  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    await refresh();
  }

  /// 批量导入交易记录
  Future<void> importTransactions(List<TransactionModel> transactions) async {
    await _db.insertTransactionsBatch(transactions);
    await refresh();
  }

  /// 获取所有交易记录（用于导出）
  Future<List<TransactionModel>> getAllTransactions() async {
    return await _db.getTransactions(pageSize: 999999);
  }

  /// 获取分类统计（饼图用）
  Future<Map<String, double>> getCategoryStats({
    required DateTime startDate,
    required DateTime endDate,
    String type = 'expense',
  }) async {
    return await _db.getCategoryStatistics(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }

  /// 获取月度统计（柱状图用）
  Future<List<Map<String, dynamic>>> getMonthlyStats(int months) async {
    return await _db.getMonthlyStatistics(months);
  }

  /// 获取每日支出趋势（折线图用）
  Future<Map<String, double>> getDailyTrend({
    required int year,
    required int month,
  }) async {
    return await _db.getDailyExpenseTrend(year: year, month: month);
  }
}
