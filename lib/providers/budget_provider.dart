import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../database/database_helper.dart';

/// 预算状态管理Provider
class BudgetProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<BudgetModel> _budgets = [];
  Map<String, double> _budgetUsage = {};
  
  bool _isLoading = false;

  // Getters
  List<BudgetModel> get budgets => _budgets;
  Map<String, double> get budgetUsage => _budgetUsage;
  bool get isLoading => _isLoading;

  /// 加载指定月份的预算
  Future<void> loadBudgets(int year, int month) async {
    _isLoading = true;
    notifyListeners();

    try {
      _budgets = await _dbHelper.getBudgetsByMonth(year, month);
      _budgetUsage = await _dbHelper.getBudgetUsage(year, month);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 保存或更新预算
  Future<void> saveBudget(BudgetModel budget) async {
    await _dbHelper.insertOrUpdateBudget(budget);
    
    // 刷新预算列表
    await loadBudgets(budget.year, budget.month);
  }

  /// 删除预算
  Future<void> deleteBudget(int id) async {
    await _dbHelper.deleteBudget(id);
    
    // 刷新预算列表
    if (_budgets.isNotEmpty) {
      await loadBudgets(_budgets.first.year, _budgets.first.month);
    }
  }

  /// 获取预算使用率
  double getBudgetUsageRate(String category) {
    return _budgetUsage[category] ?? 0.0;
  }

  /// 获取预算状态颜色
  String getBudgetStatusColor(double usageRate) {
    if (usageRate < 0.7) return 'green';
    if (usageRate < 0.9) return 'yellow';
    return 'red';
  }

  /// 检查是否超预算
  bool isOverBudget(String category) {
    return getBudgetUsageRate(category) >= 1.0;
  }

  @override
  void dispose() {
    _dbHelper.close();
    super.dispose();
  }
}
