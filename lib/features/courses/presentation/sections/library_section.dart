import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../presentation/providers/course_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/library_item_card.dart';

/// Library section header + list of uploaded material items.
class LibrarySection extends StatelessWidget {
  const LibrarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, _) {
        final courses = provider.filteredCourses;
        final isSelectionMode = provider.isSelectionMode;
        final selectedCount = provider.selectedCourseIds.length;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Library', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.lOnSurface)),
                Row(
                  children: [
                    Text('${courses.length} Modules', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.lOnSurfaceVariant)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(isSelectionMode ? Icons.close : Icons.checklist, size: 20, color: isSelectionMode ? AppColors.lPrimary : AppColors.lOnSurfaceVariant),
                      onPressed: () => provider.toggleSelectionMode(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            if (isSelectionMode && courses.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.lPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: selectedCount == courses.length && courses.isNotEmpty,
                          onChanged: (val) => provider.selectAllCourses(val ?? false),
                          activeColor: AppColors.lPrimary,
                        ),
                        Text('$selectedCount Selected', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lPrimary)),
                      ],
                    ),
                    if (selectedCount > 0)
                      TextButton.icon(
                        onPressed: () {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          final userId = auth.currentUser?.id ?? 'demo_user';
                          provider.deleteSelectedCourses(userId);
                        },
                        icon: const Icon(Icons.delete_outline, color: AppColors.lError, size: 18),
                        label: Text('Delete', style: GoogleFonts.inter(color: AppColors.lError, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (courses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text(provider.searchQuery.isNotEmpty ? 'No modules match your search.' : 'No modules yet. Upload a blueprint to start.', style: GoogleFonts.inter(color: AppColors.lOnSurfaceVariant))),
              ),
            ...courses.map((course) {
              final status = course.materialUrls.isNotEmpty 
                  ? LibraryItemStatus.ready 
                  : LibraryItemStatus.incomplete;
              
              return LibraryItemCard(
                filename: course.courseName,
                department: course.courseCode,
                year: course.theme ?? 'Unit',
                status: status,
                courseId: course.id,
                isSelectionMode: isSelectionMode,
                isSelected: provider.selectedCourseIds.contains(course.id),
                onSelect: () => provider.toggleCourseSelection(course.id),
                onLongPress: () {
                  if (!isSelectionMode) {
                    provider.toggleSelectionMode();
                    provider.toggleCourseSelection(course.id);
                  }
                },
              );
            }),
          ],
        );
      },
    );
  }
}

class _Item {
  final String filename;
  final String department;
  final String year;
  final LibraryItemStatus status;
  const _Item(this.filename, this.department, this.year, this.status);
}
