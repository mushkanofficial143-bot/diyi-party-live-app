import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme/app_theme.dart';

class CoinRechargeScreen extends StatefulWidget {
  const CoinRechargeScreen({Key? key}) : super(key: key);

  @override
  State<CoinRechargeScreen> createState() => _CoinRechargeScreenState();
}

class _CoinRechargeScreenState extends State<CoinRechargeScreen> {
  final List<Map<String, dynamic>> _packages = [
    {'coins': 100, 'price': '\$0.99', 'bonus': 0},
    {'coins': 500, 'price': '\$4.99', 'bonus': 50},
    {'coins': 1000, 'price': '\$9.99', 'bonus': 200},
    {'coins': 5000, 'price': '\$39.99', 'bonus': 1000},
    {'coins': 10000, 'price': '\$79.99', 'bonus': 2500},
    {'coins': 50000, 'price': '\$299.99', 'bonus': 15000},
  ];

  int? _selectedPackage;
  bool _isProcessing = false;

  void _purchaseCoins(int packageIndex) async {
    setState(() => _isProcessing = true);

    // TODO: Implement Google Play Billing
    // For now, show success message
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coins purchased successfully!'),
          backgroundColor: Color(0xFF27AE60),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharge Coins'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Current Balance
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1E25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2D3139)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${authProvider.userModel?.coinsBalance ?? 0} Coins',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.monetization_on, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Packages Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Select Package',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                final package = _packages[index];
                final isSelected = _selectedPackage == index;

                return GestureDetector(
                  onTap: () => setState(() => _selectedPackage = index),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : const Color(0xFF2D3139),
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected ? Color(0xFF2D3139) : const Color(0xFF1A1E25),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '${package['coins']}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const Text('Coins', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                                ],
                              ),
                              if (package['bonus'] > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF39C12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '+${package['bonus']} Bonus',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              Text(
                                package['price'],
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 16, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Purchase Button
            if (_selectedPackage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _purchaseCoins(_selectedPackage!),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Purchase ${_packages[_selectedPackage!]['price']}'),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            // Terms
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Secure payment via Google Play Billing. Terms & refund policy apply.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: const Color(0xFF9CA3AF)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
