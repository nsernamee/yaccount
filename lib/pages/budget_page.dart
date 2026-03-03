import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/budget_model.dart';
import '../providers/budget_provider.dart';
import '../providers/app_provider.dart';
import '../models/category_constants.dart';

/// 预算管理页面
class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final budgetProvider = context.read<BudgetProvider>();
    final appProvider = context.read<AppProvider>();
    await budgetProvider.loadBudgets(appProvider.selectedYear, appProvider.selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预算管理'),
        centerTitle: true,
      ),
      body: Consumer2<BudgetProvider, AppProvider>(
        builder: (context, budgetProvider, appProvider, child) {
          if (budgetProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildMonthSelector(appProvider),
              Expanded(
                child: budgetProvider.budgets.isEmpty
                    ? _buildEmptyState()
                    : _buildBudgetList(budgetProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建月份选择器
  Widget _buildMonthSelector(AppProvider appProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              appProvider.previousMonth();
              _loadBudgets();
            },
          ),
          Text(
            '${appProvider.selectedYear}年${appProvider.selectedMonth}月',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              appProvider.nextMonth();
              _loadBudgets();
            },
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64.w,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无预算',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '点击右下角按钮添加预算',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建预算列表
  Widget _buildBudgetList(BudgetProvider budgetProvider) {
    final budgets = budgetProvider.budgets;
    final totalBudget = budgets.where((b) => b.category == 'total').firstOrNull;

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // 总预算
        if (totalBudget != null)
          _buildBudgetCard(budgetProvider, totalBudget, isTotal: true),
        
        // 分类预算
        ...budgets.where((b) => b.category != 'total').map((budget) =>
            _buildBudgetCard(budgetProvider, budget)),
      ],
    );
  }

  /// 构建预算卡片
  Widget _buildBudgetCard(
    BudgetProvider budgetProvider,
    BudgetModel budget, {
    bool isTotal = false,
  }) {
    final usageRate = budgetProvider.getBudgetUsageRate(budget.category);
    final statusColor = budgetProvider.getBudgetStatusColor(usageRate);

    Color getColor() {
      switch (statusColor) {
        case 'green': return Colors.green;
        case 'yellow': return Colors.orange;
        case 'red': return Colors.red;
        default: return Colors.green;
      }
    }

    String getIcon() {
      if (isTotal) return '💰';
      return CategoryConstants.categoryIcons[budget.category] ?? '📦';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
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
              Row(
                children: [
                  Text(
                    getIcon(),
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTotal ? '总预算' : budget.category,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '¥${budget.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: getColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${(usageRate * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: getColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已使用: ¥${(budget.amount * usageRate).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              if (budgetProvider.isOverBudget(budget.category))
                Text(
                  '已超支',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditBudgetDialog(budget),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('编辑'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteBudgetDialog(budget),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('删除'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 显示添加预算对话框
  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => BudgetDialog(
        onSave: (budget) async {
          await context.read<BudgetProvider>().saveBudget(budget);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('预算添加成功')),
            );
          }
        },
        appProvider: context.read<AppProvider>(),
      ),
    );
  }

  /// 显示编辑预算对话框
  void _showEditBudgetDialog(BudgetModel budget) {
    showDialog(
      context: context,
      builder: (context) => BudgetDialog(
        budget: budget,
        onSave: (updatedBudget) async {
          await context.read<BudgetProvider>().saveBudget(updatedBudget);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('预算更新成功')),
            );
          }
        },
        appProvider: context.read<AppProvider>(),
      ),
    );
  }

  /// 显示删除预算确认对话框
  void _showDeleteBudgetDialog(BudgetModel budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除${budget.category == 'total' ? '总' : budget.category}预算吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<BudgetProvider>().deleteBudget(budget.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('预算删除成功')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 预算对话框
class BudgetDialog extends StatefulWidget {
  final BudgetModel? budget;
  final Function(BudgetModel) onSave;
  final AppProvider appProvider;

  const BudgetDialog({
    super.key,
    this.budget,
    required this.onSave,
    required this.appProvider,
  });

  @override
  State<BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  late String _selectedCategory;
  late String _selectedCategoryLabel;

  @override
  void initState() {
    super.initState();
    
    if (widget.budget != null) {
      _selectedCategory = widget.budget!.category;
      _amountController.text = widget.budget!.amount.toString();
    } else {
      _selectedCategory = 'total';
    }
    
    _updateCategoryLabel();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateCategoryLabel() {
    if (_selectedCategory == 'total') {
      _selectedCategoryLabel = '总预算';
    } else {
      _selectedCategoryLabel = _selectedCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.budget == null ? '添加预算' : '编辑预算'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '选择分类',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: 'total', child: Text('总预算')),
                ...CategoryConstants.expenseCategories.map((category) =>
                    DropdownMenuItem(value: category, child: Text(category))),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                    _updateCategoryLabel();
                  });
                }
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '预算金额',
                border: OutlineInputBorder(),
                prefixText: '¥',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入预算金额';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return '请输入有效的金额';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveBudget,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _saveBudget() {
    if (!_formKey.currentState!.validate()) return;

    final budget = BudgetModel(
      id: widget.budget?.id,
      category: _selectedCategory,
      amount: double.parse(_amountController.text),
      year: widget.appProvider.selectedYear,
      month: widget.appProvider.selectedMonth,
    );

    widget.onSave(budget);
    Navigator.pop(context);
  }
}
