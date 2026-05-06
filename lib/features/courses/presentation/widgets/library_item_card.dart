import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../presentation/providers/course_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Status badge extracted for reuse across library items.
enum LibraryItemStatus { ready, processing, incomplete }

class StatusBadge extends StatelessWidget {
  final LibraryItemStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg; Color fg; String label;
    switch (status) {
      case LibraryItemStatus.ready:
        bg = AppColors.lSecondaryContainer; fg = AppColors.lOnSecondaryContainer; label = 'READY';
        break;
      case LibraryItemStatus.processing:
        bg = AppColors.lSurfaceContainerHighest; fg = AppColors.lOnSurfaceVariant; label = 'PROCESSING';
        break;
      case LibraryItemStatus.incomplete:
        bg = AppColors.lTertiaryFixed; fg = AppColors.lOnTertiaryFixedVariant; label = 'INCOMPLETE';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: fg, letterSpacing: 0.5)),
    );
  }
}

/// Single row card in the Material Lab library list.
class LibraryItemCard extends StatelessWidget {
  final String filename;
  final String department;
  final String year;
  final LibraryItemStatus status;
  final VoidCallback? onAction;
  final String courseId;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelect;
  final VoidCallback? onLongPress;

  const LibraryItemCard({
    super.key,
    required this.filename,
    required this.department,
    required this.year,
    required this.status,
    required this.courseId,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelect,
    this.onLongPress,
    this.onAction,
  });

  IconData get _icon {
    switch (status) {
      case LibraryItemStatus.ready: return Icons.description_outlined;
      case LibraryItemStatus.processing: return Icons.picture_as_pdf_outlined;
      case LibraryItemStatus.incomplete: return Icons.folder_zip_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lPrimaryContainer.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSelected ? AppColors.lPrimary : AppColors.lOutlineVariant, width: isSelected ? 1.5 : 1),
        boxShadow: const [BoxShadow(color: Color(0x06002045), blurRadius: 6)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onLongPress: onLongPress,
          onTap: isSelectionMode ? onSelect : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                if (isSelectionMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) => onSelect?.call(),
                    activeColor: AppColors.lPrimary,
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: AppColors.lSurfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                  child: Icon(_icon, color: status == LibraryItemStatus.incomplete ? AppColors.lOutline : AppColors.lPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(filename, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lOnSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('$department • $year', style: GoogleFonts.inter(fontSize: 12, color: AppColors.lOnSurfaceVariant)),
                      const SizedBox(width: 8),
                      StatusBadge(status: status),
                    ]),
                  ]),
                ),
                const SizedBox(width: 8),
                if (!isSelectionMode) ...[
                  _ActionWidget(status: status, onAction: onAction),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.lOutline, size: 20),
                    onSelected: (val) async {
                       if (val == 'delete') {
                         final auth = Provider.of<AuthProvider>(context, listen: false);
                         final provider = Provider.of<CourseProvider>(context, listen: false);
                         await provider.deleteCourse(auth.currentUser?.id ?? 'demo_user', courseId);
                       }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'delete', child: Text('Delete Module', style: TextStyle(color: AppColors.lError, fontSize: 13, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionWidget extends StatelessWidget {
  final LibraryItemStatus status;
  final VoidCallback? onAction;
  const _ActionWidget({required this.status, this.onAction});
  @override
  Widget build(BuildContext context) {
    if (status == LibraryItemStatus.ready) {
      return TextButton.icon(
        onPressed: onAction,
        icon: const Icon(Icons.play_circle_outline, size: 18),
        label: const Text('Start Quiz'),
        style: TextButton.styleFrom(foregroundColor: AppColors.lPrimary, textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
      );
    } else if (status == LibraryItemStatus.incomplete) {
      return TextButton(onPressed: onAction,
        child: Text('Resume', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.lOutline)));
    }
    return const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.lPrimary)));
  }
}
