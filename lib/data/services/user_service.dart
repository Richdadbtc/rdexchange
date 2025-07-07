import 'package:get/get.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();
  
  // Observable user data
  var currentUser = Rxn<User>();
  var userPermissions = <String>[].obs;
  var userFeatures = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }
  
  // Add this init method for async initialization
  Future<UserService> init() async {
    await loadUserData();
    return this;
  }
  
  Future<void> loadUserData() async {
    final user = await AuthService.getCachedUser();
    if (user != null) {
      currentUser.value = user;
      _updateUserPermissions(user);
      _updateUserFeatures(user);
    }
  }
  
  void _updateUserPermissions(User user) {
    userPermissions.clear();
    
    // Base permissions for all users
    userPermissions.addAll(['view_profile', 'update_profile']);
    
    // Role-based permissions
    switch (user.role) {
      case 'admin':
        userPermissions.addAll([
          'admin_dashboard', 'user_management', 'system_settings',
          'advanced_trading', 'priority_support', 'all_features'
        ]);
        break;
      case 'user':
      default:
        userPermissions.addAll(['basic_trading', 'standard_support']);
        break;
    }
    
    // Status-based permissions
    switch (user.status) {
      case 'active':
        userPermissions.addAll(['trade', 'withdraw', 'deposit']);
        break;
      case 'pending':
        userPermissions.addAll(['view_only', 'complete_verification']);
        break;
      case 'suspended':
        userPermissions.clear();
        userPermissions.addAll(['view_profile', 'contact_support']);
        break;
    }
    
    // Verification-based permissions
    if (user.isEmailVerified) {
      userPermissions.add('email_verified_features');
    }
    if (user.isPhoneVerified) {
      userPermissions.add('phone_verified_features');
    }
  }
  
  void _updateUserFeatures(User user) {
    userFeatures.clear();
    
    // Role-based features
    if (user.role == 'admin') {
      userFeatures.addAll([
        'admin_dashboard', 'user_management', 'system_analytics',
        'advanced_charts', 'api_access'
      ]);
    }
    
    // Status and verification-based features
    if (user.status == 'active' && user.isEmailVerified && user.isPhoneVerified) {
      userFeatures.addAll(['full_trading', 'higher_limits']);
    }
  }
  
  bool hasPermission(String permission) {
    return userPermissions.contains(permission);
  }
  
  bool hasFeature(String feature) {
    return userFeatures.contains(feature);
  }
  
  String get userDisplayName {
    return currentUser.value?.fullName ?? 'User';
  }
  
  String get userGreeting {
    final hour = DateTime.now().hour;
    final name = currentUser.value?.firstName ?? 'User';
    
    if (hour < 12) {
      return 'Good Morning, $name';
    } else if (hour < 17) {
      return 'Good Afternoon, $name';
    } else {
      return 'Good Evening, $name';
    }
  }
}