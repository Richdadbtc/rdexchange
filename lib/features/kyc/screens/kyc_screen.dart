import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../controllers/kyc_controller.dart';

class KycScreen extends StatelessWidget {
  final KycController controller = Get.put(KycController());

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
          'KYC Verification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() => controller.isVerified.value 
        ? _buildSuccessView() 
        : _buildVerificationForm()),
    );
  }

  Widget _buildVerificationForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A2A2A),
                  Color(0xFF1F1F1F),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    MaterialCommunityIcons.account_check,
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
                        'Identity Verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Verify your identity to unlock all features',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Verification Type Selection
          Text(
            'Select Verification Method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          
          Obx(() => Row(
            children: controller.verificationTypes.map((type) {
              bool isSelected = controller.selectedVerificationType.value == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectVerificationType(type),
                  child: Container(
                    margin: EdgeInsets.only(right: type == 'NIN' ? 8 : 0),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green.withOpacity(0.2) : Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey[700]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          type == 'NIN' ? MaterialCommunityIcons.card_account_details : MaterialCommunityIcons.bank,
                          color: isSelected ? Colors.green : Colors.grey[400],
                          size: 24,
                        ),
                        SizedBox(height: 8),
                        Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? Colors.green : Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          type == 'NIN' ? 'National ID' : 'Bank Verification',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
          
          SizedBox(height: 30),

          // Form Fields
          Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verification Number
              _buildInputField(
                label: '${controller.selectedVerificationType.value} Number',
                hint: 'Enter your ${controller.selectedVerificationType.value} number',
                icon: controller.selectedVerificationType.value == 'NIN' 
                  ? MaterialCommunityIcons.card_account_details 
                  : MaterialCommunityIcons.bank,
                onChanged: (value) => controller.verificationNumber.value = value,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 11,
              ),
              
              SizedBox(height: 20),
              
              // First Name
              _buildInputField(
                label: 'First Name',
                hint: 'Enter your first name',
                icon: Icons.person_outline,
                onChanged: (value) => controller.firstName.value = value,
              ),
              
              SizedBox(height: 20),
              
              // Last Name
              _buildInputField(
                label: 'Last Name',
                hint: 'Enter your last name',
                icon: Icons.person_outline,
                onChanged: (value) => controller.lastName.value = value,
              ),
              
              SizedBox(height: 20),
              
              // Conditional Fields
              if (controller.selectedVerificationType.value == 'NIN') ...[
                // Date of Birth for NIN
                GestureDetector(
                  onTap: () => controller.selectDate(Get.context!),
                  child: _buildInputField(
                    label: 'Date of Birth',
                    hint: 'Select your date of birth',
                    icon: Icons.calendar_today,
                    value: controller.dateOfBirth.value,
                    enabled: false,
                  ),
                ),
              ] else ...[
                // Phone Number for BVN
                _buildInputField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  icon: Icons.phone_outlined,
                  onChanged: (value) => controller.phoneNumber.value = value,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ],
          )),
          
          SizedBox(height: 40),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.submitVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'SUBMIT VERIFICATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            )),
          ),
          
          SizedBox(height: 20),
          
          // Info Note
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your information is secure and will only be used for verification purposes. Processing may take 1-3 business days.',
                    style: TextStyle(
                      color: Colors.blue[300],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Verification Submitted!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Your KYC verification has been submitted successfully. You will be notified once the verification is complete.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    Function(String)? onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? value,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: TextField(
            enabled: enabled,
            controller: value != null ? TextEditingController(text: value) : null,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(
                icon,
                color: Colors.grey[400],
              ),
              counterText: '',
            ),
            onChanged: onChanged,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
          ),
        ),
      ],
    );
  }
}