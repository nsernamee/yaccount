import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database_helper.dart';

/// 全局应用状态Provider
class AppProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isInitialized = false;
  bool _isDbReady = false;
  String? _password;
  bool _isEncrypted = false;

  bool get isInitialized => _isInitialized;
  bool get isDbReady => _isDbReady;
  bool get isEncrypted => _isEncrypted;

  /// 初始化应用
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 检查是否设置了密码
    _password = await _secureStorage.read(key: 'db_password');
    _isEncrypted = _password != null && _password!.isNotEmpty;

    // 初始化数据库
    await _initDatabase();
    _isInitialized = true;
    notifyListeners();
  }

  /// 初始化数据库
  Future<void> _initDatabase() async {
    try {
      await _db.reinitialize(password: _password);
      _isDbReady = true;
    } catch (e) {
      // 如果加密数据库打开失败，尝试非加密模式
      if (_isEncrypted) {
        _isEncrypted = false;
        _password = null;
        await _secureStorage.delete(key: 'db_password');
        await _db.reinitialize();
        _isDbReady = true;
      }
    }
  }

  /// 设置数据库密码（启用加密）
  Future<void> setPassword(String password) async {
    if (password.isEmpty) return;

    _password = password;
    _isEncrypted = true;

    // 安全存储密码
    await _secureStorage.write(key: 'db_password', value: password);

    // 重新初始化数据库
    await _db.reinitialize(password: password);
    notifyListeners();
  }

  /// 清除密码（禁用加密）
  Future<void> clearPassword() async {
    _password = null;
    _isEncrypted = false;

    await _secureStorage.delete(key: 'db_password');
    await _db.reinitialize();
    notifyListeners();
  }

  /// 获取数据库实例
  DatabaseHelper get database => _db;
}
