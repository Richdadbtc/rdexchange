import 'package:get/get.dart';
import 'package:rdexchange/features/auth/screens/reset_password_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/account_success_screen.dart';
import '../features/main/screens/main_navigation_screen.dart';
import '../features/notifications/screens/notification_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/rewards/screens/rewards_screen.dart';
import '../features/trade/screens/buy_screen.dart';
import '../features/trade/screens/sell_screen.dart';
import '../features/wallet/screens/wallet_screen.dart';
import '../features/kyc/screens/kyc_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => OnboardingScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterScreen(),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => ResetPasswordScreen(),
    ),
    GetPage(
      name: Routes.OTP_VERIFICATION,
      page: () => OtpVerificationScreen(),
    ),
    GetPage(
      name: Routes.ACCOUNT_SUCCESS,
      page: () => AccountSuccessScreen(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => MainNavigationScreen(),
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => NotificationScreen(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileScreen(),
    ),
    GetPage(
      name: Routes.REWARDS,
      page: () => RewardsScreen(),
    ),
    GetPage(
      name: Routes.BUY,
      page: () => BuyScreen(),
    ),
    GetPage(
      name: Routes.SELL,
      page: () => SellScreen(),
    ),
    GetPage(
      name: Routes.WALLET,
      page: () => WalletScreen(),
    ),
    GetPage(
      name: Routes.KYC,
      page: () => KycScreen(),
    ),
  ];
}