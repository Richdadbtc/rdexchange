import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class ProfileController extends GetxController {
  // User data - replace with actual user data from your auth system
  String userName = 'Chris Johnson';
  String userEmail = 'chris.johnson@email.com';
  String userPhone = '+234 801 234 5678';
  String userAvatar = ''; // Add avatar URL if available
  
  // Account verification status
  bool isEmailVerified = true;
  bool isPhoneVerified = false;
  bool isKycVerified = false;
  
  void logout() {
    // Add logout logic here
    Get.offAllNamed('/login');
  }
  
  void editProfile() {
    Get.snackbar('Edit Profile', 'Edit profile feature coming soon');
  }
  
  void changePassword() {
    Get.snackbar('Change Password', 'Change password feature coming soon');
  }
  
  void enableTwoFactor() {
    Get.snackbar('2FA', 'Two-factor authentication feature coming soon');
  }
  
  void contactSupport() {
    Get.snackbar('Support', 'Contact support feature coming soon');
  }
}

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.editProfile,
            icon: Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    // Profile Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: controller.userAvatar.isEmpty
                          ? Icon(
                              MaterialCommunityIcons.account,
                              size: 50,
                              color: Colors.white,
                            )
                          : ClipOval(
                              child: Image.network(
                                controller.userAvatar,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    SizedBox(height: 16),
                    // User Name
                    Text(
                      controller.userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    // User Email
                    Text(
                      controller.userEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Account Status Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Verification Status Cards
                  _buildStatusCard(
                    'Email Verification',
                    controller.isEmailVerified ? 'Verified' : 'Not Verified',
                    controller.isEmailVerified ? Colors.green : Colors.orange,
                    MaterialCommunityIcons.email_check,
                  ),
                  SizedBox(height: 12),
                  _buildStatusCard(
                    'Phone Verification',
                    controller.isPhoneVerified ? 'Verified' : 'Not Verified',
                    controller.isPhoneVerified ? Colors.green : Colors.orange,
                    MaterialCommunityIcons.phone_check,
                  ),
                  SizedBox(height: 12),
                  _buildStatusCard(
                    'KYC Verification',
                    controller.isKycVerified ? 'Verified' : 'Pending',
                    controller.isKycVerified ? Colors.green : Colors.red,
                    MaterialCommunityIcons.account_check,
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Profile Options
                  Text(
                    'Account Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  _buildProfileOption(
                    'Personal Information',
                    'Update your personal details',
                    MaterialCommunityIcons.account_edit,
                    controller.editProfile,
                  ),
                  _buildProfileOption(
                    'Change Password',
                    'Update your account password',
                    MaterialCommunityIcons.lock_reset,
                    controller.changePassword,
                  ),
                  _buildProfileOption(
                    'Two-Factor Authentication',
                    'Secure your account with 2FA',
                    MaterialCommunityIcons.shield_check,
                    controller.enableTwoFactor,
                  ),
                  _buildProfileOption(
                    'Contact Support',
                    'Get help from our support team',
                    MaterialCommunityIcons.help_circle,
                    controller.contactSupport,
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Logout Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: Color(0xFF2A2A2A),
                            title: Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  controller.logout();
                                },
                                child: Text('Logout', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusCard(String title, String status, Color statusColor, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: statusColor,
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
                SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.green,
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
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}