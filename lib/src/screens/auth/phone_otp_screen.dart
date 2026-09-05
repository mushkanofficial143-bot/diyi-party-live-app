import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes/app_router.dart';

class PhoneOtpScreen extends StatefulWidget {
  final String verificationId;

  const PhoneOtpScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  late List<TextEditingController> _otpControllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    setState(() => _isLoading = true);

    final success = await authProvider.verifyPhoneOTP(widget.verificationId, otp);

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
      appBar: AppBar(
        title: const Text('Verify OTP'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the 6-digit code sent to your phone',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _otpControllers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Verify OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
