'use client'
import { useState, useEffect } from 'react'
import StatsCard from '@/components/StatsCard'
import RecentTransactions from '@/components/RecentTransactions'
import UserGrowthChart from '@/components/UserGrowthChart'
import { 
  UsersIcon, 
  CreditCardIcon, 
  BanknotesIcon, 
  ArrowTrendingUpIcon 
} from '@heroicons/react/24/outline'

interface DashboardStats {
  totalUsers: number
  totalTransactions: number
  totalVolume: number
  activeOrders: number
}

export default function Dashboard() {
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    totalTransactions: 0,
    totalVolume: 0,
    activeOrders: 0
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchDashboardStats()
  }, [])

  const fetchDashboardStats = async () => {
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch('http://localhost:3001/api/admin/dashboard-stats', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        setStats(data)
      }
    } catch (error) {
      console.error('Error fetching dashboard stats:', error)
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
      <div>
        <h1 className="text-2xl font-semibold text-white">Dashboard Overview</h1>
        <p className="mt-2 text-sm text-gray-400">
          Welcome to RDX Exchange Admin Panel. Here's what's happening today.
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <StatsCard
          title="Total Users"
          value={stats.totalUsers.toLocaleString()}
          icon={UsersIcon}
          change="+12%"
          changeType="increase"
        />
        <StatsCard
          title="Total Transactions"
          value={stats.totalTransactions.toLocaleString()}
          icon={CreditCardIcon}
          change="+8%"
          changeType="increase"
        />
        <StatsCard
          title="Trading Volume"
          value={`$${stats.totalVolume.toLocaleString()}`}
          icon={ArrowTrendingUpIcon}
          change="+15%"
          changeType="increase"
        />
        <StatsCard
          title="Active Orders"
          value={stats.activeOrders.toLocaleString()}
          icon={BanknotesIcon}
          change="-3%"
          changeType="decrease"
        />
      </div>

      {/* Charts and Recent Activity */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <UserGrowthChart />
        <RecentTransactions />
      </div>
    </div>
  )
}