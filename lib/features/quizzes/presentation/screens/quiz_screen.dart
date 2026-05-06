import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../providers/quiz_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import '../sections/quiz_progress_section.dart';
import '../sections/question_card_section.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizProvider _quizProvider;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _quizProvider = Provider.of<QuizProvider>(context, listen: false);
    _quizProvider.addListener(_onProviderUpdate);
  }

  void _onProviderUpdate() {
    if (!_quizProvider.isQuizActive && mounted) {
      Navigator.pushReplacementNamed(context, '/quiz-results');
    }
  }

  @override
  void dispose() {
    _quizProvider.removeListener(_onProviderUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        final quiz = provider.activeQuiz;
        if (quiz == null) return const Scaffold(body: Center(child: Text('Error loading quiz')));
        final question = quiz.questions[provider.currentQuestionIndex];
        final current = provider.currentQuestionIndex + 1;
        final total = quiz.questions.length;

        return Scaffold(
          backgroundColor: AppColors.lBackground,
          appBar: AppTopBar(rightSlot: _TimerChip(timerString: provider.timerString)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              children: [
                QuizProgressSection(current: current, total: total),
                const SizedBox(height: 20),
                QuestionCardSection(
                  question: question,
                  provider: provider,
                  submitted: _submitted,
                  onSubmit: () => setState(() => _submitted = true),
                ),
                const SizedBox(height: 20),
                _FooterNav(
                  current: current,
                  total: total,
                  submitted: _submitted,
                  onPrev: provider.previousQuestion,
                  onNext: () {
                    setState(() => _submitted = false);
                    if (current == total) {
                      final score = provider.calculateScore();
                      Provider.of<ProgressProvider>(context, listen: false).recordQuizCompletion(score);
                      provider.endQuiz();
                      Navigator.pushReplacementNamed(context, '/quiz-results');
                    } else {
                      provider.nextQuestion();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerChip extends StatelessWidget {
  final String timerString;
  const _TimerChip({required this.timerString});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: AppColors.lSurfaceContainerLow, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.lOutlineVariant)),
    child: Row(children: [
      const Icon(Icons.timer_outlined, size: 16, color: AppColors.lPrimary),
      const SizedBox(width: 6),
      Text(timerString, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
    ]),
  );
}

class _FooterNav extends StatelessWidget {
  final int current;
  final int total;
  final bool submitted;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _FooterNav({required this.current, required this.total, required this.submitted, required this.onPrev, required this.onNext});
  @override
  Widget build(BuildContext context) {
    if (!submitted) return const SizedBox.shrink();
    return Row(children: [
      if (current > 1) ...[
        Expanded(child: OutlinedButton(onPressed: onPrev,
          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.lPrimary), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text('Previous', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.lPrimary)))),
        const SizedBox(width: 12),
      ],
      Expanded(child: ElevatedButton.icon(
        onPressed: onNext,
        icon: const Icon(Icons.arrow_forward, size: 16),
        label: Text(current == total ? 'Submit Quiz' : 'Next Question', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.lPrimary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      )),
    ]);
  }
}
