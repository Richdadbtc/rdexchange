class RewardModel {
  final String id;
  final String type; // 'referral', 'daily_login', 'bonus'
  final String title;
  final String description;
  final double amount;
  final String currency; // 'RDX', 'USDT', 'NGN'
  final DateTime earnedDate;
  final bool claimed;
  final String? referralCode;

  RewardModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.amount,
    required this.currency,
    required this.earnedDate,
    this.claimed = false,
    this.referralCode,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      earnedDate: DateTime.parse(json['earnedDate']),
      claimed: json['claimed'] ?? false,
      referralCode: json['referralCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'earnedDate': earnedDate.toIso8601String(),
      'claimed': claimed,
      'referralCode': referralCode,
    };
  }
}

class DailyCheckIn {
  final DateTime date;
  final bool checked;
  final double reward;
  final String currency;
  final int streak;

  DailyCheckIn({
    required this.date,
    required this.checked,
    required this.reward,
    required this.currency,
    required this.streak,
  });
}

class ReferralData {
  final String referralCode;
  final int totalReferrals;
  final double totalEarnings;
  final List<String> referredUsers;
  final double pendingRewards;

  ReferralData({
    required this.referralCode,
    required this.totalReferrals,
    required this.totalEarnings,
    required this.referredUsers,
    required this.pendingRewards,
  });
}