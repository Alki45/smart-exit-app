import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/question_generator_service.dart';
import '../../../../features/quizzes/presentation/providers/quiz_provider.dart';
import '../../../../features/quizzes/data/models/quiz_model.dart';
import '../../data/models/blueprint_model.dart';
import '../providers/course_provider.dart';
import 'package:uuid/uuid.dart';

class UploadBlueprintScreen extends StatefulWidget {
  const UploadBlueprintScreen({Key? key}) : super(key: key);

  @override
  State<UploadBlueprintScreen> createState() => _UploadBlueprintScreenState();
}

class _UploadBlueprintScreenState extends State<UploadBlueprintScreen> {
  String? _selectedFileName;
  String? _selectedFilePath;
  bool _isUploading = false;
  String _statusMessage = '';
  String _uploadType = 'material'; // 'material' or 'blueprint'

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFilePath = result.files.single.path;
      });
    }
  }

  void _upload() async {
    if (_selectedFileName == null || _selectedFilePath == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    final userId = auth.currentUser!.id;
    setState(() {
      _isUploading = true;
      _statusMessage = 'Starting upload...';
    });

    try {
      if (_uploadType == 'material') {
        await _processCourseMaterial(userId);
      } else {
        await _processBlueprint(userId);
      }
      
      if (mounted) {
        setState(() {
          _isUploading = false;
          _statusMessage = 'Success!';
        });
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _processCourseMaterial(String userId) async {
      setState(() => _statusMessage = 'Extracting text from PDF...');
      final pdfService = PdfService();
      final text = await pdfService.extractText(_selectedFilePath!);

      if (text.isEmpty) {
         throw Exception('No text found in PDF');
      }

      setState(() => _statusMessage = 'Generating AI Quizzes (this may take a moment)...');
      final generator = QuestionGeneratorService();
      final questions = await generator.generateQuestions(text, limit: 15);

      if (questions.isEmpty) {
        throw Exception('Could not generate any questions from this content.');
      }

      setState(() => _statusMessage = 'Saving to your account...');
      final quizId = const Uuid().v4();
      final quiz = QuizModel(
        id: quizId,
        courseId: '1', // Default
        title: 'Quiz: $_selectedFileName',
        duration: 20,
        questions: questions,
        createdAt: DateTime.now(),
      );

      if (mounted) {
        await Provider.of<QuizProvider>(context, listen: false).saveQuiz(userId, quiz);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz generated and saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
  }

  Future<void> _processBlueprint(String userId) async {
      setState(() => _statusMessage = 'Analyzing Blueprint structure...');
      final pdfService = PdfService();
      final text = await pdfService.extractText(_selectedFilePath!);

      if (text.isEmpty) {
          throw Exception('No text found in Blueprint PDF');
      }

      if (mounted) {
         try {
            setState(() => _statusMessage = 'Extracting courses and topics...');
            await Provider.of<CourseProvider>(context, listen: false).generateCoursesFromBlueprint(userId, text);
            
            setState(() => _statusMessage = 'Finalizing blueprint setup...');
            final blueprint = BlueprintModel(
              id: const Uuid().v4(),
              fileName: _selectedFileName!,
              fileUrl: _selectedFilePath!, 
              uploadedAt: DateTime.now(),
            );
            
            await Provider.of<CourseProvider>(context, listen: false).addBlueprint(userId, blueprint);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Blueprint processed and saved to your account!'),
                backgroundColor: AppColors.success,
              ),
            );
         } catch (e) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Generation Failed: ${e.toString()}'),
                backgroundColor: AppColors.error,
              ),
            );
         }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Blueprint'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Icon Placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackgroundLight,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 60,
                color: AppColors.cyan,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Upload Resource',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _uploadType = 'material'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _uploadType == 'material' ? AppColors.cyan.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Course Material',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _uploadType == 'material' ? AppColors.cyan : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                   Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _uploadType = 'blueprint'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _uploadType == 'blueprint' ? AppColors.purple.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                         child: Text(
                          'Exam Blueprint',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                             color: _uploadType == 'blueprint' ? AppColors.purple : AppColors.textSecondary,
                             fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              _uploadType == 'material' 
                  ? 'Upload PDFs, Word docs, or slides to generate practice quizzes.'
                  : 'Upload official Exit Exam Blueprints to guide mock exam structure.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Upload Button Area
            if (_selectedFileName == null)
              CustomButton(
                text: AppStrings.uploadBlueprint,
                onPressed: _pickFile,
                type: ButtonType.primary,
              )
            else
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: AppColors.cardBackground,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: AppColors.borderColor),
                 ),
                 child: Row(
                   children: [
                     const Icon(Icons.picture_as_pdf, color: AppColors.error),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Text(
                         _selectedFileName!,
                         style: AppTextStyles.bodyMedium,
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                     IconButton(
                       icon: const Icon(Icons.close, color: AppColors.textTertiary),
                       onPressed: () => setState(() => _selectedFileName = null),
                     ),
                   ],
                 ),
               ),
            
            if (_selectedFileName != null)...[
               const SizedBox(height: 24),
               CustomButton(
                 text: 'Confirm Upload',
                 onPressed: _upload,
                 isLoading: _isUploading,
               ),
            ],

            const Spacer(),
            
            TextButton(
              onPressed: () {
                // Navigate to manual add
                 Navigator.pushReplacementNamed(context, AppStrings.addCourse);
              },
              child: Text(
                AppStrings.addCoursesManually,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cyan),
              ), 
            ),
             const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
