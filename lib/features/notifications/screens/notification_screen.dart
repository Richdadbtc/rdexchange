import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../data/services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  final NotificationService notificationService = Get.find<NotificationService>();

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
          Obx(() => notificationService.unreadCount.value > 0
              ? TextButton(
                  onPressed: notificationService.markAllAsRead,
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
        if (notificationService.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        if (notificationService.notifications.isEmpty) {
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

        return RefreshIndicator(
          onRefresh: notificationService.loadNotifications,
          color: Colors.green,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notificationService.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationService.notifications[index];
              return _buildNotificationItem(notification);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.read ? Color(0xFF2A2A2A) : Color(0xFF2A2A2A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: notification.read ? null : Border.all(color: Colors.green.withOpacity(0.3)),
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
                  fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!notification.read)
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
              notification.timeAgo,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          if (!notification.read) {
            notificationService.markAsRead(notification.id);
          }
        },
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[400]),
          color: Color(0xFF2A2A2A),
          itemBuilder: (context) => [
            if (!notification.read)
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
              notificationService.markAsRead(notification.id);
            } else if (value == 'delete') {
              notificationService.deleteNotification(notification.id);
            }
          },
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'reward':
        return Colors.amber;
      case 'price_alert':
        return Colors.orange;
      case 'account':
        return Colors.green;
      case 'feature':
        return Colors.purple;
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'reward':
        return MaterialCommunityIcons.gift;
      case 'price_alert':
        return MaterialCommunityIcons.chart_line;
      case 'account':
        return MaterialCommunityIcons.account_check;
      case 'feature':
        return MaterialCommunityIcons.star;
      case 'success':
        return MaterialCommunityIcons.check_circle;
      case 'warning':
        return MaterialCommunityIcons.alert;
      case 'error':
        return MaterialCommunityIcons.alert_circle;
      default:
        return MaterialCommunityIcons.bell;
    }
  }
}