import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import '../../../quizzes/presentation/providers/quiz_provider.dart';

/// Circular readiness score card using CustomPainter conic arc.
class ReadinessScoreSection extends StatelessWidget {
  const ReadinessScoreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (_, progress, __) {
        final score = (progress.averageScore / 100).clamp(0.0, 1.0);
        final pct = '${progress.averageScore.round()}%';
        
        return Consumer<QuizProvider>(
          builder: (context, quizProvider, _) {
            final stats = quizProvider.globalTopicPerformance;
            String recommendation = "You're making steady progress. Complete more quizzes to get personalized insights.";
            
            if (stats.isNotEmpty) {
              final weakest = stats.entries.toList()
                ..sort((a, b) => (a.value['correct']! / a.value['total']!).compareTo(b.value['correct']! / b.value['total']!));
              final topicName = weakest.first.key;
              recommendation = "You're making steady progress. Focus on $topicName to hit your 80% goal.";
            }

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.lOutlineVariant),
                boxShadow: const [BoxShadow(color: Color(0x08002045), blurRadius: 12, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Text('Readiness Score', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CustomPaint(
                      painter: _ConicRingPainter(progress: score),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(pct, style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
                          Text('READY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppColors.lOnSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    recommendation,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.lOnSurfaceVariant, height: 1.5),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ConicRingPainter extends CustomPainter {
  final double progress;
  const _ConicRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const strokeW = 14.0;
    final radius = (size.width - strokeW) / 2;
    final track = Paint()..color = AppColors.lSurfaceContainer..strokeWidth = strokeW..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final fill = Paint()..color = AppColors.lPrimary..strokeWidth = strokeW..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), radius, track);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: radius), -1.5708, 2 * 3.14159 * progress, false, fill);
  }

  @override
  bool shouldRepaint(_ConicRingPainter old) => old.progress != progress;
}
