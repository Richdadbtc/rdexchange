// Admin Dashboard JavaScript - Modular Version
class AdminDashboard {
    constructor() {
        this.apiBaseUrl = 'http://localhost:3001/api';
        this.token = localStorage.getItem('adminToken');
        this.demoCredentials = {
            email: 'admin@rdx.com',
            password: 'admin123'
        };
        this.currentPage = 'dashboard';
        this.init();
    }

    async init() {
        await this.loadComponents();
        this.setupEventListeners();
        this.checkAuth();
        this.initCharts();
    }

    async loadComponents() {
        // Load sidebar
        const sidebarResponse = await fetch('components/sidebar.html');
        const sidebarHtml = await sidebarResponse.text();
        document.getElementById('sidebar-container').innerHTML = sidebarHtml;

        // Load header
        const headerResponse = await fetch('components/header.html');
        const headerHtml = await headerResponse.text();
        document.getElementById('header-container').innerHTML = headerHtml;

        // Load modals
        const modalsResponse = await fetch('components/modals.html');
        const modalsHtml = await modalsResponse.text();
        document.getElementById('modals-container').innerHTML = modalsHtml;
    }

    async loadPage(pageName) {
        try {
            const response = await fetch(`pages/${pageName}.html`);
            const pageHtml = await response.text();
            document.getElementById('page-content').innerHTML = pageHtml;
            
            // Update active nav link
            document.querySelectorAll('.nav-link').forEach(link => {
                link.classList.remove('active');
            });
            document.querySelector(`[data-page="${pageName}"]`).classList.add('active');
            
            this.currentPage = pageName;
            this.loadPageData(pageName);
        } catch (error) {
            console.error('Error loading page:', error);
        }
    }

    setupEventListeners() {
        // Login form
        document.getElementById('loginForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleLogin();
        });

        // Logout button (delegated event)
        document.addEventListener('click', (e) => {
            if (e.target.id === 'logoutBtn' || e.target.closest('#logoutBtn')) {
                this.handleLogout();
            }
        });

        // Sidebar navigation (delegated event)
        document.addEventListener('click', (e) => {
            const pageLink = e.target.closest('[data-page]');
            if (pageLink) {
                e.preventDefault();
                this.loadPage(pageLink.dataset.page);
            }
        });

        // Sidebar toggle (delegated event)
        document.addEventListener('click', (e) => {
            if (e.target.id === 'sidebarToggle' || e.target.closest('#sidebarToggle')) {
                document.querySelector('.sidebar').classList.toggle('show');
            }
        });
    }

    checkAuth() {
        if (!this.token) {
            this.showLogin();
        } else {
            this.showDashboard();
            this.loadPage('dashboard');
        }
    }

    showLogin() {
        const loginModal = new bootstrap.Modal(document.getElementById('loginModal'));
        loginModal.show();
        document.getElementById('dashboard').classList.add('d-none');
    }

    showDashboard() {
        const loginModal = bootstrap.Modal.getInstance(document.getElementById('loginModal'));
        if (loginModal) loginModal.hide();
        document.getElementById('dashboard').classList.remove('d-none');
    }

    async handleLogin() {
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const errorDiv = document.getElementById('loginError');

        // Check demo credentials first
        if (email === this.demoCredentials.email && password === this.demoCredentials.password) {
            this.token = 'demo-admin-token-' + Date.now();
            localStorage.setItem('adminToken', this.token);
            localStorage.setItem('adminUser', JSON.stringify({
                id: 1,
                email: email,
                name: 'Demo Admin',
                role: 'admin'
            }));
            this.showDashboard();
            this.loadPage('dashboard');
            errorDiv.classList.add('d-none');
            return;
        }

        // Try API login if demo credentials don't match
        try {
            const response = await fetch(`${this.apiBaseUrl}/auth/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email, password })
            });

            const data = await response.json();

            if (response.ok && data.user.role === 'admin') {
                this.token = data.token;
                localStorage.setItem('adminToken', this.token);
                localStorage.setItem('adminUser', JSON.stringify(data.user));
                this.showDashboard();
                this.loadPage('dashboard');
                errorDiv.classList.add('d-none');
            } else {
                errorDiv.textContent = 'Invalid admin credentials. Try: admin@rdx.com / admin123';
                errorDiv.classList.remove('d-none');
            }
        } catch (error) {
            errorDiv.textContent = 'Login failed. Use demo credentials: admin@rdx.com / admin123';
            errorDiv.classList.remove('d-none');
        }
    }

    handleLogout() {
        localStorage.removeItem('adminToken');
        localStorage.removeItem('adminUser');
        this.token = null;
        this.showLogin();
    }

    loadPageData(pageName) {
        switch(pageName) {
            case 'dashboard':
                this.loadDashboardData();
                break;
            case 'users':
                this.loadUsers();
                break;
            case 'transactions':
                this.loadTransactions();
                break;
            case 'orders':
                this.loadOrders();
                break;
            case 'rates':
                this.loadRates();
                break;
            case 'analytics':
                this.loadAnalytics();
                break;
            case 'settings':
                this.loadSettings();
                break;
            case 'notifications':
                this.loadNotifications();
                break;
        }
    }

    // Rate Management Functions
    // Update the loadRates method to use real API
    async loadRates() {
        try {
            const response = await fetch(`${this.apiUrl}/admin/rates`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch rates');
            }
            
            const result = await response.json();
            const rates = result.data.rates;
            
            // Load rate statistics
            await this.loadRateStats();
            
            this.displayRates(rates);
            this.setupRateEventListeners();
        } catch (error) {
            console.error('Error loading rates:', error);
            this.showToast('Failed to load rates', 'error');
        }
    }
    
    // Add new method to load rate statistics
    async loadRateStats() {
        try {
            const response = await fetch(`${this.apiUrl}/admin/rates/stats`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch rate stats');
            }
            
            const result = await response.json();
            const stats = result.data;
            
            document.getElementById('activePairs').textContent = stats.activeRates;
            document.getElementById('avgBuyRate').textContent = `$${stats.avgBuyRate.toFixed(2)}`;
            document.getElementById('avgSellRate').textContent = `$${stats.avgSellRate.toFixed(2)}`;
            document.getElementById('avgSpread').textContent = `${stats.avgSpread}%`;
        } catch (error) {
            console.error('Error loading rate stats:', error);
        }
    }

    // Update displayRates method
    displayRates(rates) {
        const tbody = document.getElementById('ratesTable');
        tbody.innerHTML = rates.map(rate => {
            const spread = rate.spread || ((rate.buyRate - rate.sellRate) / rate.marketPrice * 100).toFixed(2);
            const statusBadge = rate.active ?
                '<span class="badge bg-success">Active</span>' :
                '<span class="badge bg-secondary">Inactive</span>';
            
            return `
                <tr>
                    <td>
                        <div class="d-flex align-items-center">
                            <div class="crypto-icon me-2">
                                <i class="bi bi-currency-${rate.symbol.toLowerCase()} text-warning"></i>
                            </div>
                            <span class="text-light">${rate.name}</span>
                        </div>
                    </td>
                    <td><span class="badge bg-secondary">${rate.symbol}</span></td>
                    <td class="text-light">$${rate.marketPrice.toLocaleString()}</td>
                    <td class="text-success">$${rate.buyRate.toLocaleString()}</td>
                    <td class="text-danger">$${rate.sellRate.toLocaleString()}</td>
                    <td><span class="badge bg-info">${spread}%</span></td>
                    <td>${statusBadge}</td>
                    <td class="text-muted">${new Date(rate.lastUpdated).toLocaleString()}</td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary me-1" onclick="adminDashboard.editRate('${rate._id}')">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-${rate.active ? 'warning' : 'success'}" onclick="adminDashboard.toggleRateStatus('${rate._id}')">
                            <i class="bi bi-${rate.active ? 'pause' : 'play'}"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger" onclick="adminDashboard.deleteRate('${rate._id}')">
                            <i class="bi bi-trash"></i>
                        </button>
                    </td>
                </tr>
            `;
        }).join('');
    }

    // Update saveCryptocurrency method
    async saveCryptocurrency() {
        try {
            const formData = {
                name: document.getElementById('cryptoName').value,
                symbol: document.getElementById('cryptoSymbol').value,
                marketPrice: parseFloat(document.getElementById('marketPrice').value),
                buyRate: parseFloat(document.getElementById('buyRate').value),
                sellRate: parseFloat(document.getElementById('sellRate').value),
                active: document.getElementById('cryptoActive').checked
            };
            
            const response = await fetch(`${this.apiUrl}/admin/rates`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.showToast('Cryptocurrency added successfully!', 'success');
                document.getElementById('addCryptoForm').reset();
                bootstrap.Modal.getInstance(document.getElementById('addCryptoModal')).hide();
                this.loadRates();
            } else {
                this.showToast(result.message || 'Failed to add cryptocurrency', 'error');
            }
        } catch (error) {
            console.error('Error saving cryptocurrency:', error);
            this.showToast('Failed to add cryptocurrency', 'error');
        }
    }

    // Update editRate method
    async editRate(rateId) {
        try {
            const response = await fetch(`${this.apiUrl}/admin/rates`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            const result = await response.json();
            const rate = result.data.rates.find(r => r._id === rateId);
            
            if (rate) {
                document.getElementById('editCryptoId').value = rate._id;
                document.getElementById('editCryptoName').value = rate.name;
                document.getElementById('editMarketPrice').value = rate.marketPrice;
                document.getElementById('editBuyRate').value = rate.buyRate;
                document.getElementById('editSellRate').value = rate.sellRate;
                document.getElementById('editCryptoActive').checked = rate.active;
                
                new bootstrap.Modal(document.getElementById('editRateModal')).show();
            }
        } catch (error) {
            console.error('Error loading rate for edit:', error);
            this.showToast('Failed to load rate data', 'error');
        }
    }

    // Update updateRate method
    async updateRate() {
        try {
            const rateId = document.getElementById('editCryptoId').value;
            const formData = {
                marketPrice: parseFloat(document.getElementById('editMarketPrice').value),
                buyRate: parseFloat(document.getElementById('editBuyRate').value),
                sellRate: parseFloat(document.getElementById('editSellRate').value),
                active: document.getElementById('editCryptoActive').checked
            };
            
            const response = await fetch(`${this.apiUrl}/admin/rates/${rateId}`, {
                method: 'PUT',
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.showToast('Rate updated successfully!', 'success');
                bootstrap.Modal.getInstance(document.getElementById('editRateModal')).hide();
                this.loadRates();
            } else {
                this.showToast(result.message || 'Failed to update rate', 'error');
            }
        } catch (error) {
            console.error('Error updating rate:', error);
            this.showToast('Failed to update rate', 'error');
        }
    }

    // Update toggleRateStatus method
    async toggleRateStatus(rateId) {
        try {
            const response = await fetch(`${this.apiUrl}/admin/rates/${rateId}/toggle`, {
                method: 'PATCH',
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.showToast(result.message, 'success');
                this.loadRates();
            } else {
                this.showToast(result.message || 'Failed to update status', 'error');
            }
        } catch (error) {
            console.error('Error toggling rate status:', error);
            this.showToast('Failed to update status', 'error');
        }
    }

    // Update deleteRate method
    async deleteRate(rateId) {
        if (confirm('Are you sure you want to delete this cryptocurrency rate?')) {
            try {
                const response = await fetch(`${this.apiUrl}/admin/rates/${rateId}`, {
                    method: 'DELETE',
                    headers: {
                        'Authorization': `Bearer ${this.token}`,
                        'Content-Type': 'application/json'
                    }
                });
                
                const result = await response.json();
                
                if (result.success) {
                    this.showToast('Cryptocurrency rate deleted!', 'success');
                    this.loadRates();
                } else {
                    this.showToast(result.message || 'Failed to delete rate', 'error');
                }
            } catch (error) {
                console.error('Error deleting rate:', error);
                this.showToast('Failed to delete rate', 'error');
            }
        }
    }

    showToast(message, type = 'info') {
        // Simple toast implementation
        const toast = document.createElement('div');
        toast.className = `alert alert-${type === 'error' ? 'danger' : type === 'success' ? 'success' : 'info'} position-fixed`;
        toast.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
        toast.textContent = message;
        document.body.appendChild(toast);
        
        setTimeout(() => {
            toast.remove();
        }, 3000);
    }

    // Placeholder methods for other pages
    async loadDashboardData() {
        // Dashboard data loading logic
        console.log('Loading dashboard data...');
    }

    // User Management Functions
    async loadUsers() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/users`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch users');
            }
            
            const result = await response.json();
            const users = result.data.users;
            
            // Load user statistics
            await this.loadUserStats();
            
            this.displayUsers(users);
            this.setupUserEventListeners();
        } catch (error) {
            console.error('Error loading users:', error);
            this.showToast('Failed to load users', 'error');
        }
    }

    async loadUserStats() {
        try {
            const response = await fetch(`${this.apiUrl}/admin/stats`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch user stats');
            }
            
            const result = await response.json();
            const stats = result.data;
            
            document.getElementById('totalUsers').textContent = stats.totalUsers;
            document.getElementById('activeUsers').textContent = stats.totalUsers; // You can modify this based on your stats
            document.getElementById('verifiedUsers').textContent = Math.floor(stats.totalUsers * 0.8); // Example calculation
            document.getElementById('newUsers').textContent = stats.userChange || 0;
        } catch (error) {
            console.error('Error loading user stats:', error);
        }
    }

    displayUsers(users) {
        const tbody = document.getElementById('usersTable');
        tbody.innerHTML = users.map(user => {
            const statusBadge = user.status === 'active' ? 
                '<span class="badge bg-success">Active</span>' :
                user.status === 'suspended' ?
                '<span class="badge bg-danger">Suspended</span>' :
                '<span class="badge bg-secondary">Inactive</span>';
            
            const verificationBadge = user.isEmailVerified ?
                '<span class="badge bg-success">Verified</span>' :
                '<span class="badge bg-warning">Unverified</span>';
            
            const roleBadge = user.role === 'admin' ?
                '<span class="badge bg-primary">Admin</span>' :
                '<span class="badge bg-info">User</span>';
            
            return `
                <tr>
                    <td>
                        <input class="form-check-input" type="checkbox" value="${user._id}">
                    </td>
                    <td>
                        <div class="d-flex align-items-center">
                            <div class="avatar-sm bg-primary rounded-circle d-flex align-items-center justify-content-center me-2">
                                <span class="text-white">${user.firstName?.charAt(0) || 'U'}${user.lastName?.charAt(0) || ''}</span>
                            </div>
                            <div>
                                <div class="text-light">${user.firstName || ''} ${user.lastName || ''}</div>
                                <small class="text-muted">ID: ${user._id.slice(-6)}</small>
                            </div>
                        </div>
                    </td>
                    <td class="text-light">${user.email}</td>
                    <td class="text-light">${user.phone || 'N/A'}</td>
                    <td>${statusBadge}</td>
                    <td>${verificationBadge}</td>
                    <td>${roleBadge}</td>
                    <td class="text-muted">${new Date(user.createdAt).toLocaleDateString()}</td>
                    <td class="text-muted">${user.lastLogin ? new Date(user.lastLogin).toLocaleDateString() : 'Never'}</td>
                    <td>
                        <div class="btn-group" role="group">
                            <button class="btn btn-sm btn-outline-primary" onclick="adminDashboard.editUser('${user._id}')" title="Edit">
                                <i class="bi bi-pencil"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-info" onclick="adminDashboard.viewUser('${user._id}')" title="View">
                                <i class="bi bi-eye"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-${user.status === 'active' ? 'warning' : 'success'}" onclick="adminDashboard.toggleUserStatus('${user._id}')" title="${user.status === 'active' ? 'Suspend' : 'Activate'}">
                                <i class="bi bi-${user.status === 'active' ? 'pause' : 'play'}"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-danger" onclick="adminDashboard.deleteUser('${user._id}')" title="Delete">
                                <i class="bi bi-trash"></i>
                            </button>
                        </div>
                    </td>
                </tr>
            `;
        }).join('');
        
        document.getElementById('userCount').textContent = `Showing ${users.length} users`;
    }

    setupUserEventListeners() {
        // Refresh users button
        const refreshBtn = document.getElementById('refreshUsersBtn');
        if (refreshBtn) {
            refreshBtn.addEventListener('click', () => {
                this.loadUsers();
                this.showToast('Users refreshed successfully!', 'success');
            });
        }
        
        // Apply filters button
        const applyFiltersBtn = document.getElementById('applyFilters');
        if (applyFiltersBtn) {
            applyFiltersBtn.addEventListener('click', () => {
                this.applyUserFilters();
            });
        }
        
        // Clear filters button
        const clearFiltersBtn = document.getElementById('clearFilters');
        if (clearFiltersBtn) {
            clearFiltersBtn.addEventListener('click', () => {
                this.clearUserFilters();
            });
        }
    }

    async saveUser() {
        try {
            const formData = {
                firstName: document.getElementById('firstName').value,
                lastName: document.getElementById('lastName').value,
                email: document.getElementById('userEmail').value,
                phone: document.getElementById('userPhone').value,
                password: document.getElementById('userPassword').value,
                role: document.getElementById('userRole').value,
                isEmailVerified: document.getElementById('emailVerified').checked,
                isPhoneVerified: document.getElementById('phoneVerified').checked,
                status: document.getElementById('userActive').checked ? 'active' : 'inactive'
            };
            
            const response = await fetch(`${this.apiUrl}/admin/users`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.showToast('User created successfully!', 'success');
                document.getElementById('addUserForm').reset();
                bootstrap.Modal.getInstance(document.getElementById('addUserModal')).hide();
                this.loadUsers();
            } else {
                this.showToast(result.message || 'Failed to create user', 'error');
            }
        } catch (error) {
            console.error('Error saving user:', error);
            this.showToast('Failed to create user', 'error');
        }
    }

    async editUser(userId) {
        try {
            const response = await fetch(`${this.apiUrl}/admin/users`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            const result = await response.json();
            const user = result.data.users.find(u => u._id === userId);
            
            if (user) {
                document.getElementById('editUserId').value = user._id;
                document.getElementById('editFirstName').value = user.firstName || '';
                document.getElementById('editLastName').value = user.lastName || '';
                document.getElementById('editUserEmail').value = user.email;
                document.getElementById('editUserPhone').value = user.phone || '';
                document.getElementById('editUserStatus').value = user.status;
                document.getElementById('editUserRole').value = user.role;
                document.getElementById('editEmailVerified').checked = user.isEmailVerified;
                document.getElementById('editPhoneVerified').checked = user.isPhoneVerified;
                
                new bootstrap.Modal(document.getElementById('editUserModal')).show();
            }
        } catch (error) {
            console.error('Error loading user for edit:', error);
            this.showToast('Failed to load user data', 'error');
        }
    }

    async updateUser() {
        try {
            const userId = document.getElementById('editUserId').value;
            const formData = {
                firstName: document.getElementById('editFirstName').value,
                lastName: document.getElementById('editLastName').value,
                email: document.getElementById('editUserEmail').value,
                phone: document.getElementById('editUserPhone').value,
                status: document.getElementById('editUserStatus').value,
                role: document.getElementById('editUserRole').value,
                isEmailVerified: document.getElementById('editEmailVerified').checked,
                isPhoneVerified: document.getElementById('editPhoneVerified').checked
            };
            
            const response = await fetch(`${this.apiUrl}/admin/users/${userId}`, {
                method: 'PUT',
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.showToast('User updated successfully!', 'success');
                bootstrap.Modal.getInstance(document.getElementById('editUserModal')).hide();
                this.loadUsers();
            } else {
                this.showToast(result.message || 'Failed to update user', 'error');
            }
        } catch (error) {
            console.error('Error updating user:', error);
            this.showToast('Failed to update user', 'error');
        }
    }

    async toggleUserStatus(userId) {
        try {
            const response = await fetch(`${this.apiUrl}/admin/users/${userId}/toggle-status`, {
                method: 'PATCH',
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.showToast(result.message, 'success');
                this.loadUsers();
            } else {
                this.showToast(result.message || 'Failed to update user status', 'error');
            }
        } catch (error) {
            console.error('Error toggling user status:', error);
            this.showToast('Failed to update user status', 'error');
        }
    }

    async deleteUser(userId) {
        if (confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
            try {
                const response = await fetch(`${this.apiUrl}/admin/users/${userId}`, {
                    method: 'DELETE',
                    headers: {
                        'Authorization': `Bearer ${this.token}`,
                        'Content-Type': 'application/json'
                    }
                });
                
                const result = await response.json();
                
                if (result.success) {
                    this.showToast('User deleted successfully!', 'success');
                    this.loadUsers();
                } else {
                    this.showToast(result.message || 'Failed to delete user', 'error');
                }
            } catch (error) {
                console.error('Error deleting user:', error);
                this.showToast('Failed to delete user', 'error');
            }
        }
    }

    viewUser(userId) {
        // Implement user details view
        console.log('View user:', userId);
        this.showToast('User details view - Coming soon!', 'info');
    }

    applyUserFilters() {
        // Implement filter logic
        console.log('Apply user filters');
        this.loadUsers(); // For now, just reload
    }

    clearUserFilters() {
        document.getElementById('userSearch').value = '';
        document.getElementById('statusFilter').value = 'all';
        document.getElementById('verificationFilter').value = 'all';
        document.getElementById('roleFilter').value = 'all';
        this.loadUsers();
    }

    // Transaction Management Functions
    async loadTransactions() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/transactions`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch transactions');
            }
            
            const result = await response.json();
            this.displayTransactions(result.data.transactions);
        } catch (error) {
            console.error('Error loading transactions:', error);
            this.showToast('Failed to load transactions', 'error');
        }
    }

    async loadOrders() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/orders`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch orders');
            }
            
            const result = await response.json();
            this.displayOrders(result.data.orders);
        } catch (error) {
            console.error('Error loading orders:', error);
            this.showToast('Failed to load orders', 'error');
        }
    }

    async loadAnalytics() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/analytics`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch analytics');
            }
            
            const result = await response.json();
            this.displayAnalytics(result.data);
        } catch (error) {
            console.error('Error loading analytics:', error);
            this.showToast('Failed to load analytics', 'error');
        }
    }

    async loadSettings() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/settings`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch settings');
            }
            
            const result = await response.json();
            this.populateSettings(result.data);
        } catch (error) {
            console.error('Error loading settings:', error);
            this.showToast('Failed to load settings', 'error');
        }
    }

    displayTransactions(transactions) {
        const tbody = document.getElementById('transactionsTable');
        if (!tbody) return;
        
        tbody.innerHTML = transactions.map(tx => `
            <tr>
                <td><code>${tx._id.slice(-8)}</code></td>
                <td>${tx.userId?.email || 'N/A'}</td>
                <td><span class="badge bg-info">${tx.type}</span></td>
                <td class="text-light">$${tx.amount.toLocaleString()}</td>
                <td><span class="badge bg-secondary">${tx.currency}</span></td>
                <td><span class="badge bg-${tx.status === 'completed' ? 'success' : tx.status === 'pending' ? 'warning' : 'danger'}">${tx.status}</span></td>
                <td class="text-muted">${new Date(tx.createdAt).toLocaleString()}</td>
                <td>
                    <button class="btn btn-sm btn-outline-primary" onclick="adminDashboard.viewTransaction('${tx._id}')">
                        <i class="bi bi-eye"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    }

    displayOrders(orders) {
        const tbody = document.getElementById('ordersTable');
        if (!tbody) return;
        
        tbody.innerHTML = orders.map(order => `
            <tr>
                <td><code>${order._id.slice(-8)}</code></td>
                <td>${order.userId?.email || 'N/A'}</td>
                <td><span class="badge bg-secondary">${order.pair}</span></td>
                <td><span class="badge bg-${order.type === 'buy' ? 'success' : 'danger'}">${order.type}</span></td>
                <td class="text-light">${order.amount}</td>
                <td class="text-light">$${order.price.toLocaleString()}</td>
                <td><span class="badge bg-${order.status === 'filled' ? 'success' : order.status === 'pending' ? 'warning' : 'danger'}">${order.status}</span></td>
                <td class="text-muted">${new Date(order.createdAt).toLocaleString()}</td>
                <td>
                    <button class="btn btn-sm btn-outline-primary" onclick="adminDashboard.viewOrder('${order._id}')">
                        <i class="bi bi-eye"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    }

    displayAnalytics(data) {
        // Update analytics cards
        if (document.getElementById('totalRevenue')) {
            document.getElementById('totalRevenue').textContent = `$${data.revenue?.toLocaleString() || 0}`;
        }
        // Add more analytics display logic here
    }

    populateSettings(settings) {
        // Populate settings form fields
        if (document.getElementById('platformName')) {
            document.getElementById('platformName').value = settings.platformName || 'RDX Exchange';
        }
        // Add more settings population logic here
    }

    // Chart initialization method
    initCharts() {
        // Chart initialization logic will go here
        console.log('Charts initialized');
    }

    // Notification Management Functions
    async loadNotifications() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/notifications`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch notifications');
            }
            
            const result = await response.json();
            const notifications = result.data.notifications;
            
            // Load notification statistics
            await this.loadNotificationStats();
            
            this.displayNotifications(notifications);
            this.setupNotificationEventListeners();
        } catch (error) {
            console.error('Error loading notifications:', error);
            this.showToast('Failed to load notifications', 'error');
        }
    }

    async loadNotificationStats() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/notifications/stats`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch notification stats');
            }
            
            const result = await response.json();
            const stats = result.data;
            
            document.getElementById('totalNotifications').textContent = stats.total || 0;
            document.getElementById('deliveredNotifications').textContent = stats.delivered || 0;
            document.getElementById('openedNotifications').textContent = stats.opened || 0;
            document.getElementById('openRate').textContent = `${stats.openRate || 0}%`;
        } catch (error) {
            console.error('Error loading notification stats:', error);
        }
    }

    displayNotifications(notifications) {
        const tbody = document.getElementById('notificationsTable');
        if (!tbody) return;
        
        tbody.innerHTML = notifications.map(notification => {
            const statusBadge = notification.status === 'sent' ?
                '<span class="badge bg-success">Sent</span>' :
                notification.status === 'delivered' ?
                '<span class="badge bg-info">Delivered</span>' :
                notification.status === 'failed' ?
                '<span class="badge bg-danger">Failed</span>' :
                '<span class="badge bg-warning">Pending</span>';
            
            const typeBadge = {
                'general': '<span class="badge bg-secondary">General</span>',
                'promotional': '<span class="badge bg-primary">Promotional</span>',
                'security': '<span class="badge bg-danger">Security</span>',
                'system': '<span class="badge bg-info">System</span>'
            }[notification.type] || '<span class="badge bg-secondary">General</span>';
            
            return `
                <tr>
                    <td><code>${notification._id.slice(-8)}</code></td>
                    <td class="text-light">${notification.title}</td>
                    <td>${typeBadge}</td>
                    <td class="text-light">${notification.recipientCount || 0}</td>
                    <td class="text-light">${notification.sentCount || 0}</td>
                    <td class="text-light">${notification.deliveredCount || 0}</td>
                    <td class="text-light">${notification.openedCount || 0}</td>
                    <td>${statusBadge}</td>
                    <td class="text-muted">${new Date(notification.createdAt).toLocaleString()}</td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary me-1" onclick="adminDashboard.viewNotificationDetails('${notification._id}')">
                            <i class="bi bi-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-info" onclick="adminDashboard.resendNotification('${notification._id}')">
                            <i class="bi bi-arrow-repeat"></i>
                        </button>
                    </td>
                </tr>
            `;
        }).join('');
    }

    setupNotificationEventListeners() {
        // Target audience change handler
        const targetAudience = document.getElementById('targetAudience');
        const customSection = document.getElementById('customAudienceSection');
        
        if (targetAudience && customSection) {
            targetAudience.addEventListener('change', (e) => {
                if (e.target.value === 'custom') {
                    customSection.style.display = 'block';
                } else {
                    customSection.style.display = 'none';
                }
            });
        }
    }

    async sendNotification() {
        try {
            const formData = {
                title: document.getElementById('notificationTitle').value,
                message: document.getElementById('notificationMessage').value,
                type: document.getElementById('notificationType').value,
                targetAudience: document.getElementById('targetAudience').value,
                priority: document.getElementById('notificationPriority').value,
                actionUrl: document.getElementById('actionUrl').value,
                scheduleTime: document.getElementById('scheduleTime').value,
                sendEmail: document.getElementById('sendEmail').checked,
                customUserIds: document.getElementById('customUserIds').value
            };
            
            // Validation
            if (!formData.title || !formData.message || !formData.type || !formData.targetAudience) {
                this.showToast('Please fill in all required fields', 'error');
                return;
            }
            
            const response = await fetch(`${this.apiBaseUrl}/admin/notifications/send`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.showToast('Notification sent successfully!', 'success');
                document.getElementById('sendNotificationForm').reset();
                bootstrap.Modal.getInstance(document.getElementById('sendNotificationModal')).hide();
                this.loadNotifications();
            } else {
                this.showToast(result.message || 'Failed to send notification', 'error');
            }
        } catch (error) {
            console.error('Error sending notification:', error);
            this.showToast('Failed to send notification', 'error');
        }
    }

    async viewNotificationDetails(notificationId) {
        // Implement notification details view
        console.log('View notification details:', notificationId);
        this.showToast('Notification details view - Coming soon!', 'info');
    }

    async resendNotification(notificationId) {
        if (confirm('Are you sure you want to resend this notification?')) {
            try {
                const response = await fetch(`${this.apiBaseUrl}/admin/notifications/${notificationId}/resend`, {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${this.token}`,
                        'Content-Type': 'application/json'
                    }
                });
                
                const result = await response.json();
                
                if (result.success) {
                    this.showToast('Notification resent successfully!', 'success');
                    this.loadNotifications();
                } else {
                    this.showToast(result.message || 'Failed to resend notification', 'error');
                }
            } catch (error) {
                console.error('Error resending notification:', error);
                this.showToast('Failed to resend notification', 'error');
            }
        }
    }

    applyNotificationFilters() {
        // Implement filter logic
        console.log('Apply notification filters');
        this.loadNotifications(); // For now, just reload
    }

    clearNotificationFilters() {
        document.getElementById('notificationSearch').value = '';
        document.getElementById('statusFilter').value = 'all';
        document.getElementById('typeFilter').value = 'all';
        document.getElementById('dateFilter').value = '';
        this.loadNotifications();
    }
}

// Initialize the dashboard
let adminDashboard;
document.addEventListener('DOMContentLoaded', () => {
    adminDashboard = new AdminDashboard();
});