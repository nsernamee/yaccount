/// 预算模型
class BudgetModel {
  final int? id;
  final String category; // 'total' 表示总预算
  final double amount;
  final int year;
  final int month;

  BudgetModel({
    this.id,
    required this.category,
    required this.amount,
    required this.year,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'year': year,
      'month': month,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      year: map['year'] as int,
      month: map['month'] as int,
    );
  }

  BudgetModel copyWith({
    int? id,
    String? category,
    double? amount,
    int? year,
    int? month,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }
}
