import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

/// 数据导入导出页面
class ImportExportPage extends StatefulWidget {
  const ImportExportPage({super.key});

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据导入导出'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildExportSection(),
          SizedBox(height: 24.h),
          _buildImportSection(),
          SizedBox(height: 24.h),
          _buildInfoSection(),
        ],
      ),
    );
  }

  /// 构建导出区域
  Widget _buildExportSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
            children: [
              Icon(Icons.download, color: Theme.of(context).primaryColor),
              SizedBox(width: 12.w),
              Text(
                '导出数据',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '将您的记账数据导出为CSV文件，可用于备份或查看',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportData,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.file_download),
              label: Text(_isExporting ? '导出中...' : '导出为CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建导入区域
  Widget _buildImportSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
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
            children: [
              Icon(Icons.upload, color: Theme.of(context).primaryColor),
              SizedBox(width: 12.w),
              Text(
                '导入数据',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '从CSV文件导入记账数据，可选择增量导入或覆盖原有数据',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isImporting ? null : () => _importData(false),
                  icon: _isImporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(_isImporting ? '导入中...' : '增量导入'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isImporting ? null : () => _importData(true),
                  icon: _isImporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isImporting ? '导入中...' : '覆盖导入'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建信息区域
  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8.w),
              Text(
                '注意事项',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInfoItem('• 导入文件格式必须与导出格式一致'),
          SizedBox(height: 8.h),
          _buildInfoItem('• 增量导入不会删除现有数据'),
          SizedBox(height: 8.h),
          _buildInfoItem('• 覆盖导入将清空所有现有数据，请谨慎操作'),
          SizedBox(height: 8.h),
          _buildInfoItem('• 导入前建议先备份现有数据'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        color: Colors.blue[800],
      ),
    );
  }

  /// 导出数据
  Future<void> _exportData() async {
    setState(() => _isExporting = true);

    try {
      final provider = context.read<TransactionProvider>();
      final transactions = await provider.getAllTransactions();

      if (transactions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('暂无数据可导出')),
          );
        }
        return;
      }

      // 生成CSV数据
      final List<List<String>> csvData = [
        ['日期', '类型', '分类', '金额', '备注', '创建时间'],
        ...transactions.map((t) => [
          DateFormat('yyyy-MM-dd').format(t.date),
          t.type == 'expense' ? '支出' : '收入',
          t.category,
          t.amount.toString(),
          t.note,
          DateFormat('yyyy-MM-dd HH:mm:ss').format(t.createdAt),
        ]),
      ];

      final csvString = const ListToCsvConverter().convert(csvData);

      // 选择保存位置
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) return;

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('$directory/yaccount_export_$timestamp.csv');
      await file.writeAsString(csvString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出成功: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// 导入数据
  Future<void> _importData(bool overwrite) async {
    // 覆盖导入需要二次确认
    if (overwrite) {
      final confirmed = await _showOverwriteConfirmDialog();
      if (!confirmed) return;
    }

    setState(() => _isImporting = true);

    try {
      // 选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();

      // 解析CSV
      final List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);

      if (csvTable.length < 2) {
        throw Exception('CSV文件格式错误');
      }

      // 跳过标题行
      final rows = csvTable.skip(1).toList();

      // 解析数据
      final List<TransactionModel> transactions = [];
      for (var row in rows) {
        try {
          final transaction = TransactionModel(
            date: DateFormat('yyyy-MM-dd').parse(row[0].toString()),
            type: row[1].toString() == '支出' ? 'expense' : 'income',
            category: row[2].toString(),
            amount: double.parse(row[3].toString()),
            note: row[4].toString(),
            createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').parse(row[5].toString()),
          );
          transactions.add(transaction);
        } catch (e) {
          print('解析行失败: $e');
        }
      }

      if (transactions.isEmpty) {
        throw Exception('未找到有效数据');
      }

      final provider = context.read<TransactionProvider>();

      // 如果是覆盖模式，先删除所有数据
      if (overwrite) {
        final allTransactions = await provider.getAllTransactions();
        for (var t in allTransactions) {
          await provider.deleteTransaction(t.id!);
        }
      }

      // 批量插入数据
      for (var t in transactions) {
        await provider.addTransaction(t);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入成功: ${transactions.length}条记录')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  /// 显示覆盖导入确认对话框
  Future<bool> _showOverwriteConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认覆盖'),
        content: const Text(
          '覆盖导入将清空所有现有数据，此操作不可撤销！\n\n确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确定覆盖'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
