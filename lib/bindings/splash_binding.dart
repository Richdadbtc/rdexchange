import 'package:get/get.dart';
import '../features/splash/screens/splash_screen.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}