import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../quizzes/data/models/question_model.dart';
import '../providers/quiz_provider.dart';
import '../widgets/answer_option_tile.dart';

/// Question card: badge, question text, answer options, submit button.
class QuestionCardSection extends StatelessWidget {
  final QuestionModel question;
  final QuizProvider provider;
  final bool submitted;
  final VoidCallback onSubmit;

  const QuestionCardSection({
    super.key, required this.question, required this.provider,
    required this.submitted, required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final selected = provider.userAnswers[question.id];
    final letters = ['A', 'B', 'C', 'D', 'E'];
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lOutlineVariant),
        boxShadow: const [BoxShadow(color: Color(0x08002045), blurRadius: 12)]),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 4, color: AppColors.lPrimary),
        Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.lPrimaryContainer, borderRadius: BorderRadius.circular(99)),
            child: Text(question.topic ?? 'General',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                color: AppColors.lOnPrimaryContainer, letterSpacing: 0.6)),
          ),
          const SizedBox(height: 16),
          Text(question.questionText,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.lOnSurface, height: 1.6)),
          const SizedBox(height: 20),
          ...List.generate(question.options.length, (i) {
            bool? isCorrect;
            if (submitted) isCorrect = i == question.correctAnswerIndex ? true : (selected == i ? false : null);
            return AnswerOptionTile(
              letter: letters[i], text: question.options[i],
              isSelected: selected == i, isCorrect: isCorrect,
              onTap: () { if (!submitted) provider.selectAnswer(question.id, i); },
            );
          }),
          const SizedBox(height: 8),
          if (!submitted) Align(alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: selected != null ? onSubmit : null,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text('Submit Answer', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.lPrimary, foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.lOutlineVariant,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
        ])),
      ]),
    );
  }
}
