import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rdexchange/data/services/market_service.dart';
import 'package:rdexchange/features/wallet/controllers/wallet_controller.dart';

class SellController extends GetxController {
  final MarketService marketService = Get.find<MarketService>();
  final WalletController walletController = Get.find<WalletController>();
  
  var selectedCoin = 'BTC'.obs;
  var amountController = TextEditingController();
  var selectedPayoutAccount = 'Bank Account'.obs;
  var isCoinInput = true.obs;
  var totalAmount = 0.0.obs;
  var coinAmount = 0.0.obs;

  // Dynamic rate from MarketService
  double get currentRate {
    return marketService.getNgnPrice(selectedCoin.value);
  }

  // Dynamic wallet address from WalletController
  String get walletAddress {
    final addresses = {
      'BTC': '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
      'USDT': '0x742d35Cc6634C0532925a3b8D4C9db96590b4c5d',
      'PI': 'GDQP2KPQGKIHYJGXNUIYOMHARUARCA7DJT5FO2FFOOKY3B2WSQHG4W37',
    };
    return addresses[selectedCoin.value] ?? '';
  }
  
  final List<String> availableCoins = ['BTC', 'USDT', 'PI'];
  final List<String> payoutAccounts = ['Bank Account', 'Mobile Money', 'Wallet'];
  
  @override
  void onInit() {
    super.onInit();
    amountController.addListener(calculateAmount);
    
    // Listen to market data changes
    ever(marketService.cryptoPrices, (_) => calculateAmount());
  }
  
  void calculateAmount() {
    if (amountController.text.isEmpty) {
      totalAmount.value = 0.0;
      coinAmount.value = 0.0;
      return;
    }
    
    double inputAmount = double.tryParse(amountController.text) ?? 0.0;
    
    if (isCoinInput.value) {
      // Input is in coin, calculate Naira amount
      coinAmount.value = inputAmount;
      totalAmount.value = inputAmount * currentRate;
    } else {
      // Input is in Naira, calculate coin amount
      totalAmount.value = inputAmount;
      coinAmount.value = inputAmount / currentRate;
    }
  }
  
  void toggleInputType() {
    isCoinInput.value = !isCoinInput.value;
    amountController.clear();
    calculateAmount();
  }
  
  void selectCoin(String coin) {
    selectedCoin.value = coin;
    calculateAmount();
  }
  
  void selectPayoutAccount(String account) {
    selectedPayoutAccount.value = account;
  }
  
  void copyWalletAddress() {
    Clipboard.setData(ClipboardData(text: walletAddress));
    Get.snackbar(
      'Copied!',
      'Wallet address copied to clipboard',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
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
  
  void confirmSale() {
    if (amountController.text.isEmpty || coinAmount.value <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount to sell',
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
          'Confirm Sale',
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
              'You will receive: ₦${totalAmount.value.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Payout: ${selectedPayoutAccount.value}',
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
              processSale();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Confirm Sale'),
          ),
        ],
      ),
    );
  }
  
  void processSale() {
    // Simulate sale processing
    Get.snackbar(
      'Success',
      'Sale order created successfully!',
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

class SellScreen extends StatelessWidget {
  final SellController controller = Get.put(SellController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Sell Cryptocurrency',
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
              'Select Cryptocurrency to Sell',
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
                          color: isSelected ? Colors.red : Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected 
                              ? Border.all(color: Colors.red, width: 2)
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
            
            // Wallet Address Section
            Text(
              'Send to Wallet Address',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Obx(() => Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.selectedCoin.value} Wallet Address',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.copyWalletAddress,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Copy',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    controller.walletAddress,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )),
            
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
                    'Current Selling Rate',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1 ${controller.selectedCoin.value} = ₦${controller.currentRate.toStringAsFixed(2)}',
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
                  'Enter Amount to Sell',
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
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.isCoinInput.value ? controller.selectedCoin.value : '₦ NGN',
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
                      hintText: controller.isCoinInput.value 
                          ? 'Enter amount in ${controller.selectedCoin.value}' 
                          : 'Enter amount in Naira',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixText: controller.isCoinInput.value ? '' : '₦ ',
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
                            'You will receive',
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
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Selling amount',
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
                    ],
                  )),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Payout Account Section
            Text(
              'Select Payout Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            Obx(() => Column(
              children: controller.payoutAccounts.map((account) {
                bool isSelected = controller.selectedPayoutAccount.value == account;
                IconData accountIcon;
                
                switch (account) {
                  case 'Bank Account':
                    accountIcon = FontAwesomeIcons.university;
                    break;
                  case 'Mobile Money':
                    accountIcon = FontAwesomeIcons.mobileAlt;
                    break;
                  case 'Wallet':
                    accountIcon = FontAwesomeIcons.wallet;
                    break;
                  default:
                    accountIcon = FontAwesomeIcons.creditCard;
                }
                
                return GestureDetector(
                  onTap: () => controller.selectPayoutAccount(account),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red.withOpacity(0.2) : Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected 
                          ? Border.all(color: Colors.red, width: 2)
                          : Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            accountIcon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            account,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Colors.red,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
            
            SizedBox(height: 40),
            
            // Sell Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.confirmSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sell Cryptocurrency',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}