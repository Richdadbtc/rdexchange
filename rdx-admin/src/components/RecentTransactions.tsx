'use client'
import { useState, useEffect } from 'react'
import { EyeIcon } from '@heroicons/react/24/outline'

interface Transaction {
  id: string
  user: string
  type: 'buy' | 'sell'
  amount: number
  currency: string
  status: 'completed' | 'pending' | 'failed'
  timestamp: string
}

export default function RecentTransactions() {
  const [transactions, setTransactions] = useState<Transaction[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchRecentTransactions()
  }, [])

  const fetchRecentTransactions = async () => {
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch('http://localhost:3001/api/admin/recent-transactions', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        setTransactions(data)
      } else {
        // Fallback data for demo
        setTransactions([
          {
            id: 'TXN001',
            user: 'john.doe@email.com',
            type: 'buy',
            amount: 0.5,
            currency: 'BTC',
            status: 'completed',
            timestamp: '2024-01-15T10:30:00Z'
          },
          {
            id: 'TXN002',
            user: 'jane.smith@email.com',
            type: 'sell',
            amount: 1000,
            currency: 'USDT',
            status: 'pending',
            timestamp: '2024-01-15T09:45:00Z'
          },
          {
            id: 'TXN003',
            user: 'mike.wilson@email.com',
            type: 'buy',
            amount: 2.5,
            currency: 'ETH',
            status: 'completed',
            timestamp: '2024-01-15T08:20:00Z'
          },
          {
            id: 'TXN004',
            user: 'sarah.jones@email.com',
            type: 'sell',
            amount: 0.25,
            currency: 'BTC',
            status: 'failed',
            timestamp: '2024-01-15T07:15:00Z'
          }
        ])
      }
    } catch (error) {
      console.error('Error fetching recent transactions:', error)
      // Fallback data
      setTransactions([
        {
          id: 'TXN001',
          user: 'john.doe@email.com',
          type: 'buy',
          amount: 0.5,
          currency: 'BTC',
          status: 'completed',
          timestamp: '2024-01-15T10:30:00Z'
        },
        {
          id: 'TXN002',
          user: 'jane.smith@email.com',
          type: 'sell',
          amount: 1000,
          currency: 'USDT',
          status: 'pending',
          timestamp: '2024-01-15T09:45:00Z'
        }
      ])
    } finally {
      setLoading(false)
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'text-green-400 bg-green-400/10'
      case 'pending':
        return 'text-yellow-400 bg-yellow-400/10'
      case 'failed':
        return 'text-red-400 bg-red-400/10'
      default:
        return 'text-gray-400 bg-gray-400/10'
    }
  }

  const getTypeColor = (type: string) => {
    return type === 'buy' ? 'text-green-400' : 'text-red-400'
  }

  const formatDate = (timestamp: string) => {
    return new Date(timestamp).toLocaleString()
  }

  if (loading) {
    return (
      <div className="bg-gray-800 rounded-lg p-6">
        <div className="animate-pulse">
          <div className="h-4 bg-gray-700 rounded w-1/4 mb-4"></div>
          <div className="space-y-3">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="h-12 bg-gray-700 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-gray-800 rounded-lg p-6">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-lg font-medium text-white">Recent Transactions</h3>
          <p className="text-sm text-gray-400">Latest trading activity</p>
        </div>
        <button className="text-green-400 hover:text-green-300 text-sm font-medium">
          View all
        </button>
      </div>
      
      <div className="space-y-3">
        {transactions.map((transaction) => (
          <div key={transaction.id} className="flex items-center justify-between p-3 bg-gray-700 rounded-lg hover:bg-gray-600 transition-colors">
            <div className="flex items-center space-x-3">
              <div className="flex-shrink-0">
                <div className={`w-2 h-2 rounded-full ${getTypeColor(transaction.type) === 'text-green-400' ? 'bg-green-400' : 'bg-red-400'}`}></div>
              </div>
              <div>
                <p className="text-sm font-medium text-white">{transaction.user}</p>
                <p className="text-xs text-gray-400">{transaction.id}</p>
              </div>
            </div>
            
            <div className="text-right">
              <p className={`text-sm font-medium ${getTypeColor(transaction.type)}`}>
                {transaction.type.toUpperCase()} {transaction.amount} {transaction.currency}
              </p>
              <p className="text-xs text-gray-400">{formatDate(transaction.timestamp)}</p>
            </div>
            
            <div className="flex items-center space-x-2">
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(transaction.status)}`}>
                {transaction.status}
              </span>
              <button className="text-gray-400 hover:text-white">
                <EyeIcon className="h-4 w-4" />
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}