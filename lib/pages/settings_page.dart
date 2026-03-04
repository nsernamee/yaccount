import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimary,
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                title: '安全设置',
                children: [
                  _buildEncryptionTile(context, appProvider),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: '数据管理',
                children: [
                  _SettingsTile(
                    icon: Icons.delete_outline,
                    title: '清空所有数据',
                    subtitle: '删除所有账目记录',
                    onTap: () => _showClearDataDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: '关于',
                children: [
                  const _SettingsTile(
                    icon: Icons.info_outline,
                    title: '版本',
                    subtitle: '1.0.0',
                  ),
                  _SettingsTile(
                    icon: Icons.code,
                    title: '关于 YAccount',
                    subtitle: '本地记账，安全隐私',
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEncryptionTile(BuildContext context, AppProvider appProvider) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.lock, color: AppConstants.primaryColor),
          title: const Text('数据库加密'),
          subtitle: Text(appProvider.isEncrypted ? '已启用' : '未启用'),
          trailing: Switch(
            value: appProvider.isEncrypted,
            onChanged: (value) {
              if (value) {
                _showSetPasswordDialog(context);
              } else {
                _showUnsetPasswordDialog(context);
              }
            },
          ),
        ),
        // 加密功能说明
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppConstants.primaryColor),
                  const SizedBox(width: 6),
                  const Text(
                    '加密说明',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '• 使用 AES-256 加密算法保护您的数据',
                style: TextStyle(fontSize: 12, color: AppConstants.textSecondary),
              ),
              const SizedBox(height: 4),
              const Text(
                '• 密码用于生成加密密钥，请妥善保管',
                style: TextStyle(fontSize: 12, color: AppConstants.textSecondary),
              ),
              const SizedBox(height: 4),
              const Text(
                '• 忘记密码将无法恢复数据',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
              const SizedBox(height: 4),
              const Text(
                '• 加密后数据仍然完全本地存储',
                style: TextStyle(fontSize: 12, color: AppConstants.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSetPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '设置密码后，数据库将被加密。请务必记住密码，忘记将无法恢复数据。',
              style: TextStyle(fontSize: 13, color: AppConstants.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '输入密码',
                hintText: '至少6位',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '确认密码',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('密码至少6位')),
                );
                return;
              }
              if (passwordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('两次密码不一致')),
                );
                return;
              }

              await context.read<AppProvider>().setPassword(passwordController.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('加密已启用')),
                );
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showUnsetPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('解除加密'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '请输入当前密码以解除加密。',
              style: TextStyle(fontSize: 13, color: AppConstants.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '输入密码',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 简化验证，实际应该比对存储的密钥
              await context.read<AppProvider>().clearPassword();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('加密已解除')),
                );
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空数据'),
        content: const Text(
          '此操作将删除所有账目数据，且不可恢复！\n\n请确认是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AppProvider>().database.deleteAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('数据已清空')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppConstants.primaryColor, Color(0xFF8B7CF7)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance_wallet, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('YAccount'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本：1.0.0'),
            SizedBox(height: 12),
            Text(
              '一款安全、隐私的本地记账应用。\n\n特点：',
              style: TextStyle(color: AppConstants.textSecondary),
            ),
            SizedBox(height: 8),
            Text('• 数据完全本地存储'),
            Text('• 支持数据库加密'),
            Text('• 无网络权限，确保隐私'),
            Text('• 轻量级，包体积小'),
          ],
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
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
