import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

/// 应用全局状态管理Provider
class AppProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  String _currentMonth = '';
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  
  bool _isInitialized = false;
  bool _hasSetPassword = false;

  // Getters
  String get currentMonth => _currentMonth;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  bool get isInitialized => _isInitialized;
  bool get hasSetPassword => _hasSetPassword;

  /// 初始化应用
  Future<void> initialize() async {
    await _loadCurrentMonth();
    await _checkPasswordSet();
    _isInitialized = true;
    notifyListeners();
  }

  /// 加载当前选择的月份
  Future<void> _loadCurrentMonth() async {
    final savedMonth = await _dbHelper.getSetting('selected_month');
    if (savedMonth != null) {
      final parts = savedMonth.split('-');
      _selectedYear = int.parse(parts[0]);
      _selectedMonth = int.parse(parts[1]);
    }
    _currentMonth = '$_selectedYear-$_selectedMonth';
  }

  /// 保存当前选择的月份
  Future<void> saveCurrentMonth(int year, int month) async {
    _selectedYear = year;
    _selectedMonth = month;
    _currentMonth = '$year-$month';
    
    await _dbHelper.saveSetting('selected_month', _currentMonth);
    notifyListeners();
  }

  /// 切换到上一个月
  void previousMonth() {
    if (_selectedMonth == 1) {
      _selectedMonth = 12;
      _selectedYear--;
    } else {
      _selectedMonth--;
    }
    saveCurrentMonth(_selectedYear, _selectedMonth);
  }

  /// 切换到下一个月
  void nextMonth() {
    if (_selectedMonth == 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else {
      _selectedMonth++;
    }
    saveCurrentMonth(_selectedYear, _selectedMonth);
  }

  /// 检查是否设置了密码
  Future<void> _checkPasswordSet() async {
    final hasPassword = await _dbHelper.getSetting('has_password');
    _hasSetPassword = hasPassword == 'true';
  }

  /// 设置应用密码
  Future<void> setPassword(String password) async {
    // 这里应该将密码哈希后存储，简化示例
    await _dbHelper.saveSetting('app_password', password);
    await _dbHelper.saveSetting('has_password', 'true');
    _hasSetPassword = true;
    notifyListeners();
  }

  /// 验证密码
  Future<bool> verifyPassword(String password) async {
    final savedPassword = await _dbHelper.getSetting('app_password');
    return savedPassword == password;
  }

  /// 获取应用设置
  Future<String?> getSetting(String key) async {
    return await _dbHelper.getSetting(key);
  }

  /// 保存应用设置
  Future<void> saveSetting(String key, String value) async {
    await _dbHelper.saveSetting(key, value);
  }

  @override
  void dispose() {
    _dbHelper.close();
    super.dispose();
  }
}
