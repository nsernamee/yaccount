/// 分类常量
class CategoryConstants {
  // 支出分类
  static const List<String> expenseCategories = [
    '餐饮',
    '交通',
    '购物',
    '娱乐',
    '医疗',
    '教育',
    '住房',
    '通讯',
    '其他',
  ];

  // 收入分类
  static const List<String> incomeCategories = [
    '工资',
    '奖金',
    '投资',
    '兼职',
    '其他',
  ];

  // 分类图标映射
  static const Map<String, String> categoryIcons = {
    // 支出
    '餐饮': '🍔',
    '交通': '🚗',
    '购物': '🛒',
    '娱乐': '🎮',
    '医疗': '💊',
    '教育': '📚',
    '住房': '🏠',
    '通讯': '📱',
    '其他': '📦',
    // 收入
    '工资': '💰',
    '奖金': '🎁',
    '投资': '📈',
    '兼职': '💼',
  };
}
