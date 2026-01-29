import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../../../shared/widgets/searchable_dropdown.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Academic information
  Map<String, dynamic> _universityData = {};
  String? _selectedUniversity;
  String? _selectedCollege;
  String? _selectedDepartment;
  String? _selectedStream;
  String? _selectedYear;

  List<String> _universities = [];
  List<String> _colleges = [];
  List<String> _departments = [];
  List<String> _streams = [];
  List<String> _years = [];

  @override
  void initState() {
    super.initState();
    _loadUniversityData();
  }

  Future<void> _loadUniversityData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/universities.json');
      final data = json.decode(response);
      setState(() {
        _universityData = data;
        _universities = (data['universities'] as List)
            .map((u) => u['name'] as String)
            .toList();
        _years = (data['years'] as List<dynamic>)
            .map((y) => y as String)
            .toList();
      });
    } catch (e) {
      print('Error loading university data: $e');
    }
  }

  void _onUniversityChanged(String? value) {
    setState(() {
      _selectedUniversity = value;
      _selectedCollege = null;
      _selectedDepartment = null;
      _selectedStream = null;
      
      if (value != null) {
        final university = (_universityData['universities'] as List)
            .firstWhere((u) => u['name'] == value);
        _colleges = (university['colleges'] as List)
            .map((c) => c['name'] as String)
            .toList();
      } else {
        _colleges = [];
      }
      _departments = [];
      _streams = [];
    });
  }

  void _onCollegeChanged(String? value) {
    setState(() {
      _selectedCollege = value;
      _selectedDepartment = null;
      _selectedStream = null;
      
      if (value != null && _selectedUniversity != null) {
        final university = (_universityData['universities'] as List)
            .firstWhere((u) => u['name'] == _selectedUniversity);
        final college = (university['colleges'] as List)
            .firstWhere((c) => c['name'] == value);
        _departments = (college['departments'] as List)
            .map((d) => d['name'] as String)
            .toList();
      } else {
        _departments = [];
      }
      _streams = [];
    });
  }

  void _onDepartmentChanged(String? value) {
    setState(() {
      _selectedDepartment = value;
      _selectedStream = null;
      
      if (value != null && _selectedUniversity != null && _selectedCollege != null) {
        final university = (_universityData['universities'] as List)
            .firstWhere((u) => u['name'] == _selectedUniversity);
        final college = (university['colleges'] as List)
            .firstWhere((c) => c['name'] == _selectedCollege);
        final department = (college['departments'] as List)
            .firstWhere((d) => d['name'] == value);
        _streams = (department['streams'] as List<dynamic>)
            .map((s) => s as String)
            .toList();
      } else {
        _streams = [];
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedUniversity == null ||
          _selectedCollege == null ||
          _selectedDepartment == null ||
          _selectedStream == null ||
          _selectedYear == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select all academic information')),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.register(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        university: _selectedUniversity!,
        college: _selectedCollege!,
        department: _selectedDepartment!,
        stream: _selectedStream!,
        year: _selectedYear!,
      );

      if (result['success'] == true && mounted) {
        // Show verification email sent dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Row(
              children: [
                Icon(Icons.mark_email_read, color: AppColors.cyan, size: 28),
                SizedBox(width: 12),
                Text('Verify Your Email', style: AppTextStyles.h3),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We\'ve sent a verification email to:',
                  style: AppTextStyles.bodyMedium,
                ),
                SizedBox(height: 8),
                Text(
                  result['email'],
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.purple.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.purple, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please check your spam/junk folder if you don\'t see it in your inbox.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Click the verification link to activate your account.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              CustomButton(
                text: 'Got it',
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return LoadingOverlay(
            isLoading: auth.isLoading,
            message: 'Creating account...',
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create Account',
                          style: AppTextStyles.h1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start your journey to success today',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        CustomTextField(
                          label: AppStrings.fullName,
                          hint: 'Enter your full name',
                          controller: _fullNameController,
                          prefixIcon: Icons.person_outline,
                          validator: (v) => Validators.validateRequired(v, 'Full name'),
                        ),
                        const SizedBox(height: 16),

                        SearchableDropdown(
                          label: 'University',
                          hint: 'Select University',
                          value: _selectedUniversity,
                          items: _universities,
                          prefixIcon: Icons.school_outlined,
                          onChanged: _onUniversityChanged,
                          validator: (v) => Validators.validateRequired(v, 'University'),
                        ),
                        const SizedBox(height: 16),

                        SearchableDropdown(
                          label: 'College',
                          hint: 'Select College',
                          value: _selectedCollege,
                          items: _colleges,
                          prefixIcon: Icons.account_balance_outlined,
                          onChanged: _onCollegeChanged,
                          validator: (v) => Validators.validateRequired(v, 'College'),
                        ),
                        const SizedBox(height: 16),

                        SearchableDropdown(
                          label: 'Department',
                          hint: 'Select Department',
                          value: _selectedDepartment,
                          items: _departments,
                          prefixIcon: Icons.business_outlined,
                          onChanged: _onDepartmentChanged,
                          validator: (v) => Validators.validateRequired(v, 'Department'),
                        ),
                        const SizedBox(height: 16),

                        SearchableDropdown(
                          label: 'Stream (Program)',
                          hint: 'Select Stream',
                          value: _selectedStream,
                          items: _streams,
                          prefixIcon: Icons.library_books_outlined,
                          onChanged: (v) => setState(() => _selectedStream = v),
                          validator: (v) => Validators.validateRequired(v, 'Stream'),
                        ),
                        const SizedBox(height: 16),

                        CustomDropdown(
                          label: 'Academic Year',
                          hint: 'Select Year',
                          value: _selectedYear,
                          items: _years,
                          prefixIcon: Icons.calendar_today_outlined,
                          onChanged: (v) => setState(() => _selectedYear = v),
                          validator: (v) => Validators.validateRequired(v, 'Academic Year'),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: AppStrings.email,
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: AppStrings.password,
                          hint: 'Create a password',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: AppStrings.confirmPassword,
                          hint: 'Confirm your password',
                          controller: _confirmPasswordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
                          validator: (v) => Validators.validateConfirmPassword(
                            v, 
                            _passwordController.text,
                          ),
                        ),
                        const SizedBox(height: 32),

                         // Error Message
                        if (auth.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              auth.errorMessage!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        CustomButton(
                          text: AppStrings.register,
                          onPressed: _onRegister,
                          isLoading: auth.isLoading,
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.alreadyHaveAccount,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                AppStrings.login,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.cyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
