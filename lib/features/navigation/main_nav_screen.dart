import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../alarms/views/alarms_list_screen.dart';
import '../ambient_wake/views/nightstand_screen.dart';
import '../settings/views/settings_screen.dart';
import '../sync_pods/views/pod_dashboard_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AlarmsListScreen(),
    PodDashboardScreen(),
    NightstandScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentIndex == 2 ? const Color(0xFF07080A) : AppColors.linenBackground,
      body: Stack(
        children: [
          // Active Screen
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Floating Capsule Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: _buildFloatingCapsuleBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCapsuleBar() {
    final isDark = _currentIndex == 2;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF16181D).withValues(alpha: 0.92)
            : AppColors.linenSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? const Color(0xFF282C34) : AppColors.linenSurfaceBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, LucideIcons.alarmClock, 'Alarms'),
          _buildNavItem(1, LucideIcons.sprout, 'Garden'),
          _buildNavItem(2, LucideIcons.moon, 'Nightstand'),
          _buildNavItem(3, LucideIcons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = _currentIndex == 2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFFFFB74D).withValues(alpha: 0.2) : AppColors.terracotta.withValues(alpha: 0.15))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? (isDark ? const Color(0xFFFFB74D) : AppColors.terracotta)
                  : (isDark ? Colors.white54 : AppColors.linenTextSecondary),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isDark ? const Color(0xFFFFB74D) : AppColors.terracotta,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
