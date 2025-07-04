import 'package:get/get.dart';
import '../features/onboarding/screens/onboarding_screen.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}