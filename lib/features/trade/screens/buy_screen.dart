import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BuyController extends GetxController {
  var selectedCoin = 'BTC'.obs;
  var amountController = TextEditingController();
  var selectedPaymentMethod = 'Bank'.obs;
  var isNairaInput = true.obs;
  var currentRate = 0.0.obs;
  var totalAmount = 0.0.obs;
  var coinAmount = 0.0.obs;
  
  final Map<String, double> coinRates = {
    'BTC': 800.0,
    'USDT': 1115.0,
    'PI': 2.8,
  };
  
  final List<String> availableCoins = ['BTC', 'USDT', 'PI'];
  final List<String> paymentMethods = ['Bank', 'Wallet'];
  
  @override
  void onInit() {
    super.onInit();
    updateRate();
    amountController.addListener(calculateAmount);
  }
  
  void updateRate() {
    currentRate.value = coinRates[selectedCoin.value] ?? 0.0;
    calculateAmount();
  }
  
  void calculateAmount() {
    if (amountController.text.isEmpty) {
      totalAmount.value = 0.0;
      coinAmount.value = 0.0;
      return;
    }
    
    double inputAmount = double.tryParse(amountController.text) ?? 0.0;
    
    if (isNairaInput.value) {
      // Input is in Naira, calculate coin amount
      totalAmount.value = inputAmount;
      coinAmount.value = inputAmount / currentRate.value;
    } else {
      // Input is in coin, calculate Naira amount
      coinAmount.value = inputAmount;
      totalAmount.value = inputAmount * currentRate.value;
    }
  }
  
  void toggleInputType() {
    isNairaInput.value = !isNairaInput.value;
    amountController.clear();
    calculateAmount();
  }
  
  void selectCoin(String coin) {
    selectedCoin.value = coin;
    updateRate();
  }
  
  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }
  
  String getCryptoImagePath(String symbol) {
    switch (symbol.toLowerCase()) {
      case 'btc':
        return 'assets/images/btc.png';
      case 'usdt':
        return 'assets/images/usdt.png';
      case 'pi':
        return 'assets/images/pi.png';
      default:
        return 'assets/images/default_crypto.png';
    }
  }
  
  void confirmPurchase() {
    if (amountController.text.isEmpty || totalAmount.value <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text(
          'Confirm Purchase',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coin: ${selectedCoin.value}',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Amount: ${coinAmount.value.toStringAsFixed(6)} ${selectedCoin.value}',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Total: ₦${totalAmount.value.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Payment: ${selectedPaymentMethod.value}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              processPurchase();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
  
  void processPurchase() {
    // Simulate purchase processing
    Get.snackbar(
      'Success',
      'Purchase order created successfully!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    // Navigate back to home
    Get.back();
  }
  
  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}

class BuyScreen extends StatelessWidget {
  final BuyController controller = Get.put(BuyController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Buy Cryptocurrency',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin Selection Section
            Text(
              'Select Cryptocurrency',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.availableCoins.length,
                itemBuilder: (context, index) {
                  String coin = controller.availableCoins[index];
                  
                  return Obx(() {
                    bool isSelected = controller.selectedCoin.value == coin;
                    
                    return GestureDetector(
                      onTap: () => controller.selectCoin(coin),
                      child: Container(
                        width: 100,
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected 
                                  ? Border.all(color: Colors.green, width: 2)
                                  : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  controller.getCryptoImagePath(coin),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: coin == 'BTC' ? Colors.orange : 
                                               coin == 'USDT' ? Colors.green : Colors.purple,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          coin == 'BTC' ? '₿' : 
                                          coin == 'USDT' ? '₮' : 'π',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              coin,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            
            SizedBox(height: 30),
            
            // Current Rate Display
            Obx(() => Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Rate',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1 ${controller.selectedCoin.value} = ₦${controller.currentRate.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
            
            SizedBox(height: 30),
            
            // Amount Input Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enter Amount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => GestureDetector(
                  onTap: controller.toggleInputType,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.isNairaInput.value ? '₦ NGN' : controller.selectedCoin.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )),
              ],
            ),
            SizedBox(height: 16),
            
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Obx(() => TextField(
                    controller: controller.amountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: controller.isNairaInput.value 
                          ? 'Enter amount in Naira' 
                          : 'Enter amount in ${controller.selectedCoin.value}',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixText: controller.isNairaInput.value ? '₦ ' : '',
                      prefixStyle: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )),
                  SizedBox(height: 16),
                  Divider(color: Colors.grey),
                  SizedBox(height: 16),
                  
                  // Conversion Display
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You will get',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '${controller.coinAmount.value.toStringAsFixed(6)} ${controller.selectedCoin.value}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total cost',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '₦${controller.totalAmount.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Payment Method Selection
            Text(
              'Payment Method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            Obx(() => Column(
              children: controller.paymentMethods.map((method) {
                bool isSelected = controller.selectedPaymentMethod.value == method;
                return GestureDetector(
                  onTap: () => controller.selectPaymentMethod(method),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green.withOpacity(0.2) : Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected 
                          ? Border.all(color: Colors.green, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          method == 'Bank' ? FontAwesomeIcons.university : FontAwesomeIcons.wallet,
                          color: isSelected ? Colors.green : Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 16),
                        Text(
                          method == 'Bank' ? 'Bank Transfer' : 'Wallet Balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
            
            SizedBox(height: 40),
            
            // Confirm Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.confirmPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Confirm Purchase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}