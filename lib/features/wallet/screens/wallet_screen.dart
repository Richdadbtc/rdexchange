import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../controllers/wallet_controller.dart';

class WalletScreen extends StatelessWidget {
  final WalletController controller = Get.put(WalletController());
  
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
          'Wallet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
            icon: controller.isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.refreshBalance,
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Type Selector
            _buildWalletTypeSelector(),
            SizedBox(height: 20),
            
            // Balance Card
            _buildBalanceCard(),
            SizedBox(height: 20),
            
            // Wallet Address (for crypto wallets)
            Obx(() => controller.selectedWalletType.value != 'NGN'
                ? _buildWalletAddressCard()
                : SizedBox()),
            SizedBox(height: controller.selectedWalletType.value != 'NGN' ? 20 : 0),
            
            // Action Buttons
            _buildActionButtons(),
            SizedBox(height: 30),
            
            // Transaction History
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWalletTypeSelector() {
    final walletTypes = ['NGN', 'BTC', 'USDT', 'PI'];
    
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: walletTypes.length,
        itemBuilder: (context, index) {
          final type = walletTypes[index];
          return Obx(() => GestureDetector(
            onTap: () => controller.changeWalletType(type),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: controller.selectedWalletType.value == type
                    ? Colors.green
                    : Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: controller.selectedWalletType.value == type
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ));
        },
      ),
    );
  }
  
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Obx(() => Text(
            controller.getCurrentBalanceString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          )),
          SizedBox(height: 16),
          Obx(() => Text(
            '${controller.selectedWalletType.value} Wallet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildWalletAddressCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                '${controller.selectedWalletType.value} Wallet Address',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              )),
              IconButton(
                onPressed: controller.copyWalletAddress,
                icon: Icon(
                  MaterialCommunityIcons.content_copy,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            controller.getWalletAddress() ?? '',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: MaterialCommunityIcons.plus,
            title: 'Fund Wallet',
            subtitle: 'Bank/Card',
            color: Colors.blue,
            onTap: controller.fundWallet,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: MaterialCommunityIcons.minus,
            title: 'Withdraw',
            subtitle: 'To Bank',
            color: Colors.orange,
            onTap: controller.withdrawFunds,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
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
    );
  }
  
  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction History',
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
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            final transaction = controller.transactions[index];
            return _buildTransactionItem(transaction);
          },
        )),
      ],
    );
  }
  
  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    IconData icon;
    Color iconColor;
    
    switch (transaction['icon']) {
      case 'fund':
        icon = MaterialCommunityIcons.plus;
        iconColor = Colors.green;
        break;
      case 'buy':
        icon = MaterialCommunityIcons.arrow_up;
        iconColor = Colors.blue;
        break;
      case 'withdraw':
        icon = MaterialCommunityIcons.minus;
        iconColor = Colors.orange;
        break;
      default:
        icon = MaterialCommunityIcons.swap_horizontal;
        iconColor = Colors.grey;
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
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['type'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction['date'],
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction['amount'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: transaction['status'] == 'Completed'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction['status'],
                  style: TextStyle(
                    color: transaction['status'] == 'Completed'
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}