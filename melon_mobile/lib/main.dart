import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/wallet_screen.dart';
import 'presentation/screens/analytics_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/alerts_screen.dart';
import 'presentation/screens/challenges_screen.dart';
import 'presentation/screens/news_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/deposit_screen.dart';
import 'presentation/screens/withdraw_screen.dart';
import 'presentation/screens/notifications_screen.dart';
import 'presentation/screens/payment_methods_screen.dart';
import 'presentation/screens/risk_management_screen.dart';
import 'presentation/screens/strategy_config_screen.dart';
import 'presentation/screens/navigation_wrapper.dart';

void main() {
  runApp(const MelonApp());
}

class MelonApp extends StatelessWidget {
  const MelonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.instance.themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Melon Trading',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark, // Force dark mode for premium glassmorphic look
          initialRoute: '/',
          routes: {
            '/': (context) => const OnboardingScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/dashboard': (context) => const NavigationWrapper(),
            '/history': (context) => HistoryScreen(),
            '/wallet': (context) => WalletScreen(),
            '/analytics': (context) => AnalyticsScreen(),
            '/settings': (context) => SettingsScreen(),
            '/alerts': (context) => AlertsScreen(),
            '/challenges': (context) => ChallengesScreen(),
            '/news': (context) => NewsScreen(),
            '/profile': (context) => ProfileScreen(),
            '/deposit': (context) => DepositScreen(),
            '/withdraw': (context) => WithdrawScreen(),
            '/notifications': (context) => NotificationsScreen(),
            '/payment-methods': (context) => PaymentMethodsScreen(),
            '/risk-management': (context) => RiskManagementScreen(),
            '/strategy-config': (context) => StrategyConfigScreen(),
          },
        );
      },
    );
  }
}
