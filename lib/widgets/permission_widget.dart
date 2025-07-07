import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/user_service.dart';

class PermissionWidget extends StatelessWidget {
  final String? permission;
  final String? feature;
  final Widget child;
  final Widget? fallback;
  final bool requireAll;
  
  const PermissionWidget({
    Key? key,
    this.permission,
    this.feature,
    required this.child,
    this.fallback,
    this.requireAll = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userService = Get.find<UserService>();
      
      bool hasAccess = true;
      
      if (permission != null) {
        hasAccess = userService.hasPermission(permission!);
      }
      
      if (feature != null) {
        if (requireAll) {
          hasAccess = hasAccess && userService.hasFeature(feature!);
        } else {
          hasAccess = hasAccess || userService.hasFeature(feature!);
        }
      }
      
      return hasAccess ? child : (fallback ?? SizedBox.shrink());
    });
  }
}