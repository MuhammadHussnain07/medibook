import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

class OnboardingScreen extends HookWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageCtrl = usePageController();
    final currentPage = useState(0);

    const slides = [
      _OnboardingData(
        icon: Iconsax.user_octagon,
        title: 'Find Top Doctors',
        subtitle:
            'Browse hundreds of specialist doctors and find the best one for your health needs.',
        color: Color(0xFF0077B6),
      ),
      _OnboardingData(
        icon: Iconsax.calendar_tick,
        title: 'Easy Appointment',
        subtitle:
            'Book an appointment with your preferred doctor in just a few taps, anytime.',
        color: Color(0xFF00B4D8),
      ),
      _OnboardingData(
        icon: Iconsax.health,
        title: 'Stay Healthy',
        subtitle:
            'Track your appointments and get reminders so you never miss a medical visit.',
        color: Color(0xFF10B981),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('hasSeenOnboarding', true);
                    if (context.mounted) context.go('/login');
                  },
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageCtrl,
                onPageChanged: (i) => currentPage.value = i,
                itemCount: slides.length,
                itemBuilder: (_, i) => _OnboardingSlide(data: slides[i]),
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage.value == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage.value == i
                        ? AppTheme.primary
                        : AppTheme.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () async {
                  if (currentPage.value < slides.length - 1) {
                    pageCtrl.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('hasSeenOnboarding', true);
                    if (context.mounted) context.go('/login');
                  }
                },
                child: Text(
                  currentPage.value == slides.length - 1
                      ? 'Get Started'
                      : 'Next',
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: data.color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 80, color: data.color),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppTheme.textGrey,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
