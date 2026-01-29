import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/course_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({Key? key}) : super(key: key);

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _creditController = TextEditingController(text: '3');

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<CourseProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);

      if (auth.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated'), backgroundColor: AppColors.error),
        );
        return;
      }
      
      final success = await provider.addCourse(
        userId: auth.currentUser!.id,
        code: _codeController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        creditHours: int.parse(_creditController.text.trim()),
      );

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Course added successfully'), backgroundColor: AppColors.success),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to add course'), 
              backgroundColor: AppColors.error
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using a Dialog-like full screen or actual dialog logic. 
    // The design shows it as a bottom sheet or dialog, but for now a screen or modal is fine.
    // Let's make it looks like a centered modal dialog on a dark overlay as per design,
    // but implemented as a Screen for simplicity in navigation.
    
    return Scaffold(
      backgroundColor: Colors.black54, // Semi-transparent background
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderColorLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Course',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: '', // Hidden label as per design
                      hint: 'Course Code (e.g. CSE101)',
                      controller: _codeController,
                      validator: Validators.validateCourseCode,
                    ),
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      label: '',
                      hint: 'Course Name',
                      controller: _nameController,
                      validator: (v) => Validators.validateRequired(v, 'Course Name'),
                    ),
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      label: '', // Hidden label
                      hint: 'Credit Hours',
                      controller: _creditController,
                      keyboardType: TextInputType.number,
                      validator: Validators.validateCreditHours,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer<CourseProvider>(
                      builder: (context, provider, _) {
                        return CustomButton(
                          text: 'Add',
                          onPressed: _submit,
                          isLoading: provider.isLoading,
                          height: 48,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
