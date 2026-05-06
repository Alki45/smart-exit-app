import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

/// Shared bottom navigation bar with 4 tabs.
/// [currentIndex]: 0=Dashboard, 1=Lab, 2=Stats, 3=Profile
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  static const _tabs = [
    _NavTab(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard', route: AppRoutes.home),
    _NavTab(icon: Icons.folder_open_outlined, activeIcon: Icons.folder_open, label: 'Lab', route: AppRoutes.lab),
    _NavTab(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Stats', route: AppRoutes.stats),
    _NavTab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', route: AppRoutes.editProfile),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.lOutlineVariant)),
        boxShadow: [BoxShadow(color: Color(0x0D1A365D), blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) => _buildTab(context, i)),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final tab = _tabs[index];
    final isActive = index == currentIndex;
    return InkWell(
      onTap: () {
        if (!isActive) Navigator.pushReplacementNamed(context, tab.route);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.lPrimaryFixed.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? tab.activeIcon : tab.icon,
              color: isActive ? AppColors.lPrimary : AppColors.lOnSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.lPrimary : AppColors.lOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavTab({required this.icon, required this.activeIcon, required this.label, required this.route});
}
