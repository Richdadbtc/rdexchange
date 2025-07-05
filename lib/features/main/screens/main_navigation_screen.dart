import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../features/home/screens/home_screen.dart';
import 'menu_screen.dart';
import 'whatsapp_screen.dart';

class MainNavigationController extends GetxController {
  var selectedIndex = 0.obs;
  
  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
  
  void logout() {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/login');
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class MainNavigationScreen extends StatelessWidget {
  final MainNavigationController controller = Get.put(MainNavigationController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: Obx(() => _buildBody()),
      bottomNavigationBar: Container(
        color: Color(0xFF1A1A1A),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: MaterialCommunityIcons.home,
              isSelected: controller.selectedIndex.value == 0,
              onTap: () => controller.changeTabIndex(0),
            ),
            _buildNavItem(
              icon: MaterialCommunityIcons.menu,
              isSelected: controller.selectedIndex.value == 1,
              onTap: () => controller.changeTabIndex(1),
            ),
            _buildNavItem(
              icon: MaterialCommunityIcons.whatsapp,
              isSelected: controller.selectedIndex.value == 2,
              onTap: () => controller.changeTabIndex(2),
            ),
          ],
        )),
      ),
    );
  }
  
  Widget _buildBody() {
    switch (controller.selectedIndex.value) {
      case 0:
        return HomeTabScreen();
      case 1:
        return MenuScreen();
      case 2:
        return WhatsAppScreen();
      default:
        return HomeTabScreen();
    }
  }
  
  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color iconColor;
    if (icon == MaterialCommunityIcons.whatsapp) {
      iconColor = Colors.green;
    } else if (isSelected) {
      iconColor = Colors.white;
    } else {
      iconColor = Colors.grey[400]!;
    }
    
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: iconColor,
        size: 28,
      ),
    );
  }
}