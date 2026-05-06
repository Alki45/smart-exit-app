import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Shared top app bar used across all main screens.
/// [rightSlot]: optional widget injected in the action area (e.g., timer for Quiz, avatar for Dashboard).
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? rightSlot;
  const AppTopBar({super.key, this.rightSlot});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.lOutlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.school_rounded, color: AppColors.lPrimary, size: 26),
            const SizedBox(width: 10),
            Text(
              'SmartExit',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.lPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            if (rightSlot != null) rightSlot!,
            if (rightSlot == null) ...[
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.lOnSurfaceVariant),
                onPressed: () {},
                splashRadius: 20,
              ),
              const SizedBox(width: 4),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final name = auth.currentUser?.fullName ?? 'Student';
                  final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                  
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.lPrimaryContainer,
                    child: Text(
                      initials.isEmpty ? 'S' : initials,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lOnPrimaryContainer,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
