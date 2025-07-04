import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../data/models/reward_model.dart';

class RewardsController extends GetxController {
  var rewards = <RewardModel>[].obs;
  var dailyCheckIns = <DailyCheckIn>[].obs;
  var referralData = Rx<ReferralData?>(null);
  var totalRewardBalance = 0.0.obs;
  var currentStreak = 0.obs;
  var canCheckInToday = true.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRewardsData();
    checkDailyLoginStatus();
    loadReferralData();
  }

  void loadRewardsData() {
    // Simulate loading rewards data
    rewards.value = [
      RewardModel(
        id: '1',
        type: 'daily_login',
        title: 'Daily Login Bonus',
        description: 'Login reward for day 5',
        amount: 10.0,
        currency: 'RDX',
        earnedDate: DateTime.now().subtract(Duration(days: 1)),
        claimed: true,
      ),
      RewardModel(
        id: '2',
        type: 'referral',
        title: 'Referral Bonus',
        description: 'Friend joined using your code',
        amount: 50.0,
        currency: 'USDT',
        earnedDate: DateTime.now().subtract(Duration(days: 3)),
        claimed: false,
        referralCode: 'RDX123ABC',
      ),
      RewardModel(
        id: '3',
        type: 'bonus',
        title: 'Welcome Bonus',
        description: 'Welcome to RDX Exchange',
        amount: 100.0,
        currency: 'RDX',
        earnedDate: DateTime.now().subtract(Duration(days: 7)),
        claimed: true,
      ),
    ];
    
    calculateTotalBalance();
  }

  void loadReferralData() {
    referralData.value = ReferralData(
      referralCode: 'RDX${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      totalReferrals: 5,
      totalEarnings: 250.0,
      referredUsers: ['user1@example.com', 'user2@example.com'],
      pendingRewards: 50.0,
    );
  }

  void checkDailyLoginStatus() {
    // Simulate daily check-in data
    final today = DateTime.now();
    final lastCheckIn = DateTime(today.year, today.month, today.day - 1);
    
    dailyCheckIns.value = List.generate(7, (index) {
      final date = DateTime(today.year, today.month, today.day - (6 - index));
      final isToday = date.day == today.day;
      final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
      
      return DailyCheckIn(
        date: date,
        checked: isPast && !isToday,
        reward: _getDailyReward(index + 1),
        currency: 'RDX',
        streak: index + 1,
      );
    });
    
    currentStreak.value = 4; // Simulate current streak
    canCheckInToday.value = true; // User can check in today
  }

  double _getDailyReward(int day) {
    switch (day) {
      case 1: return 5.0;
      case 2: return 10.0;
      case 3: return 15.0;
      case 4: return 20.0;
      case 5: return 25.0;
      case 6: return 30.0;
      case 7: return 50.0;
      default: return 5.0;
    }
  }

  void performDailyCheckIn() {
    if (!canCheckInToday.value) return;
    
    isLoading.value = true;
    
    // Simulate API call
    Future.delayed(Duration(seconds: 2), () {
      final today = DateTime.now();
      final todayReward = _getDailyReward(currentStreak.value + 1);
      
      // Add new reward
      rewards.add(RewardModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'daily_login',
        title: 'Daily Login Bonus',
        description: 'Day ${currentStreak.value + 1} login reward',
        amount: todayReward,
        currency: 'RDX',
        earnedDate: today,
        claimed: true,
      ));
      
      // Update streak
      currentStreak.value++;
      canCheckInToday.value = false;
      
      // Update daily check-ins
      checkDailyLoginStatus();
      calculateTotalBalance();
      
      isLoading.value = false;
      
      Get.snackbar(
        'Check-in Successful!',
        'You earned ${todayReward.toStringAsFixed(1)} RDX tokens!',
        backgroundColor: Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    });
  }

  void claimReward(String rewardId) {
    final rewardIndex = rewards.indexWhere((r) => r.id == rewardId);
    if (rewardIndex != -1 && !rewards[rewardIndex].claimed) {
      rewards[rewardIndex] = RewardModel(
        id: rewards[rewardIndex].id,
        type: rewards[rewardIndex].type,
        title: rewards[rewardIndex].title,
        description: rewards[rewardIndex].description,
        amount: rewards[rewardIndex].amount,
        currency: rewards[rewardIndex].currency,
        earnedDate: rewards[rewardIndex].earnedDate,
        claimed: true,
        referralCode: rewards[rewardIndex].referralCode,
      );
      
      calculateTotalBalance();
      
      Get.snackbar(
        'Reward Claimed!',
        'You claimed ${rewards[rewardIndex].amount} ${rewards[rewardIndex].currency}',
        backgroundColor: Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    }
  }

  void copyReferralCode() {
    if (referralData.value != null) {
      Clipboard.setData(ClipboardData(text: referralData.value!.referralCode));
      Get.snackbar(
        'Copied!',
        'Referral code copied to clipboard',
        backgroundColor: Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    }
  }

  void shareReferralCode() {
    if (referralData.value != null) {
      // Implement share functionality
      Get.snackbar(
        'Share',
        'Share functionality will be implemented',
        backgroundColor: Color(0xFF2196F3),
        colorText: Colors.white,
      );
    }
  }

  void calculateTotalBalance() {
    totalRewardBalance.value = rewards
        .where((r) => r.claimed)
        .fold(0.0, (sum, reward) => sum + reward.amount);
  }
}