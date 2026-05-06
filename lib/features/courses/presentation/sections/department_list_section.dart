import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/department_provider.dart';
import '../screens/department_detail_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DepartmentListSection extends StatefulWidget {
  const DepartmentListSection({super.key});

  @override
  State<DepartmentListSection> createState() => _DepartmentListSectionState();
}

class _DepartmentListSectionState extends State<DepartmentListSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<DepartmentProvider>(context, listen: false).loadDepartments(isDemo: auth.isDemoMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DepartmentProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.departments.isEmpty) {
          return const Center(child: LoadingIndicator());
        }

        if (provider.errorMessage != null && provider.departments.isEmpty) {
          return Center(
            child: Text(
              provider.errorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lError),
            ),
          );
        }

        if (provider.departments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.domain_disabled, size: 64, color: AppColors.lOutline),
                  const SizedBox(height: 16),
                  Text(
                    'No Departments Found',
                    style: AppTextStyles.h3.copyWith(color: AppColors.lOutline),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a department to begin mapping your blueprint and materials.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.departments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final dept = provider.departments[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DepartmentDetailScreen(department: dept),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lPrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.domain, color: AppColors.lPrimary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dept.name, style: AppTextStyles.h3),
                          const SizedBox(height: 4),
                          Text(dept.faculty, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.lOutline),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
