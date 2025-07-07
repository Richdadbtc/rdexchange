'use client'
import { useState, useEffect } from 'react'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer
} from 'recharts'

interface ChartData {
  month: string
  users: number
  transactions: number
}

export default function UserGrowthChart() {
  const [data, setData] = useState<ChartData[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchChartData()
  }, [])

  const fetchChartData = async () => {
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch('http://localhost:3001/api/admin/growth-stats', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (response.ok) {
        const chartData = await response.json()
        setData(chartData)
      } else {
        // Fallback data for demo
        setData([
          { month: 'Jan', users: 1200, transactions: 890 },
          { month: 'Feb', users: 1350, transactions: 1020 },
          { month: 'Mar', users: 1580, transactions: 1180 },
          { month: 'Apr', users: 1720, transactions: 1350 },
          { month: 'May', users: 1950, transactions: 1520 },
          { month: 'Jun', users: 2180, transactions: 1680 }
        ])
      }
    } catch (error) {
      console.error('Error fetching chart data:', error)
      // Fallback data
      setData([
        { month: 'Jan', users: 1200, transactions: 890 },
        { month: 'Feb', users: 1350, transactions: 1020 },
        { month: 'Mar', users: 1580, transactions: 1180 },
        { month: 'Apr', users: 1720, transactions: 1350 },
        { month: 'May', users: 1950, transactions: 1520 },
        { month: 'Jun', users: 2180, transactions: 1680 }
      ])
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="bg-gray-800 rounded-lg p-6">
        <div className="animate-pulse">
          <div className="h-4 bg-gray-700 rounded w-1/4 mb-4"></div>
          <div className="h-64 bg-gray-700 rounded"></div>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-gray-800 rounded-lg p-6">
      <div className="mb-4">
        <h3 className="text-lg font-medium text-white">User Growth & Transactions</h3>
        <p className="text-sm text-gray-400">Monthly growth trends</p>
      </div>
      
      <div className="h-64">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data}>
            <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
            <XAxis 
              dataKey="month" 
              stroke="#9CA3AF"
              fontSize={12}
            />
            <YAxis 
              stroke="#9CA3AF"
              fontSize={12}
            />
            <Tooltip 
              contentStyle={{
                backgroundColor: '#1F2937',
                border: '1px solid #374151',
                borderRadius: '6px',
                color: '#F9FAFB'
              }}
            />
            <Line 
              type="monotone" 
              dataKey="users" 
              stroke="#10B981" 
              strokeWidth={2}
              name="Users"
              dot={{ fill: '#10B981', strokeWidth: 2, r: 4 }}
            />
            <Line 
              type="monotone" 
              dataKey="transactions" 
              stroke="#3B82F6" 
              strokeWidth={2}
              name="Transactions"
              dot={{ fill: '#3B82F6', strokeWidth: 2, r: 4 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  )
}