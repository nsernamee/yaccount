import 'package:flutter/material.dart';

/// 应用常量
class AppConstants {
  // 主题色
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color expenseColor = Color(0xFFE17055);
  static const Color incomeColor = Color(0xFF00B894);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);

  // 预算颜色
  static const Color budgetGreen = Color(0xFF00B894);
  static const Color budgetYellow = Color(0xFFFDCB6E);
  static const Color budgetRed = Color(0xFFE17055);

  // 分页大小
  static const int pageSize = 20;

  // 图表颜色
  static const List<Color> chartColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
    Color(0xFFAA96DA),
    Color(0xFFFCBAD3),
    Color(0xFF6C5CE7),
    Color(0xFF00B894),
    Color(0xFF636E72),
  ];
}

/// 交易类型
class TransactionType {
  static const String expense = 'expense';
  static const String income = 'income';
}
