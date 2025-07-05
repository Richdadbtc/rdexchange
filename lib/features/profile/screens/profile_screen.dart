import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileController extends GetxController {
  // Observable user data
  var userName = 'Chris Johnson'.obs;
  var userEmail = 'chris.johnson@email.com'.obs;
  var userPhone = '+234 801 234 5678'.obs;
  var userAvatar = ''.obs;
  var selectedImagePath = ''.obs;
  
  // Account verification status
  var isEmailVerified = true.obs;
  var isPhoneVerified = false.obs;
  var isKycVerified = false.obs;
  
  // Edit mode
  var isEditMode = false.obs;
  var isLoading = false.obs;
  
  // Text controllers for editing
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    // Initialize controllers with current values
    nameController.text = userName.value;
    emailController.text = userEmail.value;
    phoneController.text = userPhone.value;
  }
  
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
  
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) {
      // Reset controllers if canceling edit
      nameController.text = userName.value;
      emailController.text = userEmail.value;
      phoneController.text = userPhone.value;
    }
  }
  
  Future<void> saveProfile() async {
    isLoading.value = true;
    
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));
    
    // Update user data
    userName.value = nameController.text;
    userEmail.value = emailController.text;
    userPhone.value = phoneController.text;
    
    isEditMode.value = false;
    isLoading.value = false;
    
    Get.snackbar(
      'Success',
      'Profile updated successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
  
  Future<void> changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    
    // Show options dialog
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Profile Picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  'Camera',
                  Icons.camera_alt,
                  () async {
                    Get.back();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 512,
                      maxHeight: 512,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      selectedImagePath.value = image.path;
                    }
                  },
                ),
                _buildImageOption(
                  'Gallery',
                  Icons.photo_library,
                  () async {
                    Get.back();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 512,
                      maxHeight: 512,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      selectedImagePath.value = image.path;
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageOption(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 30),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
  
  void logout() {
    Get.offAllNamed('/login');
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
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with gradient
          Obx(() => SliverAppBar(
            expandedHeight: controller.isEditMode.value ? 380.0 : 280.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade600,
                      Colors.green.shade400,
                      Colors.teal.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: _buildProfileHeader(),
              ),
            ),
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            actions: [
              Obx(() => IconButton(
                onPressed: controller.isEditMode.value 
                    ? controller.toggleEditMode 
                    : controller.toggleEditMode,
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.isEditMode.value ? Icons.close : Icons.edit,
                    color: Colors.white,
                  ),
                ),
              )),
            ],
          )),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildAccountStatusSection(),
                  SizedBox(height: 30),
                  _buildAccountSettingsSection(),
                  SizedBox(height: 30),
                  _buildLogoutButton(),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Obx(() => Padding(
      padding: EdgeInsets.only(top: 60, bottom: 16), // Further reduced padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use minimum space needed
        children: [
          // Enhanced Profile Avatar with edit capability
          Stack(
            children: [
              Container(
                width: 100, // Slightly reduced size
                height: 100, // Slightly reduced size
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                  ),
                  border: Border.all(color: Colors.white, width: 3), // Reduced border
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12, // Slightly reduced
                      offset: Offset(0, 6), // Slightly reduced
                    ),
                  ],
                ),
                child: ClipOval(
                  child: controller.selectedImagePath.value.isNotEmpty
                      ? Image.file(
                          File(controller.selectedImagePath.value),
                          fit: BoxFit.cover,
                        )
                      : controller.userAvatar.value.isNotEmpty
                          ? Image.network(
                              controller.userAvatar.value,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green.shade300, Colors.teal.shade300],
                                ),
                              ),
                              child: Icon(
                                MaterialCommunityIcons.account,
                                size: 50, // Reduced icon size
                                color: Colors.white,
                              ),
                            ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: controller.changeProfilePicture,
                  child: Container(
                    width: 32, // Slightly smaller
                    height: 32, // Slightly smaller
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6, // Reduced
                          offset: Offset(0, 3), // Reduced
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16, // Reduced icon size
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16), // Reduced spacing
          
          // Editable user information
          if (controller.isEditMode.value) ...[
            _buildEditableField('Name', controller.nameController),
            SizedBox(height: 6), // Further reduced spacing
            _buildEditableField('Email', controller.emailController),
            SizedBox(height: 6), // Further reduced spacing
            _buildEditableField('Phone', controller.phoneController),
            SizedBox(height: 12), // Further reduced spacing
            _buildSaveButton(),
          ] else ...[
            // Display mode
            Text(
              controller.userName.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24, // Slightly reduced
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6), // Reduced spacing
            Text(
              controller.userEmail.value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15, // Slightly reduced
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3), // Reduced spacing
            Text(
              controller.userPhone.value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13, // Slightly reduced
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ));
  }
  
  Widget _buildEditableField(String label, TextEditingController textController) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: textController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSaveButton() {
    return Obx(() => Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 8,
        ),
        child: controller.isLoading.value
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              )
            : Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    ));
  }
  
  Widget _buildAccountStatusSection() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        
        _buildEnhancedStatusCard(
          'Email Verification',
          controller.isEmailVerified.value ? 'Verified' : 'Not Verified',
          controller.isEmailVerified.value ? Colors.green : Colors.orange,
          MaterialCommunityIcons.email_check,
        ),
        SizedBox(height: 12),
        _buildEnhancedStatusCard(
          'Phone Verification',
          controller.isPhoneVerified.value ? 'Verified' : 'Not Verified',
          controller.isPhoneVerified.value ? Colors.green : Colors.orange,
          MaterialCommunityIcons.phone_check,
        ),
        SizedBox(height: 12),
        _buildEnhancedStatusCard(
          'KYC Verification',
          controller.isKycVerified.value ? 'Verified' : 'Pending',
          controller.isKycVerified.value ? Colors.green : Colors.red,
          MaterialCommunityIcons.account_check,
        ),
      ],
    ));
  }
  
  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        
        _buildEnhancedProfileOption(
          'Change Password',
          'Update your account password',
          MaterialCommunityIcons.lock_reset,
          controller.changePassword,
        ),
        _buildEnhancedProfileOption(
          'Two-Factor Authentication',
          'Secure your account with 2FA',
          MaterialCommunityIcons.shield_check,
          controller.enableTwoFactor,
        ),
        _buildEnhancedProfileOption(
          'Contact Support',
          'Get help from our support team',
          MaterialCommunityIcons.help_circle,
          controller.contactSupport,
        ),
      ],
    );
  }
  
  Widget _buildEnhancedStatusCard(String title, String status, Color statusColor, IconData icon) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A2A),
            Color(0xFF1F1F1F),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withOpacity(0.3), statusColor.withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: 24,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
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
  
  Widget _buildEnhancedProfileOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A2A2A),
              Color(0xFF1F1F1F),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.green,
                size: 24,
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
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
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.green,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Get.dialog(
            AlertDialog(
              backgroundColor: Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
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
    );
  }
}