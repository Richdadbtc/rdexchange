import 'package:get/get.dart';
import '../models/reward_model.dart';
import 'api_service.dart';
import 'notification_service.dart';

class RewardService extends GetxService {
  static RewardService get to => Get.find();
  
  // Get user rewards from backend
  Future<List<RewardModel>> getUserRewards() async {
    try {
      final response = await ApiService.get('/rewards');
      if (response['success']) {
        final List<dynamic> rewardsData = response['data'];
        return rewardsData.map((json) => RewardModel.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load rewards');
    } catch (e) {
      throw Exception('Error loading rewards: $e');
    }
  }
  
  // Get referral data from backend
  Future<ReferralData> getReferralData() async {
    try {
      final response = await ApiService.get('/rewards/referral');
      if (response['success']) {
        final data = response['data'];
        return ReferralData(
          referralCode: data['referralCode'],
          totalReferrals: data['totalReferrals'],
          totalEarnings: data['totalEarnings'].toDouble(),
          referredUsers: List<String>.from(data['referredUsers'] ?? []),
          pendingRewards: data['pendingRewards'].toDouble(),
        );
      }
      throw Exception(response['message'] ?? 'Failed to load referral data');
    } catch (e) {
      throw Exception('Error loading referral data: $e');
    }
  }
  
  // Get daily check-in status
  Future<Map<String, dynamic>> getDailyCheckInStatus() async {
    try {
      final response = await ApiService.get('/rewards/daily-checkin/status');
      if (response['success']) {
        return response['data'];
      }
      throw Exception(response['message'] ?? 'Failed to load check-in status');
    } catch (e) {
      throw Exception('Error loading check-in status: $e');
    }
  }
  
  // Perform daily check-in
  Future<Map<String, dynamic>> performDailyCheckIn() async {
    try {
      final response = await ApiService.post('/rewards/daily-checkin', {});
      
      if (response['success']) {
        // Schedule next day reminder
        final notificationService = NotificationService.to;
        final tomorrow = DateTime.now().add(Duration(days: 1));
        final reminderTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0); // 9 AM
        
        await notificationService.scheduleRewardClaimReminder(reminderTime);
      }
      
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  // Claim reward
  Future<bool> claimReward(String rewardId) async {
    try {
      final response = await ApiService.post('/rewards/claim/$rewardId', {});
      return response['success'];
    } catch (e) {
      throw Exception('Error claiming reward: $e');
    }
  }
  
  // Get daily reward configuration
  Future<Map<int, double>> getDailyRewardConfig() async {
    try {
      final response = await ApiService.get('/rewards/daily-config');
      if (response['success']) {
        final Map<String, dynamic> config = response['data'];
        return config.map((key, value) => MapEntry(int.parse(key), value.toDouble()));
      }
      return _getDefaultDailyRewards();
    } catch (e) {
      return _getDefaultDailyRewards();
    }
  }
  
  Map<int, double> _getDefaultDailyRewards() {
    return {
      1: 5.0,
      2: 10.0,
      3: 15.0,
      4: 20.0,
      5: 25.0,
      6: 30.0,
      7: 50.0,
    };
  }
}