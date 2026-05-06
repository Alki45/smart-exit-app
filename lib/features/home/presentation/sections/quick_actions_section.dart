import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

/// Quick Actions section — Upload New Module + Previous Exams tiles.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionTile(
          icon: Icons.upload_file_rounded,
          iconBg: AppColors.lPrimaryFixed,
          iconColor: AppColors.lPrimary,
          title: 'Upload New Module',
          subtitle: 'Add PDF notes or blueprints to start practicing.',
          onTap: () => Navigator.pushNamed(context, AppRoutes.uploadBlueprint),
        ),
        const SizedBox(height: 14),
        _ActionTile(
          icon: Icons.history_edu_rounded,
          iconBg: AppColors.lSecondaryFixed,
          iconColor: AppColors.lSecondary,
          title: 'Previous Exams',
          subtitle: 'Review your past performance and errors.',
          onTap: () => Navigator.pushNamed(context, AppRoutes.pastAttempts),
        ),
        const SizedBox(height: 14),
        _ActionTile(
          icon: Icons.menu_book_rounded,
          iconBg: AppColors.lTertiaryFixed,
          iconColor: AppColors.lTertiary,
          title: 'Resume Reading',
          subtitle: 'Jump back to your last studied material.',
          onTap: () {
            // TODO: Route to last MaterialModel from StudySessionModel
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active reading session found.')));
          },
        ),
        const SizedBox(height: 14),
        _ActionTile(
          icon: Icons.pending_actions_rounded,
          iconBg: AppColors.lPrimaryFixedDim,
          iconColor: AppColors.lPrimary,
          title: 'Resume Quizzes',
          subtitle: 'Continue your incomplete exam attempts.',
          onTap: () {
            // Route to quizzes or show snackbar if empty
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No incomplete quizzes found.')));
          },
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lOutlineVariant),
          boxShadow: const [BoxShadow(color: Color(0x06002045), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: AppColors.lOnSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
