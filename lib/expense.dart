class Expense {
  final int id;
  final String item;
  final double amount;
  final DateTime date;

  const Expense({
    required this.id,
    required this.item,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item': item,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Expense{id: $id, item: $item, amount: $amount, date: ${date.toIso8601String()}}';
  }
}