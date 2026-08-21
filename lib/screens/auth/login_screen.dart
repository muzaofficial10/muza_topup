import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthService>();
      await auth.signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.neonButtonGradient,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 34),
                  ),
                  const SizedBox(height: 24),
                  const Text('Welcome Back',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  const Text('Log in to top up your game instantly',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        if (_emailCtrl.text.isEmpty) return;
                        await context.read<AuthService>().resetPassword(_emailCtrl.text.trim());
                        if (!mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Password reset email sent')));
                      },
                      child: const Text('Forgot password?', style: TextStyle(color: AppColors.neonBlue)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(label: 'Log In', onPressed: _login, loading: _loading),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/signup'),
                      child: const Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: AppColors.textSecondary),
                          children: [
                            TextSpan(text: 'Sign Up', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/admin/login'),
                      child: const Text('Admin Login', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
