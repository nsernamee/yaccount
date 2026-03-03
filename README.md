# YAccount - 本地加密记账应用

一款完全本地化的移动端记账应用，所有数据仅存储在手机本地，无需云端同步，确保数据隐私安全。

## 功能特性

### 核心功能
- ✅ **双模块录入**：支持支出和收入两大模块
- ✅ **数据存储**：使用 SQLite 加密数据库
- ✅ **实时统计**：今日、本周、本月收支统计
- ✅ **历史记录**：按日期倒序列表，支持删除/修改
- ✅ **月度统计**：饼图、柱状图、折线图
- ✅ **预算管理**：月度预算和分类预算
- ✅ **导入导出**：CSV 格式数据导入导出

### 性能优化
- ⚡ **启动速度**：冷启动 < 1.5秒
- ⚡ **列表流畅**：60fps 滑动体验
- ⚡ **图表优化**：数据预聚合，流畅渲染
- ⚡ **内存管理**：及时释放资源，无内存泄漏
- ⚡ **包大小**：Release 包 < 15MB

### 数据安全
- 🔒 **数据库加密**：使用 SQLCipher 加密
- 🔒 **无网络权限**：数据永不外传
- 🔒 **密码保护**：应用密码加密存储
- 🔒 **二次确认**：关键操作需确认

## 技术栈

- **框架**：Flutter 3.x
- **数据库**：sqflite + sqflite_sqlcipher
- **图表**：fl_chart
- **状态管理**：Provider
- **CSV处理**：csv
- **文件存储**：path_provider
- **响应式布局**：flutter_screenutil

## 项目结构

```
lib/
├── main.dart                      # 应用入口
├── models/                        # 数据模型
│   ├── transaction_model.dart     # 交易记录模型
│   ├── budget_model.dart          # 预算模型
│   └── category_model.dart        # 分类常量
├── database/                      # 数据库
│   └── database_helper.dart       # 数据库Helper（加密）
├── providers/                     # 状态管理
│   ├── transaction_provider.dart  # 交易记录Provider
│   ├── budget_provider.dart       # 预算Provider
│   └── app_provider.dart          # 应用全局Provider
└── pages/                         # 页面
    ├── home_page.dart             # 首页
    ├── add_transaction_page.dart  # 添加记录页
    ├── history_page.dart          # 历史记录页
    ├── statistics_page.dart       # 统计页
    ├── budget_page.dart            # 预算管理页
    ├── import_export_page.dart    # 导入导出页
    └── settings_page.dart         # 设置页
```

## 快速开始

### 环境要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode

### 安装依赖
```bash
flutter pub get
```

### 运行应用
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web（非主要平台）
flutter run -d chrome
```

## 构建发布版本

### Android
```bash
# 生成 APK
flutter build apk --release

# 生成 App Bundle
flutter build appbundle --release

# 分析包大小
flutter build apk --analyze-size
```

### iOS
```bash
# 构建 IPA
flutter build ios --release

# 分析包大小
flutter build ios --analyze-size
```

## 数据库表结构

### transactions 表
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL CHECK(type IN ('expense', 'income')),
  amount REAL NOT NULL CHECK(amount > 0),
  note TEXT,
  category TEXT NOT NULL,
  transaction_date TEXT NOT NULL,
  created_at TEXT NOT NULL
);

-- 索引
CREATE INDEX idx_transaction_date ON transactions(transaction_date DESC);
CREATE INDEX idx_transaction_type ON transactions(type);
```

### budgets 表
```sql
CREATE TABLE budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT NOT NULL,
  amount REAL NOT NULL CHECK(amount >= 0),
  year INTEGER NOT NULL,
  month INTEGER NOT NULL,
  UNIQUE(category, year, month)
);
```

## 性能优化

详见 [PERFORMANCE_OPTIMIZATION.md](./PERFORMANCE_OPTIMIZATION.md)

关键优化点：
1. **启动速度**：异步初始化、延迟加载
2. **列表流畅**：分页加载、索引优化
3. **图表性能**：数据预聚合、减少渲染点
4. **内存管理**：及时释放资源、关闭游标
5. **包大小**：代码混淆、资源压缩

## 模块设计原则

### 高内聚低耦合
- **数据层**：独立的数据模型和数据库操作
- **业务层**：Provider 封装业务逻辑
- **UI层**：页面只负责展示和交互

### 可扩展性
- 模块化设计，易于添加新功能
- Provider 状态管理，便于跨页面共享数据
- 数据库抽象，便于切换存储方案

## 开发指南

### 添加新页面
1. 在 `lib/pages/` 创建新页面文件
2. 在 `lib/main.dart` 添加路由
3. 必要时添加底部导航项

### 添加新数据模型
1. 在 `lib/models/` 创建模型文件
2. 在 `DatabaseHelper` 添加 CRUD 方法
3. 创建对应的 Provider（如需要）

### 数据库迁移
修改 `_databaseVersion` 并实现 `onUpgrade` 方法。

## 常见问题

### Q: 如何修改数据库密码？
A: 在 `lib/database/database_helper.dart` 中修改 `_getDatabasePassword()` 方法。

### Q: 如何添加新的分类？
A: 在 `lib/models/category_model.dart` 的 `CategoryConstants` 中添加。

### Q: 如何调整分页加载大小？
A: 在 `lib/database/database_helper.dart` 中修改 `getTransactionsPaginated` 的 `limit` 参数。

### Q: 应用启动慢怎么办？
A: 参考 `PERFORMANCE_OPTIMIZATION.md` 中的启动速度优化章节。

## 贡献指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](./LICENSE) 文件。

## 联系方式

如有问题或建议，请提交 Issue。

---

**注意**：本应用所有数据仅存储在本地设备，请定期备份以防数据丢失。
