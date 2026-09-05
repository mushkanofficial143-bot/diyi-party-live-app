import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _signUpWithPhone() async {
    final authProvider = context.read<AuthProvider>();
    setState(() => _isLoading = true);

    final success = await authProvider.signUpWithPhone(
      _phoneController.text,
      (verificationId) {
        if (mounted) {
          Navigator.pushNamed(context, AppRouter.phoneOtp, arguments: verificationId);
        }
      },
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${authProvider.error}')),
        );
      }
    }
  }

  void _signUpWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    setState(() => _isLoading = true);

    final success = await authProvider.signUpWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${authProvider.error}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004E89), Color(0xFF0F1419)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              Column(
                children: [
                  const Text(
                    'Diyo Party Live',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Join the ultimate live party experience',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '+1 (555) 000-0000',
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone, color: Color(0xFFFF6B35)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUpWithPhone,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Continue with Phone'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFF6B7280))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR', style: TextStyle(color: Color(0xFF9CA3AF))),
                        ),
                        Expanded(child: Divider(color: Color(0xFF6B7280))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _signUpWithGoogle,
                        child: const Text('Sign in with Google'),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'By continuing, you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
