import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';

/// Filter pill bar for the Material Lab screen.
class FilterBarSection extends StatefulWidget {
  const FilterBarSection({super.key});
  @override
  State<FilterBarSection> createState() => _FilterBarSectionState();
}

class _FilterBarSectionState extends State<FilterBarSection> {
  int _selected = 0;
  final _filters = ['All Modules', 'Department', 'Year of Study'];

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, _) {
        final _selected = provider.activeFilterIndex;
        
        return Row(
          children: [
            Text('Filter By:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.lOnSurfaceVariant)),
            const SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (i) {
                    final isActive = i == _selected;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_filters[i]),
                        selected: isActive,
                        onSelected: (_) => provider.setFilterIndex(i),
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.lPrimaryFixed,
                        checkmarkColor: AppColors.lOnPrimaryFixed,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AppColors.lOnPrimaryFixed : AppColors.lOnSurfaceVariant,
                        ),
                        shape: StadiumBorder(
                          side: BorderSide(color: isActive ? Colors.transparent : AppColors.lOutlineVariant),
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
