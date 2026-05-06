import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/data/models/department_model.dart';
import '../providers/course_provider.dart';
import 'upload_blueprint_screen.dart';
import 'course_detail_screen.dart';

class DepartmentDetailScreen extends StatelessWidget {
  final DepartmentModel department;

  const DepartmentDetailScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lBackground,
      appBar: const AppTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(department.name, style: AppTextStyles.h2),
                      Text(department.faculty, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lOutline)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Content
            Consumer<CourseProvider>(
              builder: (context, provider, _) {
                // Filter courses by departmentId
                final courses = provider.getCoursesByDepartment(department.id);

                if (courses.isEmpty) {
                  return _buildEmptyState(context);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mapped Courses', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.lSurface),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.lSecondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.book, color: AppColors.lSecondary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(course.courseName, style: AppTextStyles.bodyLarge),
                                      const SizedBox(height: 4),
                                      Text('${course.creditHours} Credits • ${course.itemShareCount ?? 0} Questions', style: AppTextStyles.bodySmall),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.lOutline),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.lPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.upload_file, size: 48, color: AppColors.lPrimary),
          ),
          const SizedBox(height: 24),
          Text('No Blueprint Uploaded', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Upload the official MoE Exit Exam blueprint for this department to generate the course mapping and competencies.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lOutline),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Upload Blueprint',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UploadBlueprintScreen(),
                  settings: RouteSettings(arguments: {'departmentId': department.id}),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
