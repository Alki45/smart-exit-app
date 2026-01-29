import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/course_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/course_provider.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  void _showCourseOptions(BuildContext context, dynamic course) {
     showModalBottomSheet(
        context: context,
        builder: (ctx) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Text(course.courseName, style: AppTextStyles.h3),
                    const SizedBox(height: 24),
                    CustomButton(
                        text: 'Take Quizzes',
                        onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pushNamed(
                                context, 
                                AppRoutes.quizList, 
                                arguments: {'courseId': course.id}
                            );
                        },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                        text: 'Upload Material & Generate Quiz',
                        type: ButtonType.outline,
                        onPressed: () {
                             Navigator.pop(ctx);
                             // Reuse Upload Screen but pass courseId to link it
                             // For now, simpler to just navigate and let user know
                             // Ideally we pass arguments to UploadScreen
                             Navigator.pushNamed(context, AppRoutes.uploadBlueprint); 
                             ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Select "Course Material" to generate quiz for this course.')),
                             );
                        },
                    ),
                ],
            ),
        ),
     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.blueprintCourses),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
         actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
               Navigator.pushNamed(context, AppRoutes.uploadBlueprint);
            },
          ),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.myCourses,
                      style: AppTextStyles.h4.copyWith(color: AppColors.cyan),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${courseProvider.courseCount} ${AppStrings.coursesTracked}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),

              // Course List
              Expanded(
                child: courseProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: courseProvider.courses.length,
                        itemBuilder: (context, index) {
                          final course = courseProvider.courses[index];
                          return CourseCard(
                            courseCode: course.courseCode,
                            courseName: course.courseName,
                            topicsCount: course.topics.length,
                            onTap: () {
                              _showCourseOptions(context, course);
                            },
                          );
                        },
                      ),
              ),
              
              // Add Course Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  text: '+ ${AppStrings.addCourse}',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.addCourse);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
