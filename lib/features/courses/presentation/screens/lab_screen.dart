import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/department_provider.dart';
import '../sections/department_list_section.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Material Lab screen — Department-first navigation.
class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lBackground,
      appBar: const AppTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Material Lab', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text(
              'Select your department to access blueprints, course materials and generate quizzes.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Department search
            Consumer<DepartmentProvider>(
              builder: (context, provider, _) {
                return CustomTextField(
                  label: 'Search Departments',
                  hint: 'Search by name or faculty...',
                  prefixIcon: Icons.search,
                  onChanged: (val) => provider.setSearchQuery(val ?? ''),
                );
              },
            ),
            const SizedBox(height: 20),

            // Add Department Button
            Consumer<DepartmentProvider>(
              builder: (context, provider, _) {
                return OutlinedButton.icon(
                  onPressed: () => _showAddDepartmentDialog(context, provider),
                  icon: const Icon(Icons.add, color: AppColors.lPrimary),
                  label: Text('Add Department', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lPrimary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.lPrimary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Department list
            const DepartmentListSection(),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  void _showAddDepartmentDialog(BuildContext context, DepartmentProvider provider) {
    final nameController = TextEditingController();
    final facultyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Department', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Department Name', hintText: 'e.g. Computer Science and Engineering'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: facultyController,
              decoration: const InputDecoration(labelText: 'Faculty', hintText: 'e.g. Faculty of Technology'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lOutline)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lPrimary, foregroundColor: Colors.white),
            onPressed: () async {
              final name = nameController.text.trim();
              final faculty = facultyController.text.trim();
              if (name.isNotEmpty && faculty.isNotEmpty) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                Navigator.pop(ctx);
                await provider.addDepartment(name, faculty, isDemo: auth.isDemoMode);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
