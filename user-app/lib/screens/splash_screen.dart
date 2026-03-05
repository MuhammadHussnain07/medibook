import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
  }

  Future<void> _checkFirstSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenOnboarding') ?? false;

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (seen) {
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white.withAlpha(38),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Iconsax.hospital,
                size: 60,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'MediBook',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppTheme.white,
              ),
            ),
            Text(
              'Your Health, Our Priority',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.white.withAlpha(204),
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              color: AppTheme.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
