import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../courses/presentation/providers/course_provider.dart';
import '../../../quizzes/presentation/providers/quiz_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        final userId = auth.currentUser!.id;
        Provider.of<CourseProvider>(context, listen: false).loadUserData(userId);
        Provider.of<QuizProvider>(context, listen: false).loadHistory(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        automaticallyImplyLeading: false, // Hide back button
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.pushNamed(context, AppRoutes.editProfile);
              } else if (value == 'logout') {
                Provider.of<AuthProvider>(context, listen: false).logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final firstName = auth.currentUser?.fullName.split(' ').first ?? 'Student';
                return Text('Welcome back, $firstName!', style: AppTextStyles.h2);
              },
            ),
            const SizedBox(height: 24),
            
            // Stats Grid
            Consumer<ProgressProvider>(
              builder: (context, progress, child) {
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        color: Colors.orange,
                        value: '${progress.streak}',
                        label: 'Day Streak',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.quiz,
                        color: AppColors.cyan,
                        value: '${progress.quizzesTaken}',
                        label: 'Quizzes',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
             Consumer<ProgressProvider>(
              builder: (context, progress, child) {
                return _StatCard(
                  icon: Icons.score,
                  color: AppColors.purple,
                  value: '${progress.averageScore.toStringAsFixed(1)}%',
                  label: 'Avg. Score',
                  isWide: true,
                );
              },
             ),
            
            const SizedBox(height: 32),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Text(
                          'Ready to study?', 
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Explore Courses',
                        onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.courses);
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'View History',
                        type: ButtonType.outline,
                        onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.pastAttempts);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final bool isWide;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: isWide ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.h3),
              Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
