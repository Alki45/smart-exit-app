import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Single answer option tile. States: default, selected, correct, incorrect.
class AnswerOptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final bool isSelected;
  final bool? isCorrect; // null = unrevealed
  final VoidCallback onTap;

  const AnswerOptionTile({
    super.key, required this.letter, required this.text,
    required this.isSelected, required this.onTap, this.isCorrect,
  });

  Color get _border => isCorrect == true ? AppColors.lSecondary
      : (isCorrect == false && isSelected) ? AppColors.lError
      : isSelected ? AppColors.lSecondary : AppColors.lOutlineVariant;

  Color get _bg => isCorrect == true ? AppColors.lSecondaryContainer.withOpacity(0.2)
      : (isCorrect == false && isSelected) ? const Color(0xFFFFDAD6).withOpacity(0.3)
      : isSelected ? AppColors.lSecondaryContainer.withOpacity(0.1) : Colors.white;

  Color get _circle => isCorrect == true ? AppColors.lSecondary
      : (isCorrect == false && isSelected) ? AppColors.lError
      : isSelected ? AppColors.lSecondary : Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bg, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: isSelected ? _circle : Colors.transparent, shape: BoxShape.circle,
              border: Border.all(color: isSelected ? _circle : AppColors.lOutlineVariant, width: 2),
            ),
            child: Center(child: Text(letter,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.lOnSurfaceVariant))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.lOnSurface, height: 1.4))),
          if (isCorrect == true) const Icon(Icons.check_circle_rounded, color: AppColors.lSecondary, size: 20),
          if (isCorrect == false && isSelected) const Icon(Icons.cancel_rounded, color: AppColors.lError, size: 20),
        ]),
      ),
    );
  }
}
