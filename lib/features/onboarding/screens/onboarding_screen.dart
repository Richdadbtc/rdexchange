import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;
  PageController pageController = PageController();

  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: 'Welcome to RD Exchange',
      description: 'Your trusted platform for secure and fast trading',
      icon: Icons.handshake,
    ),
    OnboardingItem(
      title: 'Secure Trading',
      description: 'Trade with confidence using our advanced security features',
      icon: Icons.security,
    ),
    OnboardingItem(
      title: 'Easy to Use',
      description: 'Simple and intuitive interface for all your trading needs',
      icon: Icons.touch_app,
    ),
  ];

  void nextPage() {
    if (currentPage.value < onboardingItems.length - 1) {
      currentPage.value++;
      pageController.animateToPage(
        currentPage.value,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offNamed('/login');
    }
  }

  void skipOnboarding() {
    Get.offNamed('/login');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingScreen extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: controller.skipOnboarding,
                  child: Text('Skip'),
                ),
              ),
            ),
            // Page view
            Expanded(
              flex: 3, // Give more space to the main content
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.currentPage.value = index;
                },
                itemCount: controller.onboardingItems.length,
                itemBuilder: (context, index) {
                  final item = controller.onboardingItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0), // Reduced vertical padding
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 100, // Reduced icon size
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(height: 30), // Reduced spacing
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 24, // Reduced font size
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16), // Reduced spacing
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page indicator and next button
            Padding(
              padding: const EdgeInsets.all(24.0), // Reduced padding
              child: Column(
                mainAxisSize: MainAxisSize.min, // Important: minimize column size
                children: [
                  // Page indicator
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.onboardingItems.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: controller.currentPage.value == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: controller.currentPage.value == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(height: 24), // Reduced spacing
                  // Next/Get Started button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        controller.currentPage.value == controller.onboardingItems.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}