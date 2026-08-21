import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthService>();
      await auth.signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);

      // The is_admin check below is a UX gate only. Real protection comes
      // from RLS policies on admin-only tables/columns — a non-admin user
      // who bypasses this screen still cannot read/write admin data.
      final isAdmin = await auth.isCurrentUserAdmin();
      if (!isAdmin) {
        await auth.signOut();
        throw Exception('This account does not have admin access');
      }

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/admin/dashboard', (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.admin_panel_settings_rounded, size: 56, color: AppColors.gold),
              const SizedBox(height: 16),
              const Text('Admin Access', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Restricted area — authorized personnel only',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 28),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Admin Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 22),
              CustomButton(label: 'Login as Admin', onPressed: _login, loading: _loading, gold: true),
            ],
          ),
        ),
      ),
    );
  }
}
