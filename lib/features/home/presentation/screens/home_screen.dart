import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../courses/presentation/providers/course_provider.dart';
import '../../../quizzes/presentation/providers/quiz_provider.dart';
import '../sections/hero_section.dart';
import '../sections/streak_card.dart';
import '../sections/active_prep_section.dart';
import '../sections/quick_actions_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null || auth.isDemoMode) {
        final id = auth.currentUser?.id ?? 'demo';
        Provider.of<CourseProvider>(context, listen: false).loadUserData(id, isDemo: auth.isDemoMode);
        if (!auth.isDemoMode) {
          Provider.of<QuizProvider>(context, listen: false).loadHistory(id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lBackground,
      appBar: const AppTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          children: [
            // Hero row: welcome card + streak ring
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(flex: 2, child: HeroSection()),
                  SizedBox(width: 14),
                  Expanded(flex: 1, child: StreakCard()),
                ],
              ),
            ),
            const SizedBox(height: 36),
            const ActivePrepSection(),
            const SizedBox(height: 36),
            const QuickActionsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.uploadBlueprint),
        backgroundColor: AppColors.lPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

