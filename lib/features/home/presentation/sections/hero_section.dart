import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Hero welcome card — left panel of the dashboard header row.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lOutlineVariant),
        boxShadow: const [BoxShadow(color: Color(0x08002045), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<AuthProvider>(
            builder: (_, auth, __) {
              final name = auth.currentUser?.fullName.split(' ').first ?? 'Student';
              return Text(
                'Welcome back, $name!',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.lPrimary, height: 1.2),
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (_, auth, __) {
              final track = auth.currentUser?.department ?? 'your department';
              return Text(
                'Your path to academic excellence continues in your $track programme.',
                style: GoogleFonts.inter(fontSize: 16, color: AppColors.lOnSurfaceVariant, height: 1.6),
              );
            },
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.lab),
            icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
            label: Text('Go to Lab', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
