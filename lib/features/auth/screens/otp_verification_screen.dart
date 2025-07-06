import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  
  var otpCode = ''.obs;
  var isLoading = false.obs;
  var resendTimer = 60.obs;
  var canResend = false.obs;
  
  final String email;
  
  OtpVerificationController({required this.email});
  
  @override
  void onInit() {
    super.onInit();
    startResendTimer();
  }
  
  void startResendTimer() {
    canResend.value = false;
    resendTimer.value = 60;
    
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      resendTimer.value--;
      if (resendTimer.value <= 0) {
        canResend.value = true;
        return false;
      }
      return true;
    });
  }
  
  Future<void> verifyOtp() async {
    if (otpCode.value.length != 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP', 
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    isLoading.value = true;
    
    try {
      // Use the OTP code as verification token
      final success = await authController.verifyEmail(otpCode.value);
      
      if (success) {
        Get.offNamed('/account-success');
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> resendOtp() async {
    if (canResend.value) {
      // Trigger password reset to send new OTP
      await authController.resetPassword(email);
      Get.snackbar('Success', 'OTP sent successfully', 
          snackPosition: SnackPosition.BOTTOM);
      startResendTimer();
    }
  }
}

class OtpVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String email = Get.arguments ?? 'user@example.com';
    final OtpVerificationController controller = Get.put(
        OtpVerificationController(email: email));
    
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A), // Dark background
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              // RDX Logo
              Center(
                child: Column(
                  children: [
                    // Replace with your actual logo or use text version
                    Image.asset(
                      'assets/images/rdx_logo.png', // Add your logo file here
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              // OTP Verification Title
              Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'We sent a verification code to',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // OTP Input Field
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 8),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onChanged: (value) => controller.otpCode.value = value,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                ),
              ),
              SizedBox(height: 30),
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'VERIFY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )),
              ),
              SizedBox(height: 30),
              // Resend OTP
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive the code? ',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.canResend.value ? controller.resendOtp : null,
                    child: Text(
                      controller.canResend.value 
                          ? 'Resend'
                          : 'Resend in ${controller.resendTimer.value}s',
                      style: TextStyle(
                        color: controller.canResend.value ? Colors.green : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}