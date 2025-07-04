import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class MenuController extends GetxController {
  void logout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/login');
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  void showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature will be available soon!',
      backgroundColor: Color(0xFF2A2A2A),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
    );
  }
}

class MenuScreen extends StatelessWidget {
  final MenuController controller = Get.put(MenuController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'Menu',
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
          children: [
            // Profile Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF4CAF50),
                    child: Icon(
                      MaterialCommunityIcons.account,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'john.doe@example.com',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.toNamed('/profile'),
                    icon: Icon(
                      MaterialCommunityIcons.chevron_right,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            
            // Menu Items
            _buildMenuSection(
              'Trading',
              [
                _buildMenuItem(
                  icon: MaterialCommunityIcons.trophy,
                  title: 'Rewards',
                  subtitle: 'Daily check-ins and referrals',
                  onTap: () => Get.toNamed('/rewards'),
                ),
                _buildMenuItem(
                  icon: MaterialCommunityIcons.chart_line,
                  title: 'Trading History',
                  subtitle: 'View your trading history',
                  onTap: () => controller.showComingSoon('Trading History'),
                ),
                _buildMenuItem(
                  icon: MaterialCommunityIcons.wallet,
                  title: 'Wallet',
                  subtitle: 'Manage your wallets',
                  onTap: () => Get.toNamed('/wallet'), // Updated this line
                ),
                _buildMenuItem(
                  icon: MaterialCommunityIcons.bank_transfer,
                  title: 'Deposit & Withdraw',
                  subtitle: 'Fund your account',
                  onTap: () => controller.showComingSoon('Deposit & Withdraw'),
                ),
              ],
            ),
            
            _buildMenuSection(
              'Account',
              [
                _buildMenuItem(
                  icon: MaterialCommunityIcons.account_circle,
                  title: 'Profile Settings',
                  subtitle: 'Manage your profile',
                  onTap: () => Get.toNamed('/profile'),
                ),
                _buildMenuItem(
                  icon: MaterialCommunityIcons.security,
                  title: 'Security',
                  subtitle: 'Two-factor authentication',
                  onTap: () => controller.showComingSoon('Security'),
                ),
                _buildMenuItem(
                  icon: MaterialCommunityIcons.bell,
                  title: 'Notifications',
                  subtitle: 'Manage notifications',
                  onTap: () => Get.toNamed('/notifications'),
                ),
              ],
            ),
            
            _buildMenuSection(
              'Support',
              [
                _buildMenuItem(
                  icon: MaterialCommunityIcons.help_circle,
                  title: 'Help Center',
                  subtitle: 'Get help and support',
                  onTap: () => controller.showComingSoon('Help Center'),
                ),
                _buildMenuItem(
                  icon: MaterialCommunityIcons.file_document,
                  title: 'Terms & Conditions',
                  subtitle: 'Read our terms',
                  onTap: () => controller.showComingSoon('Terms & Conditions'),
                ),
                _buildMenuItem(
                  icon: MaterialCommunityIcons.shield_check,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () => controller.showComingSoon('Privacy Policy'),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Logout Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MaterialCommunityIcons.logout,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // App Version
            Text(
              'RDX Exchange v1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items,
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                MaterialCommunityIcons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}