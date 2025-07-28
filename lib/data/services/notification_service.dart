import 'dart:convert';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();
  
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Observable variables
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    initialize();
    loadNotifications();
  }
  
  // Initialize Firebase Messaging and Local Notifications
  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else {
        print('User declined or has not accepted permission');
        return;
      }
      
      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Get FCM token and update on server
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _updateFCMToken(token);
      }
      
      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_updateFCMToken);
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      
      // Handle notification opened app
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }
  
  // Update FCM token on server
  Future<void> _updateFCMToken(String token) async {
    try {
      final response = await ApiService.post('/user/fcm-token', {
        'fcmToken': token,
      });
      
      if (response['success'] == true) {
        print('FCM token updated successfully');
      } else {
        print('Failed to update FCM token: ${response['message']}');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
  
  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Handling a foreground message: ${message.messageId}');
    
    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
    
    // Refresh notifications
    await loadNotifications();
  }
  
  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
  }
  
  // Handle notification opened app
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('Message clicked: ${message.messageId}');
    // Handle navigation based on message data
  }
  
  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'rdx_notifications',
      'RDX Notifications',
      channelDescription: 'Notifications for RDX Exchange',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  
  // Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    print('Notification tapped: ${notificationResponse.payload}');
    // Handle navigation based on payload
  }
  
  // Load notifications from API
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final response = await ApiService.get('/notifications');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> notificationsJson = response['data'];
        notifications.value = notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        
        // Update unread count
        unreadCount.value = notifications.where((n) => !n.read).length;
      } else {
        print('Failed to load notifications: ${response['message']}');
        notifications.clear();
      }
    } catch (e) {
      print('Error loading notifications: $e');
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await ApiService.post('/notifications/$notificationId/read', {});
      
      if (response['success'] == true) {
        // Update local notification
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(read: true);
          unreadCount.value = notifications.where((n) => !n.read).length;
        }
        print('Notification marked as read');
      } else {
        print('Failed to mark notification as read: ${response['message']}');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await ApiService.post('/notifications/mark-all-read', {});
      
      if (response['success'] == true) {
        // Update all local notifications
        for (int i = 0; i < notifications.length; i++) {
          notifications[i] = notifications[i].copyWith(read: true);
        }
        unreadCount.value = 0;
        print('All notifications marked as read');
      } else {
        print('Failed to mark all notifications as read: ${response['message']}');
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
  
  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await ApiService.post('/notifications/$notificationId/delete', {});
      
      if (response['success'] == true) {
        notifications.removeWhere((n) => n.id == notificationId);
        unreadCount.value = notifications.where((n) => !n.read).length;
        print('Notification deleted');
      } else {
        print('Failed to delete notification: ${response['message']}');
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
  
  // Schedule reward claim reminder
  Future<void> scheduleRewardClaimReminder(DateTime scheduledTime) async {
    try {
      await _localNotifications.zonedSchedule(
        1, // notification id
        'Daily Reward Available!',
        'Don\'t forget to claim your daily reward and maintain your streak!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_rewards',
            'Daily Rewards',
            channelDescription: 'Daily reward reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      print('Daily reward reminder scheduled for ${scheduledTime.toString()}');
    } catch (e) {
      print('Error scheduling reward reminder: $e');
    }
  }
  
  // Cancel all scheduled notifications
  Future<void> cancelAllScheduledNotifications() async {
    await _localNotifications.cancelAll();
  }
}

// Notification Model
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      data: json['data'],
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? read,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}