import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../data/models/course_model.dart';
import '../../data/models/material_model.dart';
import '../../../quizzes/presentation/screens/quiz_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Dummy data for now. Needs a proper MaterialProvider/Repository in the future.
  List<MaterialModel> _materials = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _uploadMaterial() {
    // Scaffold for file picking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulating PDF Upload...')),
    );
    setState(() {
      _materials.add(
        MaterialModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          courseId: widget.course.id,
          filePath: 'local/path/to/notes.pdf',
          contentSummary: 'Chapter 1 Notes',
          uploadedAt: DateTime.now(),
        ),
      );
    });
  }

  void _readMaterial(MaterialModel material) {
    // In a real app, this opens flutter_pdfview or similar, and updates StudySessionModel on exit.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening PDF: ${material.contentSummary}. Position will be tracked.')),
    );
  }

  void _generateAndTakeQuiz() {
    // Routes to Quiz Screen to take a quiz for this specific course based on itemShareCount
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(), // You would pass courseId here in the future
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lBackground,
      appBar: const AppTopBar(),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      child: Text(widget.course.courseName, style: AppTextStyles.h2),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${widget.course.creditHours} Credits • Target Load: ${widget.course.itemShareCount ?? 0} Questions', 
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lOutline)),
              ],
            ),
          ),
          
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.lPrimary,
              unselectedLabelColor: AppColors.lOutline,
              indicatorColor: AppColors.lPrimary,
              tabs: const [
                Tab(text: 'Materials'),
                Tab(text: 'Quizzes'),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMaterialsTab(),
                _buildQuizzesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateAndTakeQuiz,
        backgroundColor: AppColors.lPrimary,
        icon: const Icon(Icons.psychology, color: Colors.white),
        label: Text('Take Exam', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMaterialsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CustomButton(
          text: 'Upload Course Material',
          icon: Icons.upload_file,
          type: ButtonType.outline,
          onPressed: _uploadMaterial,
        ),
        const SizedBox(height: 24),
        if (_materials.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text('No materials uploaded yet.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lOutline)),
            ),
          )
        else
          ..._materials.map((m) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lSurface),
            ),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.lError),
              title: Text(m.contentSummary ?? 'Document', style: AppTextStyles.bodyLarge),
              subtitle: Text('Uploaded: ${m.uploadedAt.day}/${m.uploadedAt.month}/${m.uploadedAt.year}', style: AppTextStyles.bodySmall),
              trailing: const Icon(Icons.remove_red_eye, color: AppColors.lPrimary),
              onTap: () => _readMaterial(m),
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildQuizzesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz, size: 64, color: AppColors.lSurface),
          const SizedBox(height: 16),
          Text('Ready to test your knowledge?', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Generate a new exam using the \nAI Blueprint extraction engine.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lOutline),
          ),
        ],
      ),
    );
  }
}
