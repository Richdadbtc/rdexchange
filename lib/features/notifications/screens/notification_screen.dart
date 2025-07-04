import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationItem>[
    NotificationItem(
      id: '1',
      title: 'Welcome to RD Exchange',
      message: 'Thank you for joining RD Exchange. Start trading now!',
      time: '2 hours ago',
      isRead: false,
      type: NotificationType.welcome,
    ),
    NotificationItem(
      id: '2',
      title: 'BTC Price Alert',
      message: 'Bitcoin has reached \$800. Consider your trading strategy.',
      time: '5 hours ago',
      isRead: true,
      type: NotificationType.priceAlert,
    ),
    NotificationItem(
      id: '3',
      title: 'Account Verification',
      message: 'Your account has been successfully verified.',
      time: '1 day ago',
      isRead: true,
      type: NotificationType.account,
    ),
    NotificationItem(
      id: '4',
      title: 'New Feature Available',
      message: 'Check out our new PI Coin trading feature.',
      time: '2 days ago',
      isRead: false,
      type: NotificationType.feature,
    ),
  ].obs;

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    notifications.refresh();
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationScreen extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() => controller.unreadCount > 0
              ? TextButton(
                  onPressed: controller.markAllAsRead,
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                )
              : SizedBox()),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  MaterialCommunityIcons.bell_off_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You\'re all caught up!',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationItem(notification);
          },
        );
      }),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Color(0xFF2A2A2A) : Color(0xFF2A2A2A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: notification.isRead ? null : Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              notification.time,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            controller.markAsRead(notification.id);
          }
        },
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[400]),
          color: Color(0xFF2A2A2A),
          itemBuilder: (context) => [
            if (!notification.isRead)
              PopupMenuItem(
                value: 'read',
                child: Text('Mark as read', style: TextStyle(color: Colors.white)),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (value) {
            if (value == 'read') {
              controller.markAsRead(notification.id);
            } else if (value == 'delete') {
              controller.deleteNotification(notification.id);
            }
          },
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.welcome:
        return Colors.blue;
      case NotificationType.priceAlert:
        return Colors.orange;
      case NotificationType.account:
        return Colors.green;
      case NotificationType.feature:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.welcome:
        return MaterialCommunityIcons.hand_wave;
      case NotificationType.priceAlert:
        return MaterialCommunityIcons.chart_line;
      case NotificationType.account:
        return MaterialCommunityIcons.account_check;
      case NotificationType.feature:
        return MaterialCommunityIcons.star;
      default:
        return MaterialCommunityIcons.bell;
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

enum NotificationType {
  welcome,
  priceAlert,
  account,
  feature,
}