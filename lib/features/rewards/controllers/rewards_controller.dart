import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../data/models/reward_model.dart';
import '../../../data/services/reward_service.dart';

class RewardsController extends GetxController {
  final RewardService _rewardService = Get.find<RewardService>();
  
  var rewards = <RewardModel>[].obs;
  var dailyCheckIns = <DailyCheckIn>[].obs;
  var referralData = Rx<ReferralData?>(null);
  var totalRewardBalance = 0.0.obs;
  var currentStreak = 0.obs;
  var canCheckInToday = true.obs;
  var isLoading = false.obs;
  var dailyRewardConfig = <int, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }
  
  Future<void> loadAllData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadRewardsData(),
        loadReferralData(),
        loadDailyCheckInStatus(),
        loadDailyRewardConfig(),
      ]);
    } catch (e) {
      _showErrorSnackbar('Failed to load data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRewardsData() async {
    try {
      rewards.value = await _rewardService.getUserRewards();
      calculateTotalBalance();
    } catch (e) {
      _showErrorSnackbar('Failed to load rewards: $e');
    }
  }

  Future<void> loadReferralData() async {
    try {
      referralData.value = await _rewardService.getReferralData();
    } catch (e) {
      _showErrorSnackbar('Failed to load referral data: $e');
    }
  }
  
  Future<void> loadDailyRewardConfig() async {
    try {
      dailyRewardConfig.value = await _rewardService.getDailyRewardConfig();
    } catch (e) {
      // Use default config if API fails
      dailyRewardConfig.value = {
        1: 5.0, 2: 10.0, 3: 15.0, 4: 20.0,
        5: 25.0, 6: 30.0, 7: 50.0,
      };
    }
  }

  Future<void> loadDailyCheckInStatus() async {
    try {
      final statusData = await _rewardService.getDailyCheckInStatus();
      
      currentStreak.value = statusData['currentStreak'] ?? 0;
      canCheckInToday.value = statusData['canCheckInToday'] ?? false;
      
      // Build daily check-ins from API data
      final List<dynamic> checkInsData = statusData['dailyCheckIns'] ?? [];
      dailyCheckIns.value = checkInsData
          .map((json) => DailyCheckIn.fromJson(json))
          .toList();
          
      // If no data from API, generate default
      if (dailyCheckIns.isEmpty) {
        _generateDefaultCheckIns();
      }
    } catch (e) {
      _generateDefaultCheckIns();
    }
  }
  
  void _generateDefaultCheckIns() {
    final today = DateTime.now();
    dailyCheckIns.value = List.generate(7, (index) {
      final date = DateTime(today.year, today.month, today.day - (6 - index));
      final isToday = date.day == today.day;
      final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
      
      return DailyCheckIn(
        date: date,
        checked: isPast && !isToday,
        reward: dailyRewardConfig[index + 1] ?? 5.0,
        currency: 'RDX',
        streak: index + 1,
      );
    });
  }

  double _getDailyReward(int day) {
    return dailyRewardConfig[day] ?? 5.0;
  }

  Future<void> performDailyCheckIn() async {
    if (!canCheckInToday.value || isLoading.value) return;
    
    isLoading.value = true;
    
    try {
      final result = await _rewardService.performDailyCheckIn();
      
      // Add new reward from API response
      final newReward = RewardModel.fromJson(result['reward']);
      rewards.add(newReward);
      
      // Update streak and status
      currentStreak.value = result['newStreak'];
      canCheckInToday.value = false;
      
      // Refresh data
      await loadDailyCheckInStatus();
      calculateTotalBalance();
      
      Get.snackbar(
        'Check-in Successful!',
        'You earned ${newReward.amount.toStringAsFixed(1)} ${newReward.currency}!',
        backgroundColor: Color(0xFF4CAF50),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      _showErrorSnackbar('Check-in failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> claimReward(String rewardId) async {
    try {
      final success = await _rewardService.claimReward(rewardId);
      
      if (success) {
        // Update local reward status
        final rewardIndex = rewards.indexWhere((r) => r.id == rewardId);
        if (rewardIndex != -1) {
          final reward = rewards[rewardIndex];
          rewards[rewardIndex] = RewardModel(
            id: reward.id,
            type: reward.type,
            title: reward.title,
            description: reward.description,
            amount: reward.amount,
            currency: reward.currency,
            earnedDate: reward.earnedDate,
            claimed: true,
            referralCode: reward.referralCode,
          );
          
          calculateTotalBalance();
          
          Get.snackbar(
            'Reward Claimed!',
            'You claimed ${reward.amount} ${reward.currency}',
            backgroundColor: Color(0xFF4CAF50),
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to claim reward: $e');
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
  
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
  
  Future<void> refreshData() async {
    await loadAllData();
  }
}