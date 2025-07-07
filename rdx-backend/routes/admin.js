const express = require('express');
const auth = require('../middleware/auth');
const User = require('../models/User');
const Transaction = require('../models/Transaction');
const Order = require('../models/Order');
const Notification = require('../models/Notification');
const Wallet = require('../models/Wallet');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const router = express.Router();

// Middleware to check admin role
const adminAuth = async (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Access denied. Admin privileges required.'
    });
  }
  next();
};

// ==================== AUTHENTICATION ====================

// Admin login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Find admin user
    const admin = await User.findOne({ email, role: 'admin' });
    if (!admin) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }
    
    // Check password
    const isMatch = await admin.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }
    
    // Update last login
    admin.lastLogin = new Date();
    await admin.save();
    
    // Generate token
    const token = jwt.sign(
      { userId: admin._id, role: admin.role },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    res.json({
      success: true,
      token,
      admin: {
        id: admin._id,
        email: admin.email,
        firstName: admin.firstName,
        lastName: admin.lastName,
        role: admin.role
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Get admin profile
router.get('/profile', auth, adminAuth, async (req, res) => {
  try {
    const admin = await User.findById(req.user.userId).select('-password');
    res.json({
      success: true,
      data: admin
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// ==================== DASHBOARD STATS ====================

// Get dashboard statistics
router.get('/stats', auth, adminAuth, async (req, res) => {
  try {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0);
    
    // Total users
    const totalUsers = await User.countDocuments({ role: 'user' });
    const newUsersThisMonth = await User.countDocuments({
      role: 'user',
      createdAt: { $gte: startOfMonth }
    });
    const newUsersLastMonth = await User.countDocuments({
      role: 'user',
      createdAt: { $gte: startOfLastMonth, $lte: endOfLastMonth }
    });
    
    // Total transactions
    const totalTransactions = await Transaction.countDocuments();
    const transactionsThisMonth = await Transaction.countDocuments({
      createdAt: { $gte: startOfMonth }
    });
    const transactionsLastMonth = await Transaction.countDocuments({
      createdAt: { $gte: startOfLastMonth, $lte: endOfLastMonth }
    });
    
    // Trading volume
    const volumeResult = await Transaction.aggregate([
      { $match: { type: 'trade', status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);
    const totalVolume = volumeResult[0]?.total || 0;
    
    const volumeThisMonth = await Transaction.aggregate([
      { 
        $match: { 
          type: 'trade', 
          status: 'completed',
          createdAt: { $gte: startOfMonth }
        }
      },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);
    const volumeLastMonth = await Transaction.aggregate([
      { 
        $match: { 
          type: 'trade', 
          status: 'completed',
          createdAt: { $gte: startOfLastMonth, $lte: endOfLastMonth }
        }
      },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);
    
    // Active orders
    const activeOrders = await Order.countDocuments({ status: 'pending' });
    
    // Calculate percentage changes
    const userChange = newUsersLastMonth > 0 
      ? ((newUsersThisMonth - newUsersLastMonth) / newUsersLastMonth * 100).toFixed(1)
      : 0;
    
    const transactionChange = transactionsLastMonth > 0
      ? ((transactionsThisMonth - transactionsLastMonth) / transactionsLastMonth * 100).toFixed(1)
      : 0;
    
    const volumeChangeValue = volumeLastMonth[0]?.total || 0;
    const volumeThisMonthValue = volumeThisMonth[0]?.total || 0;
    const volumeChangePercent = volumeChangeValue > 0
      ? ((volumeThisMonthValue - volumeChangeValue) / volumeChangeValue * 100).toFixed(1)
      : 0;
    
    res.json({
      success: true,
      data: {
        totalUsers,
        totalTransactions,
        totalVolume,
        activeOrders,
        userChange: parseFloat(userChange),
        transactionChange: parseFloat(transactionChange),
        volumeChange: parseFloat(volumeChangePercent),
        ordersChange: 0 // You can implement this based on your needs
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Get analytics data
router.get('/analytics', auth, adminAuth, async (req, res) => {
  try {
    const { range = '6months' } = req.query;
    
    let months = 6;
    switch (range) {
      case '1month': months = 1; break;
      case '3months': months = 3; break;
      case '1year': months = 12; break;
      default: months = 6;
    }
    
    const now = new Date();
    const startDate = new Date(now.getFullYear(), now.getMonth() - months + 1, 1);
    
    // Revenue data (from trading fees)
    const revenueData = await Transaction.aggregate([
      {
        $match: {
          type: 'trade',
          status: 'completed',
          createdAt: { $gte: startDate }
        }
      },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' }
          },
          amount: { $sum: '$fee' }
        }
      },
      { $sort: { '_id.year': 1, '_id.month': 1 } }
    ]);
    
    // User growth data
    const userGrowthData = await User.aggregate([
      {
        $match: {
          role: 'user',
          createdAt: { $gte: startDate }
        }
      },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' }
          },
          users: { $sum: 1 }
        }
      },
      { $sort: { '_id.year': 1, '_id.month': 1 } }
    ]);
    
    // Format data for frontend
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    const revenue = revenueData.map(item => ({
      month: monthNames[item._id.month - 1],
      amount: item.amount
    }));
    
    const userGrowth = userGrowthData.map(item => ({
      month: monthNames[item._id.month - 1],
      users: item.users,
      active: Math.floor(item.users * 0.7) // Estimate active users as 70%
    }));
    
    res.json({
      success: true,
      data: {
        revenue,
        userGrowth,
        tradingVolume: [
          { currency: 'BTC', volume: 45, color: '#F7931A' },
          { currency: 'ETH', volume: 30, color: '#627EEA' },
          { currency: 'USDT', volume: 15, color: '#26A17B' },
          { currency: 'Others', volume: 10, color: '#8B5CF6' }
        ],
        topTraders: [] // Implement based on your trading data
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// ==================== USER MANAGEMENT ====================

// Get all users with pagination and filters
router.get('/users', auth, adminAuth, async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      search = '', 
      status = 'all',
      role = 'all'
    } = req.query;
    
    const filter = { role: 'user' };
    
    if (search) {
      filter.$or = [
        { firstName: { $regex: search, $options: 'i' } },
        { lastName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (status !== 'all') filter.status = status;
    if (role !== 'all') filter.role = role;
    
    const users = await User.find(filter)
      .select('-password -resetPasswordToken -emailVerificationToken')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });
    
    const total = await User.countDocuments(filter);
    
    res.json({
      success: true,
      data: {
        users,
        totalPages: Math.ceil(total / limit),
        currentPage: parseInt(page),
        total
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Update user
router.put('/users/:userId', auth, adminAuth, async (req, res) => {
  try {
    const { status, role, isEmailVerified, isPhoneVerified } = req.body;
    const { userId } = req.params;
    
    const updateData = {};
    if (status) updateData.status = status;
    if (role) updateData.role = role;
    if (typeof isEmailVerified === 'boolean') updateData.isEmailVerified = isEmailVerified;
    if (typeof isPhoneVerified === 'boolean') updateData.isPhoneVerified = isPhoneVerified;
    
    const user = await User.findByIdAndUpdate(
      userId,
      updateData,
      { new: true }
    ).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    res.json({
      success: true,
      message: 'User updated successfully',
      data: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Delete user
router.delete('/users/:userId', auth, adminAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await User.findByIdAndDelete(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    // Also delete related data
    await Promise.all([
      Transaction.deleteMany({ userId }),
      Order.deleteMany({ userId }),
      Notification.deleteMany({ userId }),
      Wallet.deleteMany({ userId })
    ]);
    
    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Verify user
router.post('/users/:userId/verify', auth, adminAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await User.findByIdAndUpdate(
      userId,
      { 
        isEmailVerified: true,
        status: 'active'
      },
      { new: true }
    ).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    res.json({
      success: true,
      message: 'User verified successfully',
      data: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Suspend user
router.post('/users/:userId/suspend', auth, adminAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await User.findByIdAndUpdate(
      userId,
      { status: 'suspended' },
      { new: true }
    ).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    res.json({
      success: true,
      message: 'User suspended successfully',
      data: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// ==================== TRANSACTION MANAGEMENT ====================

// Get all transactions
router.get('/transactions', auth, adminAuth, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      search = '',
      status = 'all',
      type = 'all',
      startDate,
      endDate
    } = req.query;
    
    const filter = {};
    
    if (search) {
      const users = await User.find({
        $or: [
          { email: { $regex: search, $options: 'i' } },
          { firstName: { $regex: search, $options: 'i' } },
          { lastName: { $regex: search, $options: 'i' } }
        ]
      }).select('_id');
      
      filter.$or = [
        { userId: { $in: users.map(u => u._id) } },
        { txHash: { $regex: search, $options: 'i' } },
        { currency: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (status !== 'all') filter.status = status;
    if (type !== 'all') filter.type = type;
    
    if (startDate && endDate) {
      filter.createdAt = {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      };
    }
    
    const transactions = await Transaction.find(filter)
      .populate('userId', 'firstName lastName email')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });
    
    const total = await Transaction.countDocuments(filter);
    
    res.json({
      success: true,
      data: {
        transactions,
        totalPages: Math.ceil(total / limit),
        currentPage: parseInt(page),
        total
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Update transaction status
router.put('/transactions/:transactionId', auth, adminAuth, async (req, res) => {
  try {
    const { status } = req.body;
    const { transactionId } = req.params;
    
    const transaction = await Transaction.findByIdAndUpdate(
      transactionId,
      { status },
      { new: true }
    ).populate('userId', 'firstName lastName email');
    
    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Transaction updated successfully',
      data: transaction
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// ==================== ORDER MANAGEMENT ====================

// Get all orders
router.get('/orders', auth, adminAuth, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      search = '',
      status = 'all',
      type = 'all'
    } = req.query;
    
    const filter = {};
    
    if (search) {
      const users = await User.find({
        $or: [
          { email: { $regex: search, $options: 'i' } },
          { firstName: { $regex: search, $options: 'i' } },
          { lastName: { $regex: search, $options: 'i' } }
        ]
      }).select('_id');
      
      filter.$or = [
        { userId: { $in: users.map(u => u._id) } },
        { symbol: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (status !== 'all') filter.status = status;
    if (type !== 'all') filter.type = type;
    
    const orders = await Order.find(filter)
      .populate('userId', 'firstName lastName email')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 });
    
    const total = await Order.countDocuments(filter);
    
    // Format orders for frontend
    const formattedOrders = orders.map(order => ({
      id: order._id,
      userId: order.userId._id,
      userEmail: order.userId.email,
      type: order.type,
      orderType: order.orderType,
      pair: order.symbol,
      amount: order.amount,
      price: order.price || 0,
      filled: order.filledAmount,
      status: order.status === 'filled' ? 'completed' : order.status,
      createdAt: order.createdAt
    }));
    
    res.json({
      success: true,
      data: {
        orders: formattedOrders,
        totalPages: Math.ceil(total / limit),
        currentPage: parseInt(page),
        total
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Cancel order
router.post('/orders/:orderId/cancel', auth, adminAuth, async (req, res) => {
  try {
    const { orderId } = req.params;
    
    const order = await Order.findByIdAndUpdate(
      orderId,
      { status: 'cancelled' },
      { new: true }
    ).populate('userId', 'firstName lastName email');
    
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Order cancelled successfully',
      data: order
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// ==================== NOTIFICATION MANAGEMENT ====================

// Get all notifications
router.get('/notifications', auth, adminAuth, async (req, res) => {
  try {
    // For admin notifications, we'll create a different schema
    // For now, return mock data that matches the frontend expectations
    const notifications = [
      {
        id: '1',
        title: 'System Maintenance Scheduled',
        message: 'We will be performing scheduled maintenance on January 20th from 2:00 AM to 4:00 AM UTC.',
        type: 'warning',
        status: 'sent',
        recipients: 'all',
        sentAt: new Date().toISOString(),
        createdAt: new Date().toISOString(),
        readCount: 1250,
        totalRecipients: 2180
      }
    ];
    
    res.json({
      success: true,
      data: notifications
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Create notification
router.post('/notifications', auth, adminAuth, async (req, res) => {
  try {
    const { title, message, type, recipients } = req.body;
    
    // Here you would implement the logic to send notifications
    // to users based on the recipients filter
    
    res.json({
      success: true,
      message: 'Notification created successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// ==================== SETTINGS ====================

// Get settings
router.get('/settings', auth, adminAuth, async (req, res) => {
  try {
    // Return default settings - you can store these in a Settings model
    const settings = {
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
    };
    
    res.json({
      success: true,
      data: settings
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Update settings
router.put('/settings', auth, adminAuth, async (req, res) => {
  try {
    // Here you would save the settings to a database
    // For now, just return success
    
    res.json({
      success: true,
      message: 'Settings updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// ==================== REPORTS ====================

// Get reports
router.get('/reports', auth, adminAuth, async (req, res) => {
  try {
    const reports = [
      {
        id: '1',
        name: 'Monthly Financial Report',
        type: 'financial',
        description: 'Comprehensive financial overview including revenue, fees, and profit margins',
        lastGenerated: new Date().toISOString(),
        size: '2.4 MB',
        status: 'ready'
      },
      {
        id: '2',
        name: 'User Activity Report',
        type: 'user',
        description: 'User registration, verification, and activity statistics',
        lastGenerated: new Date().toISOString(),
        size: '1.8 MB',
        status: 'ready'
      }
    ];
    
    res.json({
      success: true,
      data: reports
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Generate report
router.post('/reports/:reportId/generate', auth, adminAuth, async (req, res) => {
  try {
    const { reportId } = req.params;
    const { start, end } = req.body;
    
    // Here you would implement report generation logic
    
    res.json({
      success: true,
      message: 'Report generation started'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

// Download report
router.get('/reports/:reportId/download', auth, adminAuth, async (req, res) => {
  try {
    const { reportId } = req.params;
    
    // Here you would implement report download logic
    // For now, return a simple response
    
    res.json({
      success: true,
      message: 'Report download would start here'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

module.exports = router;