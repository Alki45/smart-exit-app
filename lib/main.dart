import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'firebase_options.dart'; // To be configured

import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_routes.dart';

// Feature Providers
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/courses/presentation/providers/course_provider.dart';
import 'features/quizzes/presentation/providers/quiz_provider.dart';
import 'features/progress/presentation/providers/progress_provider.dart';

// Screens
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/courses/presentation/screens/courses_screen.dart';
import 'features/courses/presentation/screens/add_course_screen.dart';
import 'features/courses/presentation/screens/upload_blueprint_screen.dart';
import 'features/quizzes/presentation/screens/quiz_list_screen.dart';
import 'features/quizzes/presentation/screens/quiz_screen.dart';
import 'features/quizzes/presentation/screens/quiz_results_screen.dart';
import 'features/quizzes/presentation/screens/quiz_review_screen.dart';
import 'features/quizzes/presentation/screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('progressBox');

  runApp(const SmartExitApp());
}

class SmartExitApp extends StatelessWidget {
  const SmartExitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],

      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.splash:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case AppRoutes.login:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case AppRoutes.register:
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case AppRoutes.home:
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case AppRoutes.profile:
            case AppRoutes.editProfile: 
               return MaterialPageRoute(builder: (_) => const EditProfileScreen());
            case AppRoutes.courses:
              return MaterialPageRoute(builder: (_) => const CoursesScreen());
            case AppRoutes.addCourse:
              return PageRouteBuilder(
                  opaque: false, 
                  pageBuilder: (_, __, ___) => const AddCourseScreen(),
              );
            case AppRoutes.uploadBlueprint:
              return MaterialPageRoute(builder: (_) => const UploadBlueprintScreen());
            case AppRoutes.quizList:
              // Extract arguments if passed
              final args = settings.arguments as Map<String, dynamic>?;
              final courseId = args?['courseId'] ?? '1'; // Default to 1
              return MaterialPageRoute(builder: (_) => QuizListScreen(courseId: courseId));
            case AppRoutes.takeQuiz:
              return MaterialPageRoute(builder: (_) => const QuizScreen());
            case AppRoutes.quizResults:
              return MaterialPageRoute(builder: (_) => const QuizResultsScreen());
            case AppRoutes.quizReview:
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => QuizReviewScreen(
                  attempt: args['attempt'],
                  quiz: args['quiz'],
                ),
              );
            case AppRoutes.pastAttempts:
              return MaterialPageRoute(builder: (_) => const HistoryScreen());
            default:
              return null;
          }
        },
      ),
    );
  }
}
