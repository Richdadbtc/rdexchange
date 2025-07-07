'use client'
import { useState, useEffect } from 'react'
import {
  MagnifyingGlassIcon,
  FunnelIcon,
  EyeIcon,
  XMarkIcon,
  CheckIcon,
  ClockIcon,
  ArrowDownTrayIcon
} from '@heroicons/react/24/outline'

interface Order {
  id: string
  userId: string
  userEmail: string
  type: 'buy' | 'sell'
  orderType: 'market' | 'limit' | 'stop'
  pair: string
  amount: number
  price: number
  filled: number
  remaining: number
  status: 'pending' | 'partial' | 'completed' | 'cancelled'
  createdAt: string
  updatedAt: string
  fee: number
}

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [typeFilter, setTypeFilter] = useState('all')
  const [currentPage, setCurrentPage] = useState(1)
  const ordersPerPage = 15

  useEffect(() => {
    fetchOrders()
  }, [])

  const fetchOrders = async () => {
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch('http://localhost:3001/api/admin/orders', {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        setOrders(data)
      } else {
        // Fallback data
        setOrders([
          {
            id: 'ORD001',
            userId: '1',
            userEmail: 'john.doe@email.com',
            type: 'buy',
            orderType: 'limit',
            pair: 'BTC/USDT',
            amount: 0.5,
            price: 45000,
            filled: 0.3,
            remaining: 0.2,
            status: 'partial',
            createdAt: '2024-01-15T10:30:00Z',
            updatedAt: '2024-01-15T11:00:00Z',
            fee: 56.25
          },
          {
            id: 'ORD002',
            userId: '2',
            userEmail: 'jane.smith@email.com',
            type: 'sell',
            orderType: 'market',
            pair: 'ETH/USDT',
            amount: 2.5,
            price: 2800,
            filled: 2.5,
            remaining: 0,
            status: 'completed',
            createdAt: '2024-01-15T09:45:00Z',
            updatedAt: '2024-01-15T09:46:00Z',
            fee: 17.50
          },
          {
            id: 'ORD003',
            userId: '3',
            userEmail: 'mike.wilson@email.com',
            type: 'buy',
            orderType: 'limit',
            pair: 'BTC/USDT',
            amount: 1.0,
            price: 44000,
            filled: 0,
            remaining: 1.0,
            status: 'pending',
            createdAt: '2024-01-15T08:20:00Z',
            updatedAt: '2024-01-15T08:20:00Z',
            fee: 0
          }
        ])
      }
    } catch (error) {
      console.error('Error fetching orders:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleCancelOrder = async (orderId: string) => {
    try {
      const token = localStorage.getItem('adminToken')
      const response = await fetch(`http://localhost:3001/api/admin/orders/${orderId}/cancel`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })
      
      if (response.ok) {
        fetchOrders()
      }
    } catch (error) {
      console.error('Error cancelling order:', error)
    }
  }

  const filteredOrders = orders.filter(order => {
    const matchesSearch = order.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         order.userEmail.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         order.pair.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === 'all' || order.status === statusFilter
    const matchesType = typeFilter === 'all' || order.type === typeFilter
    return matchesSearch && matchesStatus && matchesType
  })

  const totalPages = Math.ceil(filteredOrders.length / ordersPerPage)
  const startIndex = (currentPage - 1) * ordersPerPage
  const paginatedOrders = filteredOrders.slice(startIndex, startIndex + ordersPerPage)

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'text-green-400 bg-green-400/10'
      case 'pending':
        return 'text-yellow-400 bg-yellow-400/10'
      case 'partial':
        return 'text-blue-400 bg-blue-400/10'
      case 'cancelled':
        return 'text-red-400 bg-red-400/10'
      default:
        return 'text-gray-400 bg-gray-400/10'
    }
  }

  const getTypeColor = (type: string) => {
    return type === 'buy' ? 'text-green-400' : 'text-red-400'
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
          <h1 className="text-2xl font-semibold text-white">Order Management</h1>
          <p className="mt-2 text-sm text-gray-400">
            Monitor and manage all trading orders
          </p>
        </div>
        <button className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700">
          <ArrowDownTrayIcon className="h-4 w-4 mr-2" />
          Export Orders
        </button>
      </div>

      {/* Filters */}
      <div className="bg-gray-800 rounded-lg p-4">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="relative">
            <MagnifyingGlassIcon className="h-5 w-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Search orders..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"
            />
          </div>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="bg-gray-700 border border-gray-600 rounded-md text-white px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
          >
            <option value="all">All Status</option>
            <option value="pending">Pending</option>
            <option value="partial">Partial</option>
            <option value="completed">Completed</option>
            <option value="cancelled">Cancelled</option>
          </select>
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
            className="bg-gray-700 border border-gray-600 rounded-md text-white px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-500"
          >
            <option value="all">All Types</option>
            <option value="buy">Buy Orders</option>
            <option value="sell">Sell Orders</option>
          </select>
          <div className="flex items-center space-x-2">
            <FunnelIcon className="h-5 w-5 text-gray-400" />
            <span className="text-sm text-gray-400">
              {filteredOrders.length} orders
            </span>
          </div>
        </div>
      </div>

      {/* Orders Table */}
      <div className="bg-gray-800 rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-700">
            <thead className="bg-gray-700">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Order ID
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  User
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Pair
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Price
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Progress
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                  Status
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
              {paginatedOrders.map((order) => (
                <tr key={order.id} className="hover:bg-gray-700">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-white">{order.id}</div>
                    <div className="text-xs text-gray-400">{order.orderType}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-white">{order.userEmail}</div>
                    <div className="text-xs text-gray-400">ID: {order.userId}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`text-sm font-medium ${getTypeColor(order.type)}`}>
                      {order.type.toUpperCase()}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-white">
                    {order.pair}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-white">
                    {order.amount}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-white">
                    ${order.price.toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="w-16 bg-gray-600 rounded-full h-2 mr-2">
                        <div
                          className="bg-green-500 h-2 rounded-full"
                          style={{ width: `${(order.filled / order.amount) * 100}%` }}
                        ></div>
                      </div>
                      <span className="text-xs text-gray-400">
                        {Math.round((order.filled / order.amount) * 100)}%
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(order.status)}`}>
                      {order.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                    {new Date(order.createdAt).toLocaleString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button className="text-blue-400 hover:text-blue-300">
                        <EyeIcon className="h-4 w-4" />
                      </button>
                      {(order.status === 'pending' || order.status === 'partial') && (
                        <button
                          onClick={() => handleCancelOrder(order.id)}
                          className="text-red-400 hover:text-red-300"
                        >
                          <XMarkIcon className="h-4 w-4" />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Pagination */}
      <div className="bg-gray-800 px-4 py-3 flex items-center justify-between border-t border-gray-700 sm:px-6 rounded-lg">
        <div className="flex-1 flex justify-between sm:hidden">
          <button
            onClick={() => setCurrentPage(Math.max(currentPage - 1, 1))}
            disabled={currentPage === 1}
            className="relative inline-flex items-center px-4 py-2 border border-gray-600 text-sm font-medium rounded-md text-gray-300 bg-gray-700 hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Previous
          </button>
          <button
            onClick={() => setCurrentPage(Math.min(currentPage + 1, totalPages))}
            disabled={currentPage === totalPages}
            className="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-600 text-sm font-medium rounded-md text-gray-300 bg-gray-700 hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Next
          </button>
        </div>
        <div className="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
          <div>
            <p className="text-sm text-gray-400">
              Showing{' '}
              <span className="font-medium">{startIndex + 1}</span>
              {' '}to{' '}
              <span className="font-medium">
                {Math.min(startIndex + ordersPerPage, filteredOrders.length)}
              </span>
              {' '}of{' '}
              <span className="font-medium">{filteredOrders.length}</span>
              {' '}results
            </p>
          </div>
          <div>
            <nav className="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
              <button
                onClick={() => setCurrentPage(Math.max(currentPage - 1, 1))}
                disabled={currentPage === 1}
                className="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-600 bg-gray-700 text-sm font-medium text-gray-300 hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Previous
              </button>
              {Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
                <button
                  key={page}
                  onClick={() => setCurrentPage(page)}
                  className={`relative inline-flex items-center px-4 py-2 border text-sm font-medium ${
                    page === currentPage
                      ? 'z-10 bg-green-600 border-green-500 text-white'
                      : 'bg-gray-700 border-gray-600 text-gray-300 hover:bg-gray-600'
                  }`}
                >
                  {page}
                </button>
              ))}
              <button
                onClick={() => setCurrentPage(Math.min(currentPage + 1, totalPages))}
                disabled={currentPage === totalPages}
                className="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-600 bg-gray-700 text-sm font-medium text-gray-300 hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Next
              </button>
            </nav>
          </div>
        </div>
      </div>
    </div>
  )
}