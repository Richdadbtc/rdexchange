import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class OtpVerificationController extends GetxController {
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
  
  void verifyOtp() {
    if (otpCode.value.length != 6) {
      Get.snackbar('Error', 'Please enter a valid 6-digit OTP', 
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    isLoading.value = true;
    
    // Simulate API call
    Future.delayed(Duration(seconds: 2), () {
      isLoading.value = false;
      // For demo purposes, accept any 6-digit code
      if (otpCode.value.length == 6) {
        Get.offNamed('/account-success');
      } else {
        Get.snackbar('Error', 'Invalid OTP code', 
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }
  
  void resendOtp() {
    if (canResend.value) {
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
                    // Fallback text version if logo not available
                    // RichText(
                    //   text: TextSpan(
                    //     children: [
                    //       TextSpan(
                    //         text: 'RD',
                    //         style: TextStyle(
                    //           fontSize: 32,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //       TextSpan(
                    //         text: 'X',
                    //         style: TextStyle(
                    //           fontSize: 32,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.purple,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
              // OTP Verification Title
              Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Enter the verification code\nsent to your email',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit code',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    counterText: '',
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  onChanged: (value) => controller.otpCode.value = value,
                ),
              ),
              SizedBox(height: 30),
              // Verify Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                ),
              )),
              SizedBox(height: 40),
              // Resend Code
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive a code? ",
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
                        color: controller.canResend.value 
                            ? Colors.green
                            : Colors.grey,
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