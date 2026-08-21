import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/supabase_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final route = SupabaseService.isLoggedIn ? '/home' : '/login';
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Center(
          child: FadeTransition(
            opacity: _controller,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.neonButtonGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonBlue.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'MUZA TOP-UP',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PUBG UC · eFootball Coins',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
