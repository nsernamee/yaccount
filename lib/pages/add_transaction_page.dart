import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../models/category_constants.dart';

/// 添加/编辑交易记录页面
class AddTransactionPage extends StatefulWidget {
  final TransactionModel? transaction;
  final String? initialType;

  const AddTransactionPage({
    super.key,
    this.transaction,
    this.initialType,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _type = 'expense';
  String _category = '餐饮';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    if (widget.transaction != null) {
      // 编辑模式
      _type = widget.transaction!.type;
      _category = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
      _amountController.text = widget.transaction!.amount.toString();
      _noteController.text = widget.transaction!.note;
    } else if (widget.initialType != null) {
      // 新增模式，指定类型
      _type = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    SizedBox(height: 20.h),
                    _buildAmountInput(),
                    SizedBox(height: 20.h),
                    _buildCategorySelector(),
                    SizedBox(height: 20.h),
                    _buildDatePicker(),
                    SizedBox(height: 20.h),
                    _buildNoteInput(),
                    SizedBox(height: 32.h),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建顶部标题栏
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.transaction == null ? '添加记录' : '编辑记录',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, size: 24.w),
          ),
        ],
      ),
    );
  }

  /// 构建类型选择器
  Widget _buildTypeSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = 'expense'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _type == 'expense' ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '支出',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _type == 'expense' ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = 'income'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _type == 'income' ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '收入',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _type == 'income' ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建金额输入
  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '金额',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: '¥',
            prefixStyle: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: _type == 'expense' ? Colors.red : Colors.green,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            hintText: '0.00',
            hintStyle: TextStyle(
              fontSize: 24.sp,
              color: Colors.grey[400],
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入金额';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return '请输入有效的金额';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 构建分类选择器
  Widget _buildCategorySelector() {
    final categories = _type == 'expense'
        ? CategoryConstants.expenseCategories
        : CategoryConstants.incomeCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 2.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final icon = CategoryConstants.categoryIcons[category] ?? '📦';
            final isSelected = _category == category;

            return GestureDetector(
              onTap: () => setState(() => _category = category),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (_type == 'expense' ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1))
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? (_type == 'expense' ? Colors.red : Colors.green)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(icon, style: TextStyle(fontSize: 20.sp)),
                    SizedBox(height: 4.h),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected
                            ? (_type == 'expense' ? Colors.red : Colors.green)
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建日期选择器
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '日期',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _selectDate(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20.w, color: Colors.grey[600]),
                    SizedBox(width: 12.w),
                    Text(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, size: 24.w),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建备注输入
  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '备注',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            hintText: '添加备注（可选）',
          ),
        ),
      ],
    );
  }

  /// 构建保存按钮
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: _type == 'expense' ? Colors.red : Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          '保存',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 选择日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  /// 保存交易记录
  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final transaction = TransactionModel(
      id: widget.transaction?.id,
      type: _type,
      amount: amount,
      note: _noteController.text.trim(),
      category: _category,
      date: _selectedDate,
      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
    );

    final provider = context.read<TransactionProvider>();

    if (widget.transaction == null) {
      provider.addTransaction(transaction);
    } else {
      provider.updateTransaction(transaction);
    }

    Navigator.pop(context);
  }
}
