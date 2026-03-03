# 性能优化说明文档

本文档详细说明了 YAccount 本地记账应用的性能优化策略和实现方案。

## 目录
- [启动速度优化](#启动速度优化)
- [列表流畅度优化](#列表流畅度优化)
- [图表性能优化](#图表性能优化)
- [内存管理优化](#内存管理优化)
- [数据库优化](#数据库优化)
- [包大小优化](#包大小优化)

---

## 启动速度优化

### 目标：冷启动在1.5秒内完成界面渲染

### 实现方案

#### 1. 数据库异步初始化
```dart
// lib/main.dart
class SplashPage extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _initializeApp(); // 异步初始化，不阻塞UI
  }

  Future<void> _initializeApp() async {
    final appProvider = context.read<AppProvider>();
    await appProvider.initialize(); // 异步加载

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
```

#### 2. 延迟加载非关键数据
```dart
// lib/providers/transaction_provider.dart
class TransactionProvider with ChangeNotifier {
  Future<void> initialize() async {
    // 先加载今日数据，快速显示首页
    await loadTodayTransactions();
    
    // 延迟加载本周和本月数据
    Future.microtask(() async {
      await loadWeekTransactions();
      await loadMonthTransactions();
    });
  }
}
```

---

## 列表流畅度优化

### 目标：滑动帧率稳定在 60fps

### 实现方案

#### 1. 分页加载（懒加载）
```dart
// lib/pages/history_page.dart
class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();

  void _onScroll() {
    // 滚动到底部前 200 像素时加载更多
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    final provider = context.read<TransactionProvider>();
    if (!provider.isLoading) {
      await provider.loadTransactionsPaginated(); // 每次加载20条
    }
  }
}
```

#### 2. 数据库查询优化
```dart
// lib/database/database_helper.dart
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
    limit: limit, // 分页限制
  );

  return maps.map((map) => TransactionModel.fromMap(map)).toList();
}
```

---

## 图表性能优化

### 目标：低端设备也能流畅显示图表

### 实现方案

#### 1. 数据预聚合（避免渲染500+点）
```dart
// lib/database/database_helper.dart
/// 获取按分类汇总的数据（用于饼图）
Future<Map<String, double>> getCategoryStatistics(
  String type,
  int year,
  int month,
) async {
  final db = await database;
  
  // 在数据库层面聚合数据
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
```

---

## 数据库优化

### 实现方案

#### 1. 创建索引
```dart
// lib/database/database_helper.dart
await db.execute('''
  CREATE INDEX idx_transaction_date 
  ON transactions(transaction_date DESC)
''');

await db.execute('''
  CREATE INDEX idx_transaction_type 
  ON transactions(type)
''');
```

#### 2. 批量操作使用事务
```dart
/// 批量插入交易记录（使用事务优化性能）
Future<void> insertTransactionsBatch(List<TransactionModel> transactions) async {
  final db = await database;
  final batch = db.batch(); // 使用 batch 操作
  
  for (var transaction in transactions) {
    batch.insert('transactions', transaction.toMap());
  }
  
  await batch.commit(noResult: true); // 单次提交
}
```

#### 3. 只查询需要的字段
```dart
// 避免 SELECT *
final List<Map<String, dynamic>> maps = await db.query(
  'transactions',
  columns: ['id', 'type', 'amount', 'note', 'category', 'transaction_date'],
  // 只查询需要的字段
);
```

---

## 包大小优化

### 目标：Release 包小于 15MB

### 实现方案

#### 1. Android 混淆和代码剪裁
```gradle
// android/app/build.gradle
buildTypes {
  release {
    minifyEnabled true        // 启用混淆
    shrinkResources true      // 启用资源压缩
    proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
  }
}
```

#### 2. ProGuard 规则
```pro
# android/app/proguard-rules.pro
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
```

---

## 性能监控

### 开发阶段
使用 Flutter DevTools 分析性能：
- Performance 面板：监控帧率
- Memory 面板：监控内存使用
- Network 面板：监控网络请求（虽然本应用无网络）

### 测量目标
- 冷启动时间 < 1.5秒
- 列表滑动帧率 60fps
- 图表初始化 < 300ms
- Release 包 < 15MB
