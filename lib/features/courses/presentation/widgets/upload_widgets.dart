import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../screens/upload_logic.dart';

class TypeToggle extends StatelessWidget {
  final UploadLogic logic;
  const TypeToggle({super.key, required this.logic});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor)),
    child: Row(children: [
      _ToggleItem(label: 'Material', isActive: logic.type == 'material', color: AppColors.cyan, onTap: () { logic.type = 'material'; logic.onUpdate(); }),
      _ToggleItem(label: 'Blueprint', isActive: logic.type == 'blueprint', color: AppColors.purple, onTap: () { logic.type = 'blueprint'; logic.onUpdate(); }),
    ]),
  );
}

class _ToggleItem extends StatelessWidget {
  final String label; final bool isActive; final Color color; final VoidCallback onTap;
  const _ToggleItem({required this.label, required this.isActive, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isActive ? color.withOpacity(0.2) : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Text(label, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(color: isActive ? color : AppColors.textSecondary, fontWeight: FontWeight.bold)))));
}

class StatusArea extends StatelessWidget {
  final UploadLogic logic; final String? name; final VoidCallback onPick, onClear, onUpload;
  const StatusArea({super.key, required this.logic, required this.name, required this.onPick, required this.onClear, required this.onUpload});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(logic.type == 'material' ? 'Upload notes to generate quizzes.' : 'Upload blueprints to guide mock exams.', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
    if (logic.isUploading) ...[const SizedBox(height: 16), const CircularProgressIndicator(color: AppColors.cyan), const SizedBox(height: 16), Text(logic.status, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cyan), textAlign: TextAlign.center)],
    const SizedBox(height: 32),
    if (name == null) CustomButton(text: 'Pick PDF', onPressed: onPick)
    else _SelectedFile(name: name!, onClear: onClear, onUpload: onUpload, loading: logic.isUploading),
  ]);
}

class _SelectedFile extends StatelessWidget {
  final String name; final VoidCallback onClear, onUpload; final bool loading;
  const _SelectedFile({required this.name, required this.onClear, required this.onUpload, required this.loading});
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor)), child: Row(children: [const Icon(Icons.picture_as_pdf, color: AppColors.error), const SizedBox(width: 12), Expanded(child: Text(name, style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis)), IconButton(icon: const Icon(Icons.close), onPressed: onClear)])),
    const SizedBox(height: 24),
    CustomButton(text: 'Confirm Upload', onPressed: onUpload, isLoading: loading),
  ]);
}

class ManualLink extends StatelessWidget {
  const ManualLink({super.key});
  @override
  Widget build(BuildContext context) => TextButton(onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.addCourse), child: Text(AppStrings.addCoursesManually, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cyan)));
}
