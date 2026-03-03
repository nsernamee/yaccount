/// 交易记录模型
class TransactionModel {
  final int? id;
  final String type; // 'expense' 或 'income'
  final double amount;
  final String note;
  final String category;
  final DateTime date;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.note,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'note': note,
      'category': category,
      'transaction_date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['transaction_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  TransactionModel copyWith({
    int? id,
    String? type,
    double? amount,
    String? note,
    String? category,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
