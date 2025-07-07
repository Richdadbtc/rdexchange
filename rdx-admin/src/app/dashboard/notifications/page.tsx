'use client'
import { useState, useEffect } from 'react'
import {
  BellIcon,
  PlusIcon,
  EyeIcon,
  PencilIcon,
  TrashIcon,
  MegaphoneIcon,
  ExclamationTriangleIcon,
  InformationCircleIcon,
  CheckCircleIcon
} from '@heroicons/react/24/outline'

interface Notification {
  id: string
  title: string
  message: string
  type: 'info' | 'warning' | 'success' | 'announcement'
  status: 'draft' | 'sent' | 'scheduled'
  recipients: 'all' | 'verified' | 'premium' | 'custom'
  scheduledAt?: string
  sentAt?: string
  createdAt: string
  readCount: number
  totalRecipients: number
}

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [newNotification, setNewNotification] = useState({
    title: '',
    message: '',
    type: 'info' as const,
    recipients: 'all' as const,
    scheduledAt: ''
  })

  useEffect(() => {
    fetchNotifications()
  }, [])

  const fetchNotifications = async () => {
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch('http://localhost:3001/api/admin/notifications', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        setNotifications(data)
      } else {
        // Fallback data
        setNotifications([
          {
            id: '1',
            title: 'System Maintenance Scheduled',
            message: 'We will be performing scheduled maintenance on January 20th from 2:00 AM to 4:00 AM UTC.',
            type: 'warning',
            status: 'sent',
            recipients: 'all',
            sentAt: '2024-01-15T10:00:00Z',
            createdAt: '2024-01-15T09:30:00Z',
            readCount: 1250,
            totalRecipients: 2180
          },
          {
            id: '2',
            title: 'New Trading Pair Added',
            message: 'We are excited to announce the addition of ADA/USDT trading pair.',
            type: 'announcement',
            status: 'sent',
            recipients: 'verified',
            sentAt: '2024-01-14T15:30:00Z',
            createdAt: '2024-01-14T15:00:00Z',
            readCount: 890,
            totalRecipients: 1650
          },
          {
            id: '3',
            title: 'Security Update',
            message: 'Please update your password and enable 2FA for enhanced security.',
            type: 'info',
            status: 'draft',
            recipients: 'all',
            createdAt: '2024-01-15T11:00:00Z',
            readCount: 0,
            totalRecipients: 0
          }
        ])
      }
    } catch (error) {
      console.error('Error fetching notifications:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleCreateNotification = async () => {
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch('http://localhost:3001/api/admin/notifications', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(newNotification)
      })
      
      if (response.ok) {
        setShowCreateModal(false)
        setNewNotification({
          title: '',
          message: '',
          type: 'info',
          recipients: 'all',
          scheduledAt: ''
        })
        fetchNotifications()
      }
    } catch (error) {
      console.error('Error creating notification:', error)
    }
  }



  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'warning':
        return ExclamationTriangleIcon
      case 'success':
        return CheckCircleIcon
      case 'announcement':
        return MegaphoneIcon
      default:
        return InformationCircleIcon
    }
  }

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'warning':
        return 'text-yellow-400 bg-yellow-400/10'
      case 'success':
        return 'text-green-400 bg-green-400/10'
      case 'announcement':
        return 'text-blue-400 bg-blue-400/10'
      default:
        return 'text-gray-400 bg-gray-400/10'
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'sent':
        return 'text-green-400 bg-green-400/10'
      case 'scheduled':
        return 'text-blue-400 bg-blue-400/10'
      default:
        return 'text-gray-400 bg-gray-400/10'
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-green-500"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-white">Notification Management</h1>
          <p className="mt-2 text-sm text-gray-400">
            Create and manage platform notifications
          </p>
        </div>
        <button
          onClick={() => setShowCreateModal(true)}
          className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
        >
          <PlusIcon className="h-4 w-4 mr-2" />
          Create Notification
        </button>
      </div>

      {/* Notifications List */}
      <div className="bg-gray-800 rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-700">
            <thead className="bg-gray-700">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Notification
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Recipients
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Read Rate
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-gray-800 divide-y divide-gray-700">
              {notifications.map((notification) => {
                const TypeIcon = getTypeIcon(notification.type)
                return (
                  <tr key={notification.id} className="hover:bg-gray-700">
                    <td className="px-6 py-4">
                      <div className="flex items-start space-x-3">
                        <TypeIcon className="h-5 w-5 text-gray-400 mt-0.5" />
                        <div>
                          <div className="text-sm font-medium text-white">{notification.title}</div>
                          <div className="text-sm text-gray-400 truncate max-w-xs">
                            {notification.message}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getTypeColor(notification.type)}`}>
                        {notification.type}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(notification.status)}`}>
                        {notification.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                      {notification.recipients}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                      {notification.status === 'sent' ? (
                        `${notification.readCount}/${notification.totalRecipients} (${Math.round((notification.readCount / notification.totalRecipients) * 100)}%)`
                      ) : (
                        '-'
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                      {notification.sentAt ? new Date(notification.sentAt).toLocaleDateString() : new Date(notification.createdAt).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex space-x-2">
                        <button className="text-blue-400 hover:text-blue-300">
                          <EyeIcon className="h-4 w-4" />
                        </button>
                        <button className="text-green-400 hover:text-green-300">
                          <PencilIcon className="h-4 w-4" />
                        </button>
                        <button className="text-red-400 hover:text-red-300">
                          <TrashIcon className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Create Notification Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-gray-800 rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-medium text-white mb-4">Create New Notification</h3>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">Title</label>
                <input
                  type="text"
                  value={newNotification.title}
                  onChange={(e) => setNewNotification({ ...newNotification, title: e.target.value })}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">Message</label>
                <textarea
                  value={newNotification.message}
                  onChange={(e) => setNewNotification({ ...newNotification, message: e.target.value })}
                  rows={3}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">Type</label>
                  <select
                    value={newNotification.type}
                    onChange={(e) => setNewNotification({ ...newNotification, type: e.target.value as any })}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                  >
                    <option value="info">Info</option>
                    <option value="warning">Warning</option>
                    <option value="success">Success</option>
                    <option value="announcement">Announcement</option>
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">Recipients</label>
                  <select
                    value={newNotification.recipients}
                    onChange={(e) => setNewNotification({ ...newNotification, recipients: e.target.value as any })}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                  >
                    <option value="all">All Users</option>
                    <option value="verified">Verified Users</option>
                    <option value="premium">Premium Users</option>
                    <option value="custom">Custom</option>
                  </select>
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">Schedule (Optional)</label>
                <input
                  type="datetime-local"
                  value={newNotification.scheduledAt}
                  onChange={(e) => setNewNotification({ ...newNotification, scheduledAt: e.target.value })}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            </div>
            
            <div className="flex justify-end space-x-3 mt-6">
              <button
                onClick={() => setShowCreateModal(false)}
                className="px-4 py-2 text-sm font-medium text-gray-300 bg-gray-600 rounded-md hover:bg-gray-500"
              >
                Cancel
              </button>
              <button
                onClick={handleCreateNotification}
                className="px-4 py-2 text-sm font-medium text-white bg-green-600 rounded-md hover:bg-green-700"
              >
                Create
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}