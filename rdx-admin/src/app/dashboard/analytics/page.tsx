'use client'
import { useState, useEffect } from 'react'
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend
} from 'recharts'
import {
  CalendarIcon,
  ArrowDownTrayIcon,
  ChartBarIcon,
  CurrencyDollarIcon,
  UsersIcon} from '@heroicons/react/24/outline'

interface AnalyticsData {
  revenue: Array<{ month: string; amount: number }>
  userGrowth: Array<{ month: string; users: number; active: number }>
  tradingVolume: Array<{ currency: string; volume: number; color: string }>
  topTraders: Array<{ name: string; volume: number; profit: number }>
}

export default function AnalyticsPage() {
  const [data, setData] = useState<AnalyticsData>({
    revenue: [],
    userGrowth: [],
    tradingVolume: [],
    topTraders: []
  })
  const [loading, setLoading] = useState(true)
  const [timeRange, setTimeRange] = useState('6months')

  useEffect(() => {
    fetchAnalyticsData()
  }, [timeRange])

  const fetchAnalyticsData = async () => {
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch(`http://localhost:3001/api/admin/analytics?range=${timeRange}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (response.ok) {
        const analyticsData = await response.json()
        setData(analyticsData)
      } else {
        // Fallback data
        setData({
          revenue: [
            { month: 'Jan', amount: 45000 },
            { month: 'Feb', amount: 52000 },
            { month: 'Mar', amount: 48000 },
            { month: 'Apr', amount: 61000 },
            { month: 'May', amount: 55000 },
            { month: 'Jun', amount: 67000 }
          ],
          userGrowth: [
            { month: 'Jan', users: 1200, active: 890 },
            { month: 'Feb', users: 1350, active: 1020 },
            { month: 'Mar', users: 1580, active: 1180 },
            { month: 'Apr', users: 1720, active: 1350 },
            { month: 'May', users: 1950, active: 1520 },
            { month: 'Jun', users: 2180, active: 1680 }
          ],
          tradingVolume: [
            { currency: 'BTC', volume: 45, color: '#F7931A' },
            { currency: 'ETH', volume: 30, color: '#627EEA' },
            { currency: 'USDT', volume: 15, color: '#26A17B' },
            { currency: 'Others', volume: 10, color: '#8B5CF6' }
          ],
          topTraders: [
            { name: 'john.doe@email.com', volume: 125000, profit: 15420 },
            { name: 'jane.smith@email.com', volume: 98000, profit: 12350 },
            { name: 'mike.wilson@email.com', volume: 87000, profit: 9870 },
            { name: 'sarah.jones@email.com', volume: 76000, profit: 8450 },
            { name: 'alex.brown@email.com', volume: 65000, profit: 7230 }
          ]
        })
      }
    } catch (error) {
      console.error('Error fetching analytics:', error)
    } finally {
      setLoading(false)
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
          <h1 className="text-2xl font-semibold text-white">Analytics Dashboard</h1>
          <p className="mt-2 text-sm text-gray-400">
            Comprehensive platform analytics and insights
          </p>
        </div>
        <div className="flex items-center space-x-4">
          <select
            value={timeRange}
            onChange={(e) => setTimeRange(e.target.value)}
            className="bg-gray-700 border border-gray-600 rounded-md text-white px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
          >
            <option value="1month">Last Month</option>
            <option value="3months">Last 3 Months</option>
            <option value="6months">Last 6 Months</option>
            <option value="1year">Last Year</option>
          </select>
          <button className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700">
            <ArrowDownTrayIcon className="h-4 w-4 mr-2" />
            Export
          </button>
        </div>
      </div>

      {/* Revenue Chart */}
      <div className="bg-gray-800 rounded-lg p-6">
        <div className="mb-4">
          <h3 className="text-lg font-medium text-white">Revenue Trends</h3>
          <p className="text-sm text-gray-400">Monthly revenue from trading fees</p>
        </div>
        <div className="h-80">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={data.revenue}>
              <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
              <XAxis dataKey="month" stroke="#9CA3AF" />
              <YAxis stroke="#9CA3AF" />
              <Tooltip
                contentStyle={{
                  backgroundColor: '#1F2937',
                  border: '1px solid #374151',
                  borderRadius: '6px',
                  color: '#F9FAFB'
                }}
                formatter={(value) => [`$${value.toLocaleString()}`, 'Revenue']}
              />
              <Area
                type="monotone"
                dataKey="amount"
                stroke="#10B981"
                fill="#10B981"
                fillOpacity={0.3}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* User Growth */}
        <div className="bg-gray-800 rounded-lg p-6">
          <div className="mb-4">
            <h3 className="text-lg font-medium text-white">User Growth</h3>
            <p className="text-sm text-gray-400">Total vs Active Users</p>
          </div>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data.userGrowth}>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis dataKey="month" stroke="#9CA3AF" />
                <YAxis stroke="#9CA3AF" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1F2937',
                    border: '1px solid #374151',
                    borderRadius: '6px',
                    color: '#F9FAFB'
                  }}
                />
                <Legend />
                <Bar dataKey="users" fill="#3B82F6" name="Total Users" />
                <Bar dataKey="active" fill="#10B981" name="Active Users" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Trading Volume Distribution */}
        <div className="bg-gray-800 rounded-lg p-6">
          <div className="mb-4">
            <h3 className="text-lg font-medium text-white">Trading Volume by Currency</h3>
            <p className="text-sm text-gray-400">Distribution of trading volume</p>
          </div>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={data.tradingVolume}
                  cx="50%"
                  cy="50%"
                  outerRadius={80}
                  dataKey="volume"
                  label={({ currency, volume }) => `${currency}: ${volume}%`}
                >
                  {data.tradingVolume.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1F2937',
                    border: '1px solid #374151',
                    borderRadius: '6px',
                    color: '#F9FAFB'
                  }}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Top Traders */}
      <div className="bg-gray-800 rounded-lg p-6">
        <div className="mb-4">
          <h3 className="text-lg font-medium text-white">Top Traders</h3>
          <p className="text-sm text-gray-400">Highest volume traders this period</p>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead>
              <tr className="border-b border-gray-700">
                <th className="text-left py-3 px-4 text-sm font-medium text-gray-300">Trader</th>
                <th className="text-left py-3 px-4 text-sm font-medium text-gray-300">Volume</th>
                <th className="text-left py-3 px-4 text-sm font-medium text-gray-300">Profit/Loss</th>
                <th className="text-left py-3 px-4 text-sm font-medium text-gray-300">Rank</th>
              </tr>
            </thead>
            <tbody>
              {data.topTraders.map((trader, index) => (
                <tr key={trader.name} className="border-b border-gray-700 hover:bg-gray-700">
                  <td className="py-3 px-4 text-sm text-white">{trader.name}</td>
                  <td className="py-3 px-4 text-sm text-white">${trader.volume.toLocaleString()}</td>
                  <td className="py-3 px-4 text-sm">
                    <span className={`${trader.profit > 0 ? 'text-green-400' : 'text-red-400'}`}>
                      ${trader.profit.toLocaleString()}
                    </span>
                  </td>
                  <td className="py-3 px-4 text-sm text-gray-400">#{index + 1}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}