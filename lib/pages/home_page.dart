import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/app_provider.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/category_constants.dart';
import 'add_transaction_page.dart';

/// 主页面 - 显示统计和快捷记账
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final transactionProvider = context.read<TransactionProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    final appProvider = context.read<AppProvider>();

    await Future.wait([
      transactionProvider.initialize(),
      budgetProvider.loadBudgets(appProvider.selectedYear, appProvider.selectedMonth),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<TransactionProvider, BudgetProvider>(
          builder: (context, transactionProvider, budgetProvider, child) {
            return CustomScrollView(
              slivers: [
                _buildHeader(),
                _buildStatisticsCards(transactionProvider),
                _buildBudgetProgress(budgetProvider),
                _buildQuickActions(),
                _buildRecentTransactions(transactionProvider),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('记一笔'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  /// 构建顶部标题
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '本地记账',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _dateFormatter.format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettings(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatisticsCards(TransactionProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            // 今日统计
            _buildStatCard(
              title: '今日',
              income: provider.todayIncome,
              expense: provider.todayExpense,
              balance: provider.todayBalance,
            ),
            SizedBox(height: 16.h),
            // 本周统计
            _buildStatCard(
              title: '本周',
              income: provider.weekIncome,
              expense: provider.weekExpense,
              balance: provider.weekBalance,
            ),
            SizedBox(height: 16.h),
            // 本月统计
            _buildStatCard(
              title: '本月',
              income: provider.monthIncome,
              expense: provider.monthExpense,
              balance: provider.monthBalance,
            ),
          ],
        ),
      ),
    );
  }

  /// 单个统计卡片
  Widget _buildStatCard({
    required String title,
    required double income,
    required double expense,
    required double balance,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('收入', income, Colors.green),
              _buildStatItem('支出', expense, Colors.red),
              _buildStatItem('结余', balance, balance >= 0 ? Colors.blue : Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  /// 统计项
  Widget _buildStatItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 构建预算进度条
  Widget _buildBudgetProgress(BudgetProvider budgetProvider) {
    final totalBudget = budgetProvider.budgets
        .where((b) => b.category == 'total')
        .firstOrNull;

    if (totalBudget == null) return const SliverToBoxAdapter(child: SizedBox());

    final usageRate = budgetProvider.getBudgetUsageRate('total');
    final statusColor = budgetProvider.getBudgetStatusColor(usageRate);

    Color getColor() {
      switch (statusColor) {
        case 'green': return Colors.green;
        case 'yellow': return Colors.orange;
        case 'red': return Colors.red;
        default: return Colors.green;
      }
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '本月预算',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(usageRate * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: getColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: usageRate.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(getColor()),
                  minHeight: 8,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '¥${totalBudget.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建快捷操作
  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            Expanded(
              child: _buildQuickAction(
                icon: Icons.trending_down,
                label: '支出',
                color: Colors.red,
                onTap: () => _showAddTransactionDialog(context, type: 'expense'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildQuickAction(
                icon: Icons.trending_up,
                label: '收入',
                color: Colors.green,
                onTap: () => _showAddTransactionDialog(context, type: 'income'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建最近交易记录
  Widget _buildRecentTransactions(TransactionProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最近记录',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/history'),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (provider.transactions.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Text(
                    '暂无记录',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              ...provider.transactions.take(5).map((transaction) =>
                  _buildTransactionItem(transaction)),
          ],
        ),
      ),
    );
  }

  /// 交易记录项
  Widget _buildTransactionItem(TransactionModel transaction) {
    final isExpense = transaction.type == 'expense';
    final categoryIcon = CategoryConstants.categoryIcons[transaction.category] ?? '📦';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                categoryIcon,
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  transaction.note.isEmpty ? '无备注' : transaction.note,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}¥${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// 显示添加交易对话框
  void _showAddTransactionDialog(BuildContext context, {String? type}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionPage(initialType: type),
    );
  }

  /// 显示设置
  void _showSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }
}
