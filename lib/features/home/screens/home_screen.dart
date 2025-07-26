import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/market_service.dart';
import '../../wallet/controllers/wallet_controller.dart';

class HomeTabController extends GetxController {
  final UserService userService = Get.find<UserService>();
  final MarketService marketService = Get.find<MarketService>();
  final WalletController walletController = Get.find<WalletController>();
  
  String get userName => userService.currentUser.value?.firstName ?? 'User';
  
  String getGreeting() {
    return userService.userGreeting;
  }
  
  Widget _buildBalanceContainer(String currency, Color primaryColor, Color secondaryColor) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.8),
            primaryColor.withOpacity(0.6),
            primaryColor.withOpacity(0.4),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Text(
                  _getBalanceText(currency),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                )),
                SizedBox(height: 8),
                Text(
                  '$currency Balance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getBalanceText(String currency) {
    switch (currency) {
      case 'NGN':
        return '₦${walletController.ngnBalance.toStringAsFixed(2)}';
      case 'USDT':
        return '\$${walletController.usdtBalance.toStringAsFixed(2)}';
      case 'BTC':
        return '${walletController.btcBalance.toStringAsFixed(8)} BTC';
      case 'PI':
        return '${walletController.piBalance.toStringAsFixed(2)} PI';
      default:
        return '₦0.00';
    }
  }
  
  Widget _buildBalanceSection() {
    return Container(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildBalanceContainer('NGN', Colors.green, Colors.green),
          _buildBalanceContainer('USDT', Colors.blue, Colors.blue),
          _buildBalanceContainer('BTC', Colors.orange, Colors.orange),
          _buildBalanceContainer('PI', Colors.purple, Colors.purple),
        ],
      ),
    );
  }
  
  Widget _buildPiCoinPromotion() {
    return Obx(() {
      final piPrice = marketService.getNgnPrice('PI');
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BUY PI COIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    piPrice > 0 ? 'AT ₦${piPrice.toStringAsFixed(3)}' : 'Price Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_upward,
              color: Colors.green,
              size: 30,
            ),
          ],
        ),
      );
    });
  }
  
  List<Map<String, dynamic>> get availableFeatures {
    final features = <Map<String, dynamic>>[];
    
    // Base features for all users
    features.add({
      'title': 'Portfolio',
      'icon': Icons.pie_chart,
      'route': '/portfolio',
      'permission': 'view_wallet'
    });
    
    // Trading features based on status and verification
    if (userService.hasPermission('trade')) {
      features.add({
        'title': 'Trade',
        'icon': Icons.trending_up,
        'route': '/trade',
        'permission': 'trade'
      });
    }
    
    // Premium features
    if (userService.hasFeature('advanced_charts')) {
      features.add({
        'title': 'Advanced Charts',
        'icon': Icons.analytics,
        'route': '/advanced-charts',
        'permission': 'advanced_trading'
      });
    }
    
    // Admin features
    if (userService.hasFeature('admin_dashboard')) {
      features.add({
        'title': 'Admin Panel',
        'icon': Icons.admin_panel_settings,
        'route': '/admin',
        'permission': 'access_admin_panel'
      });
    }
    
    return features;
  }
  
  Widget buildStatusBanner() {
    final user = userService.currentUser.value;
    if (user == null) return SizedBox.shrink();
    
    switch (user.status) {
      case 'pending':
        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            border: Border.all(color: Colors.orange),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Complete your verification to unlock all features',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/kyc'),
                child: Text('Verify Now'),
              ),
            ],
          ),
        );
      case 'suspended':
        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your account is suspended. Contact support for assistance.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/support'),
                child: Text('Contact Support'),
              ),
            ],
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }
}

class HomeTabScreen extends StatelessWidget {
  final HomeTabController controller = Get.put(HomeTabController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: Column(
        children: [
          // Green Scaffold Header with Greeting, Notification and Profile - Enhanced with Rich Texture
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withOpacity(0.9),
                  Colors.green.shade600.withOpacity(0.8),
                  Colors.green.shade800.withOpacity(0.7),
                  Colors.green.shade900.withOpacity(0.6),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Background pattern overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 2.0,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Additional subtle overlay for depth
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Content
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Top Bar with greeting and icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Greeting Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.getGreeting(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Welcome back to RDX Exchange',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.2),
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Icons Row
                            Row(
                              children: [
                                // Notification icon
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Get.toNamed('/notifications');
                                    },
                                    icon: Icon(
                                      MaterialCommunityIcons.bell_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                // Profile icon
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Get.toNamed('/profile');
                                    },
                                    icon: Icon(
                                      MaterialCommunityIcons.account_circle_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Total Balance Section - Now Scrollable with Rich Texture
                        controller._buildBalanceSection(),
              ]),
                                  )
                                  )
                                  ],
                              ),
                            ),
                          // Main Content
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Live Prices Header with Refresh
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Live Market Prices',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Obx(() => Row(
                                          children: [
                                            if (controller.marketService.lastUpdated.value != null)
                                              Text(
                                                'Updated ${_getTimeAgo(controller.marketService.lastUpdated.value!)}',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () => controller.marketService.fetchPrices(),
                                              child: Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: controller.marketService.isLoading.value
                                                    ? SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor: AlwaysStoppedAnimation(Colors.green),
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons.refresh,
                                                        color: Colors.green,
                                                        size: 16,
                                                      ),
                                              ),
                                            ),
                                          ],
                                        )),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    
                                    // Error message if any
                                    Obx(() {
                                      if (controller.marketService.errorMessage.value.isNotEmpty) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 16),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            border: Border.all(color: Colors.red),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.error, color: Colors.red, size: 16),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  controller.marketService.errorMessage.value,
                                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return SizedBox.shrink();
                                    }),
                                    
                                    // Crypto Prices with Real Data
                                    Obx(() {
                                      final symbols = ['BTC', 'USDT', 'PI'];
                                      return Column(
                                        children: symbols.map((symbol) {
                                          final priceData = controller.marketService.getPrice(symbol);
                                          return Column(
                                            children: [
                                              _buildCryptoPriceWithRealData(symbol, priceData),
                                              SizedBox(height: 12),
                                            ],
                                          );
                                        }).toList(),
                                      );
                                    }),
                                    SizedBox(height: 30),
                                    
                                    // Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildActionButton(
                                            FontAwesomeIcons.arrowUp,
                                            'Buy',
                                            Colors.green,
                                            () => Get.toNamed('/buy'),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: _buildActionButton(
                                            FontAwesomeIcons.arrowDown,
                                            'Sell',
                                            Colors.red,
                                            () => Get.toNamed('/sell'),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: _buildActionButton(
                                            FontAwesomeIcons.wallet,
                                            'Fund',
                                            Colors.blue,
                                            () => Get.toNamed('/wallet'), // Updated this line
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: _buildActionButton(
                                            FontAwesomeIcons.gift,
                                            'Rewards',
                                            Color(0xFFFF9800),
                                            () => Get.toNamed('/rewards'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30),
                                    
                                    // PI Coin Promotion Banner
                                    controller._buildPiCoinPromotion(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
          
          // Main Content
  }
  
  Widget _buildCryptoPriceWithRealData(String symbol, CryptoPriceData? priceData) {
    final isLoading = controller.marketService.isLoading.value;
    final hasData = priceData != null;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A2A).withOpacity(0.9),
            Color(0xFF1E1E1E).withOpacity(0.8),
            Color(0xFF0F0F0F).withOpacity(0.7),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 6),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Crypto Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: Text(
                symbol == 'BTC' ? '₿' : 
                symbol == 'USDT' ? '₮' : 'π',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          
          // Symbol and Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasData)
                  Text(
                    priceData.name,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          
          // Price and Change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.green),
                  ),
                )
              else if (hasData) ...[
                Text(
                  priceData.formattedNgnPrice,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  priceData.formattedUsdPrice,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                if (priceData.change24h != 0)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (priceData.isPositiveChange ? Colors.green : Colors.red).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: (priceData.isPositiveChange ? Colors.green : Colors.red).withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      priceData.formattedChange,
                      style: TextStyle(
                        color: priceData.isPositiveChange ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ] else ...[
                Text(
                  'No data',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.7),
              color.withOpacity(0.5),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 6),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Background pattern overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.5,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Additional subtle overlay for depth
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Keep the old HomeScreen class for backward compatibility if needed
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainNavigationScreen();
  }
}

// Import the MainNavigationScreen
class MainNavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This will be imported from the main navigation file
    return Container(); // Placeholder
  }
}
