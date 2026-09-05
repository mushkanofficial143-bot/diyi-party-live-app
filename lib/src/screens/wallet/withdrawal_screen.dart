import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/auth_provider.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _amountController;
  late TextEditingController _accountController;
  String _selectedPaymentMethod = 'bank';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _amountController = TextEditingController();
    _accountController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _requestWithdrawal() async {
    if (_amountController.text.isEmpty || _accountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum withdrawal is 100 diamonds')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final walletProvider = context.read<WalletProvider>();

    if (authProvider.userModel == null) return;

    setState(() => _isProcessing = true);

    try {
      final success = await walletProvider.requestWithdrawal(
        authProvider.userModel!.userId,
        amount,
        _selectedPaymentMethod,
        _accountController.text,
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Withdrawal request submitted!'),
              backgroundColor: Color(0xFF27AE60),
            ),
          );
          _amountController.clear();
          _accountController.clear();
          _tabController.animateTo(1);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${walletProvider.error}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawal'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Request'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Request Tab
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Info
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1E25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2D3139)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${walletProvider.wallet?.diamondsBalance ?? 0} Diamonds',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Minimum withdrawal: 100 Diamonds',
                        style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),
                // Form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Withdrawal Amount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter amount',
                          suffixText: 'Diamonds',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Payment Method',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedPaymentMethod,
                        items: const [
                          DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                          DropdownMenuItem(value: 'wallet', child: Text('Digital Wallet')),
                          DropdownMenuItem(value: 'upi', child: Text('UPI')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedPaymentMethod = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Account Details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _accountController,
                        decoration: InputDecoration(
                          hintText: 'Enter your account number or details',
                          minLines: 3,
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _requestWithdrawal,
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Request Withdrawal'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // History Tab
          if (walletProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (walletProvider.withdrawals.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 48, color: Color(0xFF6B7280)),
                  const SizedBox(height: 16),
                  const Text(
                    'No withdrawal history',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: walletProvider.withdrawals.length,
              itemBuilder: (context, index) {
                final withdrawal = walletProvider.withdrawals[index];
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
                            '${withdrawal.amount} Diamonds',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(withdrawal.status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              withdrawal.status.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        withdrawal.paymentMethod.toUpperCase(),
                        style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${withdrawal.requestedAt.day}/${withdrawal.requestedAt.month}/${withdrawal.requestedAt.year}',
                        style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Color(0xFFF39C12);
      case 'approved':
        return Color(0xFF27AE60);
      case 'paid':
        return Color(0xFF0066CC);
      case 'rejected':
        return Color(0xFFE74C3C);
      default:
        return Color(0xFF6B7280);
    }
  }
}
