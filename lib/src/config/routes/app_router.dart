import 'package:go_router/go_router.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/phone_otp_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/party_room/party_room_screen.dart';
import '../../screens/wallet/wallet_screen.dart';
import '../../screens/wallet/coin_recharge_screen.dart';
import '../../screens/wallet/withdrawal_screen.dart';
import '../../screens/admin/admin_dashboard.dart';

class AppRouter {
  static const String login = '/login';
  static const String phoneOtp = '/phone-otp';
  static const String home = '/';
  static const String profile = '/profile';
  static const String partyRoom = '/party-room';
  static const String wallet = '/wallet';
  static const String coinRecharge = '/coin-recharge';
  static const String withdrawal = '/withdrawal';
  static const String adminDashboard = '/admin';

  static final router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: phoneOtp,
        builder: (context, state) {
          final verificationId = state.extra as String?;
          return PhoneOtpScreen(verificationId: verificationId ?? '');
        },
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) {
          final userId = state.extra as String?;
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: partyRoom,
        builder: (context, state) {
          final roomId = state.extra as String?;
          return PartyRoomScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: wallet,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: coinRecharge,
        builder: (context, state) => const CoinRechargeScreen(),
      ),
      GoRoute(
        path: withdrawal,
        builder: (context, state) => const WithdrawalScreen(),
      ),
      GoRoute(
        path: adminDashboard,
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
  );
}
