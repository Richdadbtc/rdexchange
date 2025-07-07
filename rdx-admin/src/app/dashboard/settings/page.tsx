'use client'
import { useState, useEffect } from 'react'
import {
  CogIcon,
  BellIcon,
  ShieldCheckIcon,
  CurrencyDollarIcon,
  GlobeAltIcon,
  UserGroupIcon,
  KeyIcon,
  DocumentTextIcon
} from '@heroicons/react/24/outline'

interface Settings {
  general: {
    siteName: string
    siteDescription: string
    contactEmail: string
    supportPhone: string
  }
  trading: {
    tradingFee: number
    withdrawalFee: number
    minimumWithdrawal: number
    maximumWithdrawal: number
    dailyWithdrawalLimit: number
  }
  security: {
    twoFactorRequired: boolean
    kycRequired: boolean
    emailVerificationRequired: boolean
    sessionTimeout: number
  }
  notifications: {
    emailNotifications: boolean
    smsNotifications: boolean
    pushNotifications: boolean
    maintenanceAlerts: boolean
  }
}

export default function SettingsPage() {
  const [settings, setSettings] = useState<Settings>({
    general: {
      siteName: 'RDX Exchange',
      siteDescription: 'Professional Cryptocurrency Trading Platform',
      contactEmail: 'support@rdxexchange.com',
      supportPhone: '+1-800-RDX-HELP'
    },
    trading: {
      tradingFee: 0.25,
      withdrawalFee: 0.001,
      minimumWithdrawal: 10,
      maximumWithdrawal: 50000,
      dailyWithdrawalLimit: 100000
    },
    security: {
      twoFactorRequired: true,
      kycRequired: true,
      emailVerificationRequired: true,
      sessionTimeout: 30
    },
    notifications: {
      emailNotifications: true,
      smsNotifications: false,
      pushNotifications: true,
      maintenanceAlerts: true
    }
  })
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState('general')

  const handleSave = async () => {
    setLoading(true)
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch('http://localhost:3001/api/admin/settings', {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(settings)
      })
      
      if (response.ok) {
        alert('Settings saved successfully!')
      }
    } catch (error) {
      console.error('Error saving settings:', error)
      alert('Error saving settings')
    } finally {
      setLoading(false)
    }
  }



  const tabs = [
    { id: 'general', name: 'General', icon: CogIcon },
    { id: 'trading', name: 'Trading', icon: CurrencyDollarIcon },
    { id: 'security', name: 'Security', icon: ShieldCheckIcon },
    { id: 'notifications', name: 'Notifications', icon: BellIcon }
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-white">Settings</h1>
        <p className="mt-2 text-sm text-gray-400">
          Configure platform settings and preferences
        </p>
      </div>

      <div className="bg-gray-800 rounded-lg">
        {/* Tabs */}
        <div className="border-b border-gray-700">
          <nav className="-mb-px flex space-x-8 px-6">
            {tabs.map((tab) => {
              const Icon = tab.icon
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`group inline-flex items-center py-4 px-1 border-b-2 font-medium text-sm ${
                    activeTab === tab.id
                      ? 'border-green-500 text-green-400'
                      : 'border-transparent text-gray-400 hover:text-gray-300 hover:border-gray-300'
                  }`}
                >
                  <Icon className="h-5 w-5 mr-2" />
                  {tab.name}
                </button>
              )
            })}
          </nav>
        </div>

        <div className="p-6">
          {/* General Settings */}
          {activeTab === 'general' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    Site Name
                  </label>
                  <input
                    type="text"
                    value={settings.general.siteName}
                    onChange={(e) => setSettings({
                      ...settings,
                      general: { ...settings.general, siteName: e.target.value }
                    })}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    Contact Email
                  </label>
                  <input
                    type="email"
                    value={settings.general.contactEmail}
                    onChange={(e) => setSettings({
                      ...settings,
                      general: { ...settings.general, contactEmail: e.target.value }
                    })}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Site Description
                </label>
                <textarea
                  value={settings.general.siteDescription}
                  onChange={(e) => setSettings({
                    ...settings,
                    general: { ...settings.general, siteDescription: e.target.value }
                  })}
                  rows={3}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            </div>
          )}

          {/* Trading Settings */}
          {activeTab === 'trading' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    Trading Fee (%)
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    value={settings.trading.tradingFee}
                    onChange={(e) => setSettings({
                      ...settings,
                      trading: { ...settings.trading, tradingFee: parseFloat(e.target.value) }
                    })}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    Withdrawal Fee
                  </label>
                  <input
                    type="number"
                    step="0.001"
                    value={settings.trading.withdrawalFee}
                    onChange={(e) => setSettings({
                      ...settings,
                      trading: { ...settings.trading, withdrawalFee: parseFloat(e.target.value) }
                    })}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    Minimum Withdrawal ($)
                  </label>
                  <input
                    type="number"
                    value={settings.trading.minimumWithdrawal}
                    onChange={(e) => setSettings({
                      ...settings,
                      trading: { ...settings.trading, minimumWithdrawal: parseInt(e.target.value) }
                    })}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    Daily Withdrawal Limit ($)
                  </label>
                  <input
                    type="number"
                    value={settings.trading.dailyWithdrawalLimit}
                    onChange={(e) => setSettings({
                      ...settings,
                      trading: { ...settings.trading, dailyWithdrawalLimit: parseInt(e.target.value) }
                    })}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                  />
                </div>
              </div>
            </div>
          )}

          {/* Security Settings */}
          {activeTab === 'security' && (
            <div className="space-y-6">
              <div className="space-y-4">
                {[
                  { key: 'twoFactorRequired', label: '2FA Required for All Users' },
                  { key: 'kycRequired', label: 'KYC Verification Required' },
                  { key: 'emailVerificationRequired', label: 'Email Verification Required' }
                ].map((item) => (
                  <div key={item.key} className="flex items-center justify-between">
                    <span className="text-sm font-medium text-gray-300">{item.label}</span>
                    <button
                      onClick={() => setSettings({
                        ...settings,
                        security: {
                          ...settings.security,
                          [item.key]: !settings.security[item.key as keyof typeof settings.security]
                        }
                      })}
                      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                        settings.security[item.key as keyof typeof settings.security]
                          ? 'bg-green-600'
                          : 'bg-gray-600'
                      }`}
                    >
                      <span
                        className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                          settings.security[item.key as keyof typeof settings.security]
                            ? 'translate-x-6'
                            : 'translate-x-1'
                        }`}
                      />
                    </button>
                  </div>
                ))}
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Session Timeout (minutes)
                </label>
                <input
                  type="number"
                  value={settings.security.sessionTimeout}
                  onChange={(e) => setSettings({
                    ...settings,
                    security: { ...settings.security, sessionTimeout: parseInt(e.target.value) }
                  })}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            </div>
          )}

          {/* Notification Settings */}
          {activeTab === 'notifications' && (
            <div className="space-y-6">
              <div className="space-y-4">
                {[
                  { key: 'emailNotifications', label: 'Email Notifications' },
                  { key: 'smsNotifications', label: 'SMS Notifications' },
                  { key: 'pushNotifications', label: 'Push Notifications' },
                  { key: 'maintenanceAlerts', label: 'Maintenance Alerts' }
                ].map((item) => (
                  <div key={item.key} className="flex items-center justify-between">
                    <span className="text-sm font-medium text-gray-300">{item.label}</span>
                    <button
                      onClick={() => setSettings({
                        ...settings,
                        notifications: {
                          ...settings.notifications,
                          [item.key]: !settings.notifications[item.key as keyof typeof settings.notifications]
                        }
                      })}
                      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                        settings.notifications[item.key as keyof typeof settings.notifications]
                          ? 'bg-green-600'
                          : 'bg-gray-600'
                      }`}
                    >
                      <span
                        className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                          settings.notifications[item.key as keyof typeof settings.notifications]
                            ? 'translate-x-6'
                            : 'translate-x-1'
                        }`}
                      />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Save Button */}
          <div className="mt-8 flex justify-end">
            <button
              onClick={handleSave}
              disabled={loading}
              className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 disabled:opacity-50"
            >
              {loading ? 'Saving...' : 'Save Settings'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}