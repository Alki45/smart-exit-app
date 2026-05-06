import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../progress/presentation/providers/progress_provider.dart';

/// Streak ring painted via CustomPainter.
class _StreakRing extends CustomPainter {
  final double progress;
  const _StreakRing({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const strokeW = 8.0;
    final radius = (size.width - strokeW) / 2;
    canvas.drawCircle(Offset(cx, cy), radius,
      Paint()..color = AppColors.lSurfaceContainer..strokeWidth = strokeW..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -1.5708, 2 * 3.14159 * progress, false,
      Paint()..color = AppColors.lSecondary..strokeWidth = strokeW..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_StreakRing old) => old.progress != progress;
}

class _DotRow extends StatelessWidget {
  final int active;
  const _DotRow({required this.active});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(7, (i) => Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 7,
        decoration: BoxDecoration(
          color: i < active ? AppColors.lSecondary : AppColors.lSurfaceContainer,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    )),
  );
}

/// 7-day streak ring card shown in the dashboard header row.
class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (_, progress, __) {
        final streak = progress.streak.clamp(0, 7);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lOutlineVariant),
            boxShadow: const [BoxShadow(color: Color(0x08002045), blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120, height: 120,
                child: CustomPaint(
                  painter: _StreakRing(progress: streak / 7),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.local_fire_department_rounded, color: AppColors.lSecondary, size: 30),
                    Text('$streak', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              Text('Day Streak', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
              Text('CURRENT CONSISTENCY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppColors.lOnSurfaceVariant)),
              const SizedBox(height: 12),
              _DotRow(active: streak),
            ],
          ),
        );
      },
    );
  }
}
