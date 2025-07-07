'use client'
import { useState, useEffect } from 'react'
import {
  DocumentArrowDownIcon,
  CalendarIcon,
  ChartBarIcon,
  CurrencyDollarIcon,
  UsersIcon,
  ArrowDownTrayIcon
} from '@heroicons/react/24/outline'

interface ReportData {
  id: string
  name: string
  type: 'financial' | 'user' | 'trading' | 'security'
  description: string
  lastGenerated: string
  size: string
  status: 'ready' | 'generating' | 'failed'
}

export default function ReportsPage() {
  const [reports, setReports] = useState<ReportData[]>([])
  const [loading, setLoading] = useState(true)
  const [dateRange, setDateRange] = useState({
    start: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    end: new Date().toISOString().split('T')[0]
  })

  useEffect(() => {
    fetchReports()
  }, [])

  const fetchReports = async () => {
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch('http://localhost:3001/api/admin/reports', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        setReports(data)
      } else {
        // Fallback data
        setReports([
          {
            id: '1',
            name: 'Monthly Financial Report',
            type: 'financial',
            description: 'Comprehensive financial overview including revenue, fees, and profit margins',
            lastGenerated: '2024-01-15T10:00:00Z',
            size: '2.4 MB',
            status: 'ready'
          },
          {
            id: '2',
            name: 'User Activity Report',
            type: 'user',
            description: 'User registration, verification, and activity statistics',
            lastGenerated: '2024-01-14T15:30:00Z',
            size: '1.8 MB',
            status: 'ready'
          },
          {
            id: '3',
            name: 'Trading Volume Analysis',
            type: 'trading',
            description: 'Trading pairs performance and volume analysis',
            lastGenerated: '2024-01-13T09:15:00Z',
            size: '3.1 MB',
            status: 'ready'
          },
          {
            id: '4',
            name: 'Security Audit Report',
            type: 'security',
            description: 'Security incidents, login attempts, and system vulnerabilities',
            lastGenerated: '2024-01-12T14:20:00Z',
            size: '1.2 MB',
            status: 'generating'
          }
        ])
      }
    } catch (error) {
      console.error('Error fetching reports:', error)
    } finally {
      setLoading(false)
    }
  }

  const generateReport = async (reportId: string) => {
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch(`http://localhost:3001/api/admin/reports/${reportId}/generate`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(dateRange)
      })
      
      if (response.ok) {
        fetchReports()
      }
    } catch (error) {
      console.error('Error generating report:', error)
    }
  }

  const downloadReport = async (reportId: string) => {
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch(`http://localhost:3001/api/admin/reports/${reportId}/download`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })
      
      if (response.ok) {
        const blob = await response.blob()
        const url = window.URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = `report-${reportId}.pdf`
        document.body.appendChild(a)
        a.click()
        window.URL.revokeObjectURL(url)
        document.body.removeChild(a)
      }
    } catch (error) {
      console.error('Error downloading report:', error)
    }
  }

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'financial':
        return CurrencyDollarIcon
      case 'user':
        return UsersIcon
      case 'trading':
        return ChartBarIcon
      default:
        return DocumentArrowDownIcon
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'ready':
        return 'text-green-400 bg-green-400/10'
      case 'generating':
        return 'text-yellow-400 bg-yellow-400/10'
      case 'failed':
        return 'text-red-400 bg-red-400/10'
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
          <h1 className="text-2xl font-semibold text-white">Reports</h1>
          <p className="mt-2 text-sm text-gray-400">
            Generate and download platform reports
          </p>
        </div>
      </div>

      {/* Date Range Selector */}
      <div className="bg-gray-800 rounded-lg p-4">
        <div className="flex items-center space-x-4">
          <div className="flex items-center space-x-2">
            <CalendarIcon className="h-5 w-5 text-gray-400" />
            <span className="text-sm text-gray-400">Date Range:</span>
          </div>
          <input
            type="date"
            value={dateRange.start}
            onChange={(e) => setDateRange({ ...dateRange, start: e.target.value })}
            className="bg-gray-700 border border-gray-600 rounded-md text-white px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
          />
          <span className="text-gray-400">to</span>
          <input
            type="date"
            value={dateRange.end}
            onChange={(e) => setDateRange({ ...dateRange, end: e.target.value })}
            className="bg-gray-700 border border-gray-600 rounded-md text-white px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
          />
        </div>
      </div>

      {/* Reports Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {reports.map((report) => {
          const Icon = getTypeIcon(report.type)
          return (
            <div key={report.id} className="bg-gray-800 rounded-lg p-6">
              <div className="flex items-start justify-between">
                <div className="flex items-center">
                  <Icon className="h-8 w-8 text-green-400" />
                  <div className="ml-3">
                    <h3 className="text-lg font-medium text-white">{report.name}</h3>
                    <p className="text-sm text-gray-400 mt-1">{report.description}</p>
                  </div>
                </div>
              </div>
              
              <div className="mt-4 space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Last Generated:</span>
                  <span className="text-white">
                    {new Date(report.lastGenerated).toLocaleDateString()}
                  </span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Size:</span>
                  <span className="text-white">{report.size}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Status:</span>
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(report.status)}`}>
                    {report.status}
                  </span>
                </div>
              </div>
              
              <div className="mt-6 flex space-x-2">
                <button
                  onClick={() => generateReport(report.id)}
                  disabled={report.status === 'generating'}
                  className="flex-1 btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {report.status === 'generating' ? 'Generating...' : 'Generate'}
                </button>
                {report.status === 'ready' && (
                  <button
                    onClick={() => downloadReport(report.id)}
                    className="btn-secondary"
                  >
                    <ArrowDownTrayIcon className="h-4 w-4" />
                  </button>
                )}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}