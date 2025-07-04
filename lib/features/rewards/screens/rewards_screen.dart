import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../controllers/rewards_controller.dart';
import '../../../data/models/reward_model.dart';

class RewardsScreen extends StatelessWidget {
  final RewardsController controller = Get.put(RewardsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Rewards',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRewardsSummary(),
            SizedBox(height: 24),
            _buildDailyCheckIn(),
            SizedBox(height: 24),
            _buildReferralSection(),
            SizedBox(height: 24),
            _buildRewardsHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsSummary() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MaterialCommunityIcons.trophy,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Total Rewards Earned',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Obx(() => Text(
            '${controller.totalRewardBalance.value.toStringAsFixed(2)} RDX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          )),
          SizedBox(height: 8),
          Text(
            'Keep earning by referring friends and daily check-ins!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCheckIn() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    MaterialCommunityIcons.calendar_check,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Daily Check-in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.currentStreak.value} day streak',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
            ],
          ),
          SizedBox(height: 16),
          Obx(() => GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: controller.dailyCheckIns.length,
            itemBuilder: (context, index) {
              final checkIn = controller.dailyCheckIns[index];
              final isToday = checkIn.date.day == DateTime.now().day;
              
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: checkIn.checked 
                            ? Color(0xFF4CAF50)
                            : isToday 
                                ? Color(0xFF4CAF50).withOpacity(0.3)
                                : Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(8),
                        border: isToday 
                            ? Border.all(color: Color(0xFF4CAF50), width: 2)
                            : null,
                      ),
                      child: Center(
                        child: checkIn.checked
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                '${checkIn.date.day}',
                                style: TextStyle(
                                  color: isToday ? Color(0xFF4CAF50) : Colors.grey[400],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      '${checkIn.reward.toInt()}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              );
            },
          )),
          SizedBox(height: 16),
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.canCheckInToday.value && !controller.isLoading.value
                  ? controller.performDailyCheckIn
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      controller.canCheckInToday.value ? 'Check In Today' : 'Already Checked In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildReferralSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MaterialCommunityIcons.account_multiple_plus,
                color: Color(0xFF2196F3),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Refer Friends',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Earn 50 USDT for each friend who joins using your referral code!',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          Obx(() {
            final referral = controller.referralData.value;
            if (referral == null) return SizedBox();
            
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Referral Code',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              referral.referralCode,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    IconButton(
                      onPressed: controller.copyReferralCode,
                      icon: Icon(
                        MaterialCommunityIcons.content_copy,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.shareReferralCode,
                      icon: Icon(
                        MaterialCommunityIcons.share,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildReferralStat(
                        'Total Referrals',
                        referral.totalReferrals.toString(),
                        MaterialCommunityIcons.account_multiple,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildReferralStat(
                        'Total Earnings',
                        '${referral.totalEarnings.toStringAsFixed(0)} USDT',
                        MaterialCommunityIcons.currency_usd,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReferralStat(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Color(0xFF2196F3),
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rewards History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.rewards.length,
          itemBuilder: (context, index) {
            final reward = controller.rewards[index];
            return _buildRewardItem(reward);
          },
        )),
      ],
    );
  }

  Widget _buildRewardItem(RewardModel reward) {
    IconData icon;
    Color iconColor;
    
    switch (reward.type) {
      case 'daily_login':
        icon = MaterialCommunityIcons.calendar_check;
        iconColor = Color(0xFF4CAF50);
        break;
      case 'referral':
        icon = MaterialCommunityIcons.account_multiple_plus;
        iconColor = Color(0xFF2196F3);
        break;
      default:
        icon = MaterialCommunityIcons.gift;
        iconColor = Color(0xFFFF9800);
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  reward.description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${reward.earnedDate.day}/${reward.earnedDate.month}/${reward.earnedDate.year}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${reward.amount.toStringAsFixed(1)} ${reward.currency}',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: reward.claimed 
                      ? Color(0xFF4CAF50).withOpacity(0.2)
                      : Color(0xFFFF9800).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reward.claimed ? 'Claimed' : 'Pending',
                  style: TextStyle(
                    color: reward.claimed ? Color(0xFF4CAF50) : Color(0xFFFF9800),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (!reward.claimed) ...[
            SizedBox(width: 8),
            IconButton(
              onPressed: () => controller.claimReward(reward.id),
              icon: Icon(
                MaterialCommunityIcons.download,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}