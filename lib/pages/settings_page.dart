import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSection('数据管理', [
            _buildSettingsItem(
              icon: Icons.backup,
              title: '数据导入导出',
              onTap: () => Navigator.pushNamed(context, '/import_export'),
            ),
            _buildSettingsItem(
              icon: Icons.delete_sweep,
              title: '清空所有数据',
              subtitle: '删除所有记账记录（不可恢复）',
              onTap: _showClearAllDataDialog,
            ),
          ]),
          _buildSection('安全设置', [
            _buildSettingsItem(
              icon: Icons.lock,
              title: '修改应用密码',
              onTap: () => _showChangePasswordDialog(),
            ),
          ]),
          _buildSection('关于', [
            _buildSettingsItem(
              icon: Icons.info,
              title: '应用版本',
              subtitle: 'v1.0.0',
              onTap: null,
            ),
            _buildSettingsItem(
              icon: Icons.description,
              title: '隐私政策',
              onTap: () => _showPrivacyPolicy(),
            ),
          ]),
        ],
      ),
    );
  }

  /// 构建设置分组
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: children),
        ),
      ],
    );
  }

  /// 构建设置项
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: onTap != null
            ? const Icon(Icons.chevron_right)
            : null,
        onTap: onTap,
      ),
    );
  }

  /// 显示清空所有数据确认对话框
  void _showClearAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空所有数据'),
        content: const Text(
          '此操作将删除所有记账记录，且无法恢复！\n\n确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现清空所有数据逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('确定清空'),
          ),
        ],
      ),
    );
  }

  /// 显示修改密码对话框
  void _showChangePasswordDialog() {
    // TODO: 实现修改密码功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('功能开发中')),
    );
  }

  /// 显示隐私政策
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPolicySection('数据存储', '所有数据仅存储在您的设备本地，不上传至任何服务器。'),
              SizedBox(height: 12.h),
              _buildPolicySection('网络权限', '本应用不申请任何网络权限，确保数据永不外传。'),
              SizedBox(height: 12.h),
              _buildPolicySection('数据加密', '数据库使用AES加密算法保护您的数据安全。'),
              SizedBox(height: 12.h),
              _buildPolicySection('数据删除', '您可以通过设置页面随时清空所有数据。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
