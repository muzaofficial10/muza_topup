import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/supabase_client.dart';
import 'services/auth_service.dart';
import 'services/order_service.dart';
import 'services/storage_service.dart';
import 'services/product_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/topup/pubg_topup_screen.dart';
import 'screens/topup/efootball_topup_screen.dart';
import 'screens/orders/order_history_screen.dart';
import 'screens/support/faq_screen.dart';
import 'screens/legal/terms_screen.dart';
import 'screens/legal/privacy_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/admin_products_screen.dart';
import 'screens/admin/admin_reports_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const MuzaApp());
}

class MuzaApp extends StatelessWidget {
  const MuzaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<OrderService>(create: (_) => OrderService()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<ProductService>(create: (_) => ProductService()),
      ],
      child: MaterialApp(
        title: 'Muza Top-Up',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/home': (_) => const HomeScreen(),
          '/topup/pubg': (_) => const PubgTopupScreen(),
          '/topup/efootball': (_) => const EfootballTopupScreen(),
          '/orders': (_) => const OrderHistoryScreen(),
          '/faq': (_) => const FaqScreen(),
          '/terms': (_) => const TermsScreen(),
          '/privacy': (_) => const PrivacyScreen(),
          '/admin/login': (_) => const AdminLoginScreen(),
          '/admin/dashboard': (_) => const AdminDashboardScreen(),
          '/admin/orders': (_) => const AdminOrdersScreen(),
          '/admin/products': (_) => const AdminProductsScreen(),
          '/admin/reports': (_) => const AdminReportsScreen(),
        },
      ),
    );
  }
}
