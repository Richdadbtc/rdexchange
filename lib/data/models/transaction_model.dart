class TransactionModel {
  final String id;
  final String type;
  final String currency;
  final double amount;
  final String status;
  final String date;
  final String? description;
  final String icon;

  TransactionModel({
    required this.id,
    required this.type,
    required this.currency,
    required this.amount,
    required this.status,
    required this.date,
    this.description,
    required this.icon,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      currency: json['currency'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      date: json['createdAt'] ?? '',
      description: json['description'],
      icon: _getIconFromType(json['type'] ?? ''),
    );
  }

  static String _getIconFromType(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return 'fund';
      case 'withdrawal':
        return 'withdraw';
      case 'trade':
        return 'buy';
      default:
        return 'swap';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': '${currency == 'NGN' ? '₦' : ''}${amount.toStringAsFixed(2)}${currency != 'NGN' ? ' $currency' : ''}',
      'date': date,
      'status': status == 'completed' ? 'Completed' : 'Pending',
      'icon': icon,
    };
  }
}