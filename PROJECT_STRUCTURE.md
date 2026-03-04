# YAccount 项目结构说明

## 项目概述

**YAccount** 是一款本地记账应用,使用 Flutter 3.x 开发,数据存储在手机本地 SQLite 数据库中,支持 Android/iOS 平台。

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
│   │   ├── constants.dart             # 常量定义
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

**数据库表结构**:

```sql
-- 交易记录表 (transactions)
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,           -- 'expense' 或 'income'
  amount REAL NOT NULL,         -- 金额
  category TEXT NOT NULL,       -- 分类
  note TEXT,                    -- 备注
  date TEXT NOT NULL            -- 日期 (YYYY-MM-DD)
);
CREATE INDEX idx_transaction_date ON transactions(date);

-- 预算表 (budgets)
CREATE TABLE budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT NOT NULL,       -- 分类 (总预算为 'total')
  amount REAL NOT NULL,         -- 预算金额
  month TEXT NOT NULL           -- 月份 (YYYY-MM)
);
CREATE UNIQUE INDEX idx_budget_month_category ON budgets(month, category);
```

**关键方法**:
- `get database`: 获取数据库实例(单例)
- `_initDatabase()`: 初始化数据库
- `_onCreate()`: 创建表结构
- `_onUpgrade()`: 升级数据库版本
- `insertTransaction()`: 插入交易记录
- `updateTransaction()`: 更新交易记录
- `deleteTransaction()`: 删除交易记录
- `getTransactions()`: 查询交易记录(支持分页)
- `getStatistics()`: 获取统计数据
- `saveBudget()`: 保存预算
- `getBudget()`: 查询预算

---

### 2. 数据模型层 (models/)

#### `transaction_model.dart`

**用途**: 定义交易记录的数据结构

```dart
class TransactionModel {
  final int? id;
  final String type;        // 'expense' 或 'income'
  final double amount;
  final String category;
  final String? note;
  final String date;

  // 转换方法
  Map<String, dynamic> toMap()
  factory TransactionModel.fromMap(Map<String, dynamic> map)
}
```

#### `category_model.dart`

**用途**: 定义分类数据结构

```dart
class CategoryModel {
  final String name;
  final String icon;
  final Color color;
}
```

#### `budget_model.dart`

**用途**: 定义预算数据结构

```dart
class BudgetModel {
  final int? id;
  final String category;
  final double amount;
  final String month;
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

**职责**: 管理交易数据

**状态**:
- `transactions`: 交易列表
- `isLoading`: 加载状态
- `todayIncome`: 今日收入
- `todayExpense`: 今日支出
- `todayBalance`: 今日结余
- `weekIncome`: 本周收入
- `weekExpense`: 本周支出
- `weekBalance`: 本周结余
- `monthIncome`: 本月收入
- `monthExpense`: 本月支出
- `monthBalance`: 本月结余

**方法**:
- `loadTransactions()`: 加载交易记录
- `loadStatistics()`: 加载统计数据
- `addTransaction()`: 添加交易
- `updateTransaction()`: 更新交易
- `deleteTransaction()`: 删除交易
- `importTransactions()`: 导入交易
- `exportTransactions()`: 导出交易

---

#### `budget_provider.dart`

**职责**: 管理预算数据

**状态**:
- `budgets`: 预算列表
- `totalBudget`: 总预算
- `totalSpent`: 总支出

**方法**:
- `loadBudgets()`: 加载预算
- `saveBudget()`: 保存预算
- `deleteBudget()`: 删除预算
- `getBudgetUsage()`: 获取预算使用率

---

### 4. 页面层 (pages/)

#### `home_page.dart` - 首页

**功能**:
- 展示今日/本周/本月收支统计
- 显示预算进度条(颜色根据使用率变化)
- 快捷添加交易按钮
- 快捷访问各功能入口

**UI组件**:
- 统计卡片(收入/支出/结余)
- 预算进度条
- 最近交易列表

---

#### `add_transaction_page.dart` - 添加交易

**功能**:
- 切换支出/收入类型
- 输入金额
- 选择分类
- 输入备注
- 修改日期
- 保存交易

**UI组件**:
- 类型切换 Tab
- 金额输入框
- 分类选择器
- 日期选择器
- 保存按钮

---

#### `history_page.dart` - 历史记录

**功能**:
- 按日期倒序显示交易记录
- 分页加载(每次20条)
- 滑动删除交易
- 编辑交易

**UI组件**:
- 列表视图
- 滑动操作菜单
- 加载更多指示器

---

#### `statistics_page.dart` - 统计图表

**功能**:
- 饼图: 支出分类占比
- 柱状图: 近6个月收支对比
- 折线图: 当月每日支出趋势
- 月份切换

**UI组件**:
- Tab 切换(饼图/柱状图/折线图)
- 图表容器
- 月份选择器

---

#### `budget_page.dart` - 预算管理

**功能**:
- 设置月度总预算
- 设置分类预算
- 查看预算使用率
- 预算超支提醒

**UI组件**:
- 预算列表
- 进度条
- 添加/编辑/删除按钮

---

#### `import_export_page.dart` - 导入导出

**功能**:
- 导出为 CSV 文件
- 导出为 Excel 文件
- 导入 CSV 文件
- 导入 Excel 文件
- 选择导入方式(增量/覆盖)

**UI组件**:
- 导出按钮
- 文件选择器
- 导入选项

---

#### `settings_page.dart` - 设置

**功能**:
- 设置/修改应用密码
- 关闭应用密码
- 查看关于信息
- 清空所有数据

**UI组件**:
- 设置项列表
- 密码输入框
- 确认对话框

---

### 5. 组件层 (widgets/)

#### `common_widgets.dart`

**通用组件**:
- `BudgetProgressBar`: 预算进度条组件
- `StatCard`: 统计卡片组件
- `TransactionItem`: 交易条目组件

#### `category_selector.dart`

**分类选择器**:
- 网格布局展示分类
- 支持分类图标和颜色
- 选中状态反馈

---

### 6. 工具层 (utils/)

#### `constants.dart`

**常量定义**:
- 应用主题色
- 分类列表
- 预设预算

#### `date_utils.dart`

**日期工具**:
- 获取日期范围(今日/本周/本月)
- 日期格式化
- 日期比较

---

### 7. 应用入口 (main.dart)

**职责**:
- 应用初始化
- 配置主题
- 配置路由
- 启动画面

**结构**:
```dart
void main() → 初始化系统UI → 运行应用
  └── YAccountApp
      └── MultiProvider (状态管理)
          └── MaterialApp
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

### 2. 查询统计流程

```
HomePage 请求数据
    ↓
TransactionProvider.loadStatistics()
    ↓
DatabaseHelper.getStatistics()
    ↓
SQLite Database (聚合查询)
    ↓
返回统计结果
    ↓
UI 展示数据
```

### 3. 导入导出流程

```
导入:
选择文件 → ImportExportPage → 解析文件 → TransactionProvider.importTransactions() → Database

导出:
TransactionProvider.exportTransactions() → 生成文件 → 保存/分享
```

---

## 性能优化措施

1. **数据库索引**: 为 `transactions.date` 字段建立索引,加速日期查询
2. **分页加载**: 历史记录每次加载20条,避免一次性加载大量数据
3. **异步初始化**: 数据库异步初始化,不阻塞UI启动
4. **数据聚合**: 统计查询使用 SQL GROUP BY,减少数据传输量
5. **图表优化**: 图表数据预聚合,减少渲染压力

---

## 数据安全

1. **数据库加密**: 使用 `sqflite_sqlcipher` 支持数据库加密
2. **密码保护**: 应用密码通过 SHA256 派生为数据库密钥
3. **无网络权限**: Android/iOS 均不申请网络权限
4. **数据隔离**: 数据存储在应用私有目录,其他应用无法访问

---

## 总结

YAccount 采用清晰的分层架构:

- **数据库层**: 负责数据持久化
- **模型层**: 定义数据结构
- **状态管理层**: 管理业务逻辑
- **页面层**: 负责UI展示
- **组件层**: 可复用UI组件
- **工具层**: 辅助功能

各层职责明确,便于维护和扩展。
