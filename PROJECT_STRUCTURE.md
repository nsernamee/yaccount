# YAccount 项目结构说明

## 项目概述

**YAccount** 是一款本地记账应用，使用 Flutter 开发，数据存储在手机本地 SQLite 数据库中，支持 Android/iOS 平台。

---

## 目录结构

```
yaccount/
├── lib/
│   ├── main.dart                      # 应用入口
│   ├── database/                      # 数据库层
│   │   └── database_helper.dart       # 数据库操作封装
│   ├── models/                        # 数据模型层
│   │   ├── transaction_model.dart     # 交易记录模型
│   │   ├── category_model.dart        # 分类模型
│   │   └── budget_model.dart          # 预算模型
│   ├── providers/                     # 状态管理层
│   │   ├── app_provider.dart          # 应用全局状态
│   │   ├── transaction_provider.dart  # 交易数据管理
│   │   └── budget_provider.dart       # 预算数据管理
│   ├── pages/                         # 页面层
│   │   ├── home_page.dart             # 首页
│   │   ├── add_transaction_page.dart  # 添加交易
│   │   ├── history_page.dart          # 历史记录
│   │   ├── statistics_page.dart       # 统计图表
│   │   ├── budget_page.dart           # 预算管理
│   │   ├── import_export_page.dart    # 导入导出
│   │   └── settings_page.dart         # 设置
│   ├── widgets/                       # 组件层
│   │   ├── common_widgets.dart        # 通用组件
│   │   └── category_selector.dart     # 分类选择器
│   ├── utils/                         # 工具层
│   │   ├── constants.dart              # 常量定义
│   │   └── date_utils.dart            # 日期工具
│   └── services/                      # 服务层(预留)
├── android/                           # Android 平台配置
├── ios/                               # iOS 平台配置
├── pubspec.yaml                       # 依赖配置
└── README.md                          # 项目说明
```

---

## 技术栈

| 类别 | 技术 | 用途 |
|------|------|------|
| **框架** | Flutter 3.x | 跨平台开发 |
| **数据库** | sqflite + sqflite_sqlcipher | 本地数据存储 |
| **状态管理** | Provider | 全局状态管理 |
| **图表** | fl_chart | 数据可视化 |
| **文件处理** | path_provider, file_picker, share_plus | 文件路径、选择、分享 |
| **数据处理** | csv, excel, intl, uuid | 数据解析、格式化 |
| **安全** | crypto, flutter_secure_storage | 数据加密 |
| **UI组件** | flutter_slidable | 滑动操作 |

---

## 各模块实现说明

### 1. 数据库层 (database/)

#### `database_helper.dart`

**职责**: 封装所有数据库操作

**核心功能**:
- 单例模式管理数据库连接
- 创建/升级数据库表结构
- 提供 CRUD 操作接口
- 支持数据库加密(可选)
- 复杂的聚合查询统计

**数据库表结构**:

```sql
-- 交易记录表 (transactions)
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  amount REAL NOT NULL,
  type TEXT NOT NULL,           -- 'expense' 或 'income'
  category TEXT NOT NULL,       -- 分类ID
  note TEXT,                    -- 备注
  date TEXT NOT NULL,           -- 日期 (YYYY-MM-DD)
  created_at TEXT NOT NULL      -- 创建时间
);

-- 索引优化查询性能
CREATE INDEX idx_transaction_date ON transactions(date);
CREATE INDEX idx_transaction_type ON transactions(type);
CREATE INDEX idx_transaction_category ON transactions(category);

-- 预算表 (budgets)
CREATE TABLE budgets (
  id TEXT PRIMARY KEY,
  category TEXT NOT NULL,       -- 分类ID (总预算为 'total')
  amount REAL NOT NULL,         -- 预算金额
  month INTEGER NOT NULL,       -- 月份 (YYYYMM 格式)
  created_at TEXT NOT NULL,     -- 创建时间
  UNIQUE(category, month)       -- 唯一约束
);
```

**关键方法**:
- `database`: 获取数据库实例(单例)
- `_initDatabase()`: 初始化数据库
- `_onCreate()`: 创建表结构
- `_onUpgrade()`: 升级数据库版本
- `insertTransaction()`: 插入交易记录
- `updateTransaction()`: 更新交易记录
- `deleteTransaction()`: 删除交易记录
- `getTransactions()`: 查询交易记录(支持分页)
- `getStatistics()`: 获取指定日期范围统计
- `getYearStatistics()`: 获取年度统计
- `getCategoryStatistics()`: 获取分类统计(饼图用)
- `getMonthlyStatistics()`: 获取月度统计(柱状图用)
- `getDailyExpenseTrend()`: 获取每日支出趋势(折线图用)
- `setTotalBudget()`: 设置总预算
- `setCategoryBudget()`: 设置分类预算
- `getBudgets()`: 获取预算列表

---

### 2. 数据模型层 (models/)

#### `transaction_model.dart`

**用途**: 定义交易记录的数据结构

```dart
class TransactionModel {
  final String id;              // UUID 唯一标识
  final double amount;          // 金额
  final String type;            // 'expense' 或 'income'
  final String category;        // 分类ID
  final String? note;           // 备注
  final DateTime date;          // 交易日期
  final DateTime createdAt;     // 创建时间

  // 序列化方法
  Map<String, dynamic> toMap()
  factory TransactionModel.fromMap(Map<String, dynamic> map)
  // 复制方法
  TransactionModel copyWith(...)
}
```

#### `category_model.dart`

**用途**: 定义分类数据结构，包含支出分类和收入分类

```dart
class CategoryModel {
  final String id;              // 分类ID
  final String name;             // 分类名称
  final String icon;            // 图标名称
  final int colorValue;         // 颜色值

  // 预设分类
  static List<CategoryModel> categories
}

// 支出分类: 餐饮、交通、购物、娱乐、医疗、教育、住房
// 收入分类: 工资、投资、其他
```

#### `budget_model.dart`

**用途**: 定义预算数据结构

```dart
class BudgetModel {
  final String id;              // UUID 唯一标识
  final String category;        // 分类ID ('total' 表示总预算)
  final double amount;          // 预算金额
  final int month;              // 月份 (YYYYMM 格式)
  final DateTime createdAt;     // 创建时间

  Map<String, dynamic> toMap()
  factory BudgetModel.fromMap(Map<String, dynamic> map)
}
```

---

### 3. 状态管理层 (providers/)

#### `app_provider.dart`

**职责**: 管理应用全局状态

**状态**:
- `isInitialized`: 应用是否初始化完成
- `isDbReady`: 数据库是否就绪
- `appPassword`: 应用密码
- `isPasswordSet`: 是否设置密码

**方法**:
- `initialize()`: 初始化应用
- `setPassword()`: 设置密码
- `verifyPassword()`: 验证密码
- `clearPassword()`: 清除密码

---

#### `transaction_provider.dart`

**职责**: 管理交易数据和处理统计计算

**状态**:
- `transactions`: 交易列表(分页)
- `isLoading`: 加载状态
- `hasMore`: 是否还有更多数据
- `todayStats`: 今日统计 {income, expense}
- `weekStats`: 本周统计 {income, expense}
- `monthStats`: 本月统计 {income, expense}
- `yearStats`: 本年统计 {income, expense}

**方法**:
- `initialize()`: 初始化并加载数据
- `loadTransactions()`: 加载交易记录(分页)
- `loadMore()`: 加载更多(分页)
- `refresh()`: 刷新数据
- `loadStatistics()`: 加载统计数据
- `addTransaction()`: 添加交易
- `updateTransaction()`: 更新交易
- `deleteTransaction()`: 删除交易
- `importTransactions()`: 批量导入交易
- `getAllTransactions()`: 获取所有交易(用于导出)
- `getCategoryStats()`: 获取分类统计(饼图用)
- `getMonthlyStats()`: 获取月度统计(柱状图用)
- `getDailyTrend()`: 获取每日支出趋势(折线图用)
- `getYearlyStats()`: 获取年度统计
- `getYearlyMonthlyTrend()`: 获取年度月度趋势

---

#### `budget_provider.dart`

**职责**: 管理预算数据

**状态**:
- `budgets`: 分类预算列表
- `totalBudget`: 总预算
- `currentMonth`: 当前月份

**方法**:
- `loadBudgets()`: 加载指定月份预算
- `setTotalBudget()`: 设置总预算
- `setCategoryBudget()`: 设置分类预算
- `deleteBudget()`: 删除预算
- `calculateUsageRate()`: 计算使用率
- `getUsageColor()`: 获取使用率颜色

---

### 4. 页面层 (pages/)

#### `home_page.dart` - 首页

**功能**:
- 展示本月结余(收入-支出)，负数显示红色
- 显示今日/本周/本月收支统计卡片
- 展示最近交易列表
- 快捷添加交易按钮(FloatingActionButton)
- 底部导航栏：首页、统计、预算、设置

**UI组件**:
- `StatCardRow`: 行统计卡片容器
- `StatCard`: 统计卡片(金额自动缩放字体)
- `BudgetProgressBar`: 预算进度条
- `TransactionListItem`: 交易列表项

---

#### `add_transaction_page.dart` - 添加交易

**功能**:
- 切换支出/收入类型
- 输入金额(数字键盘)
- 选择分类(网格布局)
- 输入备注(可选)
- 选择日期(默认今天)
- 保存交易

**UI组件**:
- 类型切换 Tab (支出/收入)
- 大数字金额输入框
- 分类选择器网格
- 日期选择器
- 保存按钮

---

#### `history_page.dart` - 历史记录

**功能**:
- 按日期分组显示交易记录
- 分页加载(每次20条)
- 滑动删除交易
- 编辑交易
- 筛选功能(全部/支出/收入)

**UI组件**:
- 按日期分组的列表
- `Slidable` 滑动操作
- 加载更多指示器
- 空状态组件

---

#### `statistics_page.dart` - 统计图表

**功能**:
- 月份选择器
- 饼图: 支出分类占比
- 柱状图: 近6个月收支对比
- 折线图: 当月每日支出趋势

**UI组件**:
- TabBar 切换视图
- `PieChart`: 饼图
- `BarChart`: 柱状图
- `LineChart`: 折线图
- 月份选择器

---

#### `budget_page.dart` - 预算管理

**功能**:
- 月份选择器
- 设置/编辑月度总预算
- 设置/编辑分类预算
- 查看预算使用率(百分比显示)
- 进度条可视化
- 删除分类预算

**UI组件**:
- 月份切换器
- 总预算卡片(渐变色背景)
- 分类预算卡片列表
- `BudgetProgressBar`: 进度条
- 添加/编辑/删除按钮

---

#### `import_export_page.dart` - 导入导出

**功能**:
- 导出为 CSV 文件
- 导出为 Excel 文件
- 导入 CSV 文件
- 导入 Excel 文件
- 数据增量/覆盖选项

**UI组件**:
- 导出按钮组
- 文件选择器
- 导入选项单选框
- 进度指示器

---

#### `settings_page.dart` - 设置

**功能**:
- 设置/修改应用密码
- 开启/关闭密码保护
- 清空所有数据
- 查看关于信息

**UI组件**:
- 设置项列表
- 密码输入对话框
- 确认对话框

---

### 5. 组件层 (widgets/)

#### `common_widgets.dart`

**通用组件**:
- `StatCardRow`: 统一高度的行统计卡片容器
- `StatCard`: 统计卡片(根据金额长度自动调整字体大小)
- `BudgetProgressBar`: 预算进度条组件
- `EmptyState`: 空状态组件
- `LoadMoreIndicator`: 加载更多指示器

**实现细节**:
- `StatCard` 根据金额长度动态计算字体大小(14-20px)
- `BudgetProgressBar` 根据使用率显示不同颜色(绿/黄/红)

#### `category_selector.dart`

**分类选择器**:
- 网格布局展示分类(3列)
- 显示分类图标和名称
- 支持选中状态高亮
- 支出和收入分类分别显示

---

### 6. 工具层 (utils/)

#### `constants.dart`

**常量定义**:
```dart
class AppConstants {
  // 主题色
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color expenseColor = Color(0xFFE17055);
  static const Color incomeColor = Color(0xFF00B894);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  
  // 预算颜色
  static const Color budgetGreen = Color(0xFF00B894);
  static const Color budgetYellow = Color(0xFFFDCB6E);
  static const Color budgetRed = Color(0xFFE17055);
  
  // 图表颜色列表
  static const List<Color> chartColors = [...];
}

class TransactionType {
  static const String expense = 'expense';
  static const String income = 'income';
}
```

#### `date_utils.dart`

**日期工具函数**:
- `fromMonthInt(int month)`: 将 YYYYM 转换为 DateTime
- `formatMonth(DateTime date)`: 格式化月份为 "YYYY年MM月"
- `getMonthStart(DateTime date)`: 获取月份第一天
- `getMonthEnd(DateTime date)`: 获取月份最后一天

---

### 7. 应用入口 (main.dart)

**职责**:
- 应用初始化
- 配置主题
- 配置多语言
- 启动画面

**结构**:
```
void main() → 初始化系统UI → 运行应用
  └── YAccountApp
      └── MultiProvider (状态管理)
          ├── AppProvider
          ├── TransactionProvider
          └── BudgetProvider
      └── MaterialApp
          ├── 主题配置
          └── 本地化配置
          └── _AppWrapper (初始化包装器)
              ├── _SplashScreen (启动画面)
              └── HomePage (首页)
```

---

## 数据流向

### 1. 添加交易流程

```
用户输入数据
    ↓
AddTransactionPage (收集数据)
    ↓
TransactionProvider.addTransaction()
    ↓
DatabaseHelper.insertTransaction()
    ↓
SQLite Database (存储)
    ↓
TransactionProvider 通知更新
    ↓
UI 自动刷新
```

### 2. 统计查询流程

```
HomePage/StatisticsPage 请求数据
    ↓
TransactionProvider.loadStatistics() / getCategoryStats()
    ↓
DatabaseHelper.getStatistics() / getCategoryStatistics()
    ↓
SQLite Database (聚合查询)
    ↓
返回统计结果
    ↓
UI 展示图表
```

### 3. 预算管理流程

```
BudgetPage 请求预算
    ↓
BudgetProvider.loadBudgets()
    ↓
DatabaseHelper.getBudgets()
    ↓
计算使用率
    ↓
UI 显示进度条
```

---

## 性能优化措施

1. **数据库索引**: 为 `transactions.date`、`type`、`category` 字段建立索引，加速查询
2. **分页加载**: 历史记录每次加载20条，避免一次性加载大量数据
3. **异步初始化**: 数据库异步初始化，不阻塞UI启动
4. **数据聚合**: 统计查询使用 SQL GROUP BY，减少数据传输量
5. **图表优化**: 图表数据预聚合，减少渲染压力
6. **字体动态缩放**: 统计卡片根据金额长度自动调整字体，避免溢出

---

## 数据安全

1. **数据库加密**: 使用 `sqflite_sqlcipher` 支持数据库加密
2. **密码保护**: 应用密码通过 SHA256 派生为数据库密钥
3. **无网络权限**: Android/iOS 均不申请网络权限
4. **数据隔离**: 数据存储在应用私有目录，其他应用无法访问

---

## 总结

YAccount 采用清晰的分层架构:

- **数据库层**: 负责数据持久化
- **模型层**: 定义数据结构
- **状态管理层**: 管理业务逻辑
- **页面层**: 负责UI展示
- **组件层**: 可复用UI组件
- **工具层**: 辅助功能

各层职责明确，便于维护和扩展。
