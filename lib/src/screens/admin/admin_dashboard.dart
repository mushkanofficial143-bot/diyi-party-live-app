import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isLoggedIn || authProvider.userModel?.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: const Center(
          child: Text('Unauthorized Access'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Dashboard Stats
          Container(
            color: const Color(0xFF1A1E25),
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard('Total Users', '1,245', const Color(0xFF004E89)),
                  const SizedBox(width: 12),
                  _buildStatCard('Live Rooms', '48', const Color(0xFFFF6B35)),
                  const SizedBox(width: 12),
                  _buildStatCard('Revenue', '\$12.5K', const Color(0xFF27AE60)),
                  const SizedBox(width: 12),
                  _buildStatCard('Withdrawals', '34', const Color(0xFFF39C12)),
                ],
              ),
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFFF6B35),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFFFF6B35),
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Withdrawals'),
              Tab(text: 'Content'),
              Tab(text: 'Reports'),
            ],
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildWithdrawalsTab(),
                _buildContentTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search/Filter
        TextField(
          decoration: InputDecoration(
            hintText: 'Search users...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // User List
        ..._buildUserList(),
      ],
    );
  }

  List<Widget> _buildUserList() {
    final users = [
      {'name': 'John Doe', 'id': 'user_001', 'status': 'active', 'coins': 5000, 'diamonds': 250},
      {'name': 'Jane Smith', 'id': 'user_002', 'status': 'active', 'coins': 3200, 'diamonds': 500},
      {'name': 'Mike Johnson', 'id': 'user_003', 'status': 'banned', 'coins': 0, 'diamonds': 0},
      {'name': 'Sarah Wilson', 'id': 'user_004', 'status': 'active', 'coins': 8500, 'diamonds': 1200},
      {'name': 'Tom Brown', 'id': 'user_005', 'status': 'inactive', 'coins': 2100, 'diamonds': 100},
    ];

    return users.map((user) {
      final status = user['status'] as String;
      final statusColor = status == 'active'
          ? const Color(0xFF27AE60)
          : status == 'banned'
              ? const Color(0xFFE74C3C)
              : const Color(0xFF6B7280);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2D3139)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['id'] as String,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    border: Border.all(color: statusColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Coins', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                    Text(
                      '${user['coins']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B35)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Diamonds', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                    Text(
                      '${user['diamonds']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0066CC)),
                    ),
                  ],
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(child: Text('View Profile')),
                    const PopupMenuItem(child: Text('Edit Balance')),
                    const PopupMenuItem(child: Text('Send Message')),
                    if (status != 'banned')
                      const PopupMenuItem(child: Text('Ban User'))
                    else
                      const PopupMenuItem(child: Text('Unban User')),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildWithdrawalsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Filter
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                value: 'pending',
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'paid', child: Text('Paid')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                ],
                onChanged: (value) {},
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Withdrawals List
        ..._buildWithdrawalsList(),
      ],
    );
  }

  List<Widget> _buildWithdrawalsList() {
    final withdrawals = [
      {'user': 'John Doe', 'amount': 500, 'method': 'Bank', 'status': 'pending', 'date': '2026-09-05'},
      {'user': 'Jane Smith', 'amount': 1000, 'method': 'UPI', 'status': 'approved', 'date': '2026-09-04'},
      {'user': 'Sarah Wilson', 'amount': 2000, 'method': 'Wallet', 'status': 'paid', 'date': '2026-09-03'},
      {'user': 'Mike Johnson', 'amount': 750, 'method': 'Bank', 'status': 'rejected', 'date': '2026-09-02'},
      {'user': 'Tom Brown', 'amount': 300, 'method': 'UPI', 'status': 'pending', 'date': '2026-09-01'},
    ];

    return withdrawals.map((withdrawal) {
      final status = withdrawal['status'] as String;
      final statusColor = status == 'pending'
          ? const Color(0xFFF39C12)
          : status == 'approved'
              ? const Color(0xFF0066CC)
              : status == 'paid'
                  ? const Color(0xFF27AE60)
                  : const Color(0xFFE74C3C);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2D3139)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      withdrawal['user'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${withdrawal['date']}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${withdrawal['amount']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0066CC),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${withdrawal['method']}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    border: Border.all(color: statusColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
                if (status == 'pending')
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Withdrawal approved')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Approve', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Withdrawal rejected')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE74C3C),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Reject', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildContentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Active Rooms',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._buildRoomsList(),
      ],
    );
  }

  List<Widget> _buildRoomsList() {
    final rooms = [
      {'title': 'Music Night', 'host': 'John Doe', 'viewers': 245, 'rating': 4.8},
      {'title': 'Comedy Show', 'host': 'Jane Smith', 'viewers': 512, 'rating': 4.5},
      {'title': 'Gaming Session', 'host': 'Mike Johnson', 'viewers': 128, 'rating': 4.9},
      {'title': 'Cooking Show', 'host': 'Sarah Wilson', 'viewers': 89, 'rating': 4.6},
    ];

    return rooms.map((room) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2D3139)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Host: ${room['host']}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people, size: 14, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text('${room['viewers']}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFF39C12)),
                    const SizedBox(width: 4),
                    Text('${room['rating']}'),
                  ],
                ),
              ],
            ),
            PopupMenuButton(
              itemBuilder: (context) => const [
                PopupMenuItem(child: Text('View Details')),
                PopupMenuItem(child: Text('Send Warning')),
                PopupMenuItem(child: Text('Suspend Room')),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'User Reports',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._buildReportsList(),
      ],
    );
  }

  List<Widget> _buildReportsList() {
    final reports = [
      {'title': 'Inappropriate Content', 'reporter': 'User_123', 'reported': 'Mike Johnson', 'status': 'new'},
      {'title': 'Harassment', 'reporter': 'User_456', 'reported': 'Tom Brown', 'status': 'investigating'},
      {'title': 'Spam', 'reporter': 'User_789', 'reported': 'Bot_001', 'status': 'resolved'},
      {'title': 'Copyright Violation', 'reporter': 'User_012', 'reported': 'John Doe', 'status': 'new'},
    ];

    return reports.map((report) {
      final status = report['status'] as String;
      final statusColor = status == 'new'
          ? const Color(0xFFE74C3C)
          : status == 'investigating'
              ? const Color(0xFFF39C12)
              : const Color(0xFF27AE60);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2D3139)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  report['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    border: Border.all(color: statusColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reported By',
                      style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                    ),
                    Text(
                      report['reporter'] as String,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reported User',
                      style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                    ),
                    Text(
                      report['reported'] as String,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report details opened')),
                    );
                  },
                  child: const Text('Review'),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}
