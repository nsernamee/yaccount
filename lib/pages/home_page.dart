import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'add_transaction_page.dart';
import 'history_page.dart';
import 'statistics_page.dart';
import 'budget_page.dart';
import 'import_export_page.dart';
import 'settings_page.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactionProvider = context.read<TransactionProvider>();
    final budgetProvider = context.read<BudgetProvider>();
    await Future.wait([
      transactionProvider.initialize(),
      budgetProvider.initialize(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeContent(),
          HistoryPage(),
          StatisticsPage(),
          BudgetPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: '历史',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: '预算',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

/// 首页内容
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _isStatisticsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<TransactionProvider>().refresh();
          await context.read<BudgetProvider>().initialize();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            SliverToBoxAdapter(
              child: _buildQuickActions(context),
            ),
            SliverToBoxAdapter(
              child: _buildBudgetProgress(context),
            ),
            SliverToBoxAdapter(
              child: _buildStatistics(context),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppConstants.primaryColor, Color(0xFF8B7CF7)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YAccount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // 货币选择器
                  PopupMenuButton<Currency>(
                    initialValue: context.read<CurrencyManager>().current,
                    onSelected: (currency) async {
                      await context.read<CurrencyManager>().setCurrency(currency);
                    },
                    offset: const Offset(0, 40),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => Currency.supportedCurrencies
                        .map((c) => PopupMenuItem(
                              value: c,
                              child: Row(
                                children: [
                                  Text(
                                    c.symbol,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            ))
                        .toList(),
                    child: Consumer<CurrencyManager>(
                      builder: (context, currencyManager, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currencyManager.current.symbol,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ImportExportPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swap_horiz,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '导入导出',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '本月结余',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Consumer2<TransactionProvider, CurrencyManager>(
            builder: (context, provider, currencyManager, _) {
              final balance = (provider.monthStats['income'] ?? 0) -
                  (provider.monthStats['expense'] ?? 0);
              final isNegative = balance < 0;
              final isTrillion = balance.abs() >= 1000000000000;
              final fontSize = isTrillion ? 28.0 : 42.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isNegative && !isTrillion)
                        Text(
                          '-',
                          style: TextStyle(
                            color: isNegative ? Colors.red[400] : Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      Text(
                        AppConstants.formatAmountCompact(balance),
                        style: TextStyle(
                          color: isNegative ? Colors.red[400] : Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (!isTrillion)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, right: 4),
                          child: Text(
                            currencyManager.current.symbol,
                            style: TextStyle(
                              color: isNegative ? Colors.red[400] : Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isTrillion)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        currencyManager.current.symbol,
                        style: TextStyle(
                          color: isNegative ? Colors.red[400] : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isStatisticsExpanded = !_isStatisticsExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '收支概览',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
                Icon(
                  _isStatisticsExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppConstants.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Consumer<TransactionProvider>(
            builder: (context, provider, _) {
              return AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                  child: Column(
                  children: [
                    // 今日统计
                    StatCardRow(
                      leftCard: StatCard(
                        title: '今日支出',
                        amount: provider.todayStats['expense'] ?? 0,
                        color: AppConstants.expenseColor,
                        icon: Icons.arrow_downward,
                      ),
                      rightCard: StatCard(
                        title: '今日收入',
                        amount: provider.todayStats['income'] ?? 0,
                        color: AppConstants.incomeColor,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 本周统计
                    StatCardRow(
                      leftCard: StatCard(
                        title: '本周支出',
                        amount: provider.weekStats['expense'] ?? 0,
                        color: AppConstants.expenseColor,
                        icon: Icons.date_range,
                      ),
                      rightCard: StatCard(
                        title: '本周收入',
                        amount: provider.weekStats['income'] ?? 0,
                        color: AppConstants.incomeColor,
                        icon: Icons.trending_up,
                      ),
                    ),
                    if (_isStatisticsExpanded) ...[
                      const SizedBox(height: 12),
                      // 本月统计
                      StatCardRow(
                        leftCard: StatCard(
                          title: '本月支出',
                          amount: provider.monthStats['expense'] ?? 0,
                          color: AppConstants.expenseColor,
                          icon: Icons.calendar_month,
                        ),
                        rightCard: StatCard(
                          title: '本月收入',
                          amount: provider.monthStats['income'] ?? 0,
                          color: AppConstants.incomeColor,
                          icon: Icons.account_balance_wallet,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 本年统计
                      StatCardRow(
                        leftCard: StatCard(
                          title: '本年支出',
                          amount: provider.yearStats['expense'] ?? 0,
                          color: AppConstants.expenseColor,
                          icon: Icons.event,
                        ),
                        rightCard: StatCard(
                          title: '本年收入',
                          amount: provider.yearStats['income'] ?? 0,
                          color: AppConstants.incomeColor,
                          icon: Icons.trending_up,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetProgress(BuildContext context) {
    return Consumer2<TransactionProvider, BudgetProvider>(
      builder: (context, transactionProvider, budgetProvider, _) {
        final totalBudget = budgetProvider.totalBudget;
        if (totalBudget == null) return const SizedBox.shrink();

        final monthStats = transactionProvider.monthStats;
        final spent = monthStats['expense'] ?? 0;
        final budget = totalBudget.amount;
        final rate = budgetProvider.calculateUsageRate(spent, budget);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '预算进度',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(budgetProvider.getUsageColor(rate))
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${rate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Color(budgetProvider.getUsageColor(rate)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BudgetProgressBar(
                  spent: spent,
                  budget: budget,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快速记账',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.arrow_downward,
                  label: '支出',
                  color: AppConstants.expenseColor,
                  onTap: () => _showTransactionType(context, 'expense'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.arrow_upward,
                  label: '收入',
                  color: AppConstants.incomeColor,
                  onTap: () => _showTransactionType(context, 'income'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransactionType(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionPage(initialType: type),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
