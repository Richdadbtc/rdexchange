import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;
  PageController pageController = PageController();

  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: 'Welcome to RDX Exchange',
      description: 'Your trusted platform for secure and fast cryptocurrency trading',
      icon: FontAwesomeIcons.handshake,
      gradient: [Color(0xFF4CAF50), Color(0xFF45A049)],
    ),
    OnboardingItem(
      title: 'Secure Trading',
      description: 'Trade with confidence using our advanced security features and encryption',
      icon: FontAwesomeIcons.shield,
      gradient: [Color(0xFF2196F3), Color(0xFF1976D2)],
    ),
    OnboardingItem(
      title: 'Real-time Analytics',
      description: 'Access live market data, charts, and trading insights at your fingertips',
      icon: FontAwesomeIcons.chartLine,
      gradient: [Color(0xFFFF9800), Color(0xFFF57C00)],
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
  final List<Color> gradient;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

class OnboardingScreen extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF2A2A2A),
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button with enhanced styling
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextButton(
                      onPressed: controller.skipOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Page view with enhanced design
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: (index) {
                    controller.currentPage.value = index;
                  },
                  itemCount: controller.onboardingItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.onboardingItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Enhanced icon with gradient background
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: item.gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: item.gradient[0].withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              item.icon,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 40),
                          // Enhanced title
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          // Enhanced description
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[300],
                                height: 1.5,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Enhanced page indicator and button
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Enhanced page indicator
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onboardingItems.length,
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: controller.currentPage.value == index ? 32 : 12,
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: controller.currentPage.value == index
                                ? LinearGradient(
                                    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                                  )
                                : null,
                            color: controller.currentPage.value == index
                                ? null
                                : Colors.grey[600],
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: controller.currentPage.value == index
                                ? [
                                    BoxShadow(
                                      color: Color(0xFF4CAF50).withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    )),
                    SizedBox(height: 32),
                    // Enhanced button
                    Obx(() => Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: controller.nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          controller.currentPage.value == controller.onboardingItems.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}