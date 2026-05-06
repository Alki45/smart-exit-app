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

  int _currentStep = 0;
  final int _totalSteps = 3;

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
      debugPrint('Error loading university data: $e');
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
            
        final rawStreams = (department['streams'] as List<dynamic>)
            .map((s) => s as String)
            .toList();
            
        if (rawStreams.isEmpty) {
          _streams = ['General'];
          _selectedStream = 'General';
        } else {
          _streams = rawStreams;
        }
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

  void _nextStep() {
    if (_currentStep == 0) {
      if (_fullNameController.text.isEmpty || Validators.validateEmail(_emailController.text) != null) {
         // Trigger validation
         _formKey.currentState!.validate();
         return;
      }
    } else if (_currentStep == 1) {
      if (_selectedUniversity == null || _selectedCollege == null || _selectedDepartment == null || _selectedStream == null || _selectedYear == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select all academic information')),
        );
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _onRegister();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _onRegister() async {
    if (_formKey.currentState!.validate()) {
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
        _showVerificationDialog(result['email']);
      }
    }
  }

  void _showVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.mark_email_read, color: AppColors.lPrimary, size: 64),
            const SizedBox(height: 16),
            Text('Verify Your Email', style: AppTextStyles.h2, textAlign: TextAlign.center),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('We\'ve sent a verification link to:', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(email, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.lPrimary, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.purple, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Check your spam folder if you don\'t see it in your inbox.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Return to Login',
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return LoadingOverlay(
            isLoading: auth.isLoading,
            message: 'Creating account...',
            child: SafeArea(
              child: Column(
                children: [
                  // Progress Header
                  _buildHeader(),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildStepTitle(),
                            const SizedBox(height: 32),
                            
                            if (_currentStep == 0) _buildPersonalInfoStep(),
                            if (_currentStep == 1) _buildAcademicInfoStep(),
                            if (_currentStep == 2) _buildSecurityStep(),
                            
                            const SizedBox(height: 40),
                            
                            if (auth.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  auth.errorMessage!,
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            
                            Row(
                              children: [
                                if (_currentStep > 0)
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Back',
                                      type: ButtonType.outline,
                                      onPressed: _previousStep,
                                    ),
                                  ),
                                if (_currentStep > 0) const SizedBox(width: 16),
                                Expanded(
                                  child: CustomButton(
                                    text: _currentStep == _totalSteps - 1 ? 'Register' : 'Continue',
                                    onPressed: _nextStep,
                                    isLoading: auth.isLoading,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            if (_currentStep == 0)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AppStrings.alreadyHaveAccount, style: AppTextStyles.bodyMedium),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(AppStrings.login, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.lPrimary, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              ),
              Text('Step ${_currentStep + 1} of $_totalSteps', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 48), // Spacer
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_totalSteps, (index) => Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index == _totalSteps - 1 ? 0 : 8),
                decoration: BoxDecoration(
                  color: index <= _currentStep ? AppColors.lPrimary : AppColors.lOutline.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTitle() {
    String title = '';
    String subtitle = '';
    
    switch (_currentStep) {
      case 0:
        title = 'Let\'s get started';
        subtitle = 'First, tell us who you are';
        break;
      case 1:
        title = 'Academic Background';
        subtitle = 'Tell us about your studies';
        break;
      case 2:
        title = 'Secure Account';
        subtitle = 'Create a strong password for your journey';
        break;
    }
    
    return Column(
      children: [
        Text(title, style: AppTextStyles.h1.copyWith(color: AppColors.lPrimary), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.lOnSurfaceVariant), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      children: [
        CustomTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          controller: _fullNameController,
          prefixIcon: Icons.person_outline,
          validator: (v) => Validators.validateRequired(v, 'Full name'),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Email Address',
          hint: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          validator: Validators.validateEmail,
        ),
      ],
    );
  }

  Widget _buildAcademicInfoStep() {
    return Column(
      children: [
        SearchableDropdown(
          label: 'University',
          hint: 'Select University',
          value: _selectedUniversity,
          items: _universities,
          prefixIcon: Icons.school_outlined,
          onChanged: _onUniversityChanged,
        ),
        const SizedBox(height: 20),
        SearchableDropdown(
          label: 'College',
          hint: 'Select College',
          value: _selectedCollege,
          items: _colleges,
          prefixIcon: Icons.account_balance_outlined,
          onChanged: _onCollegeChanged,
        ),
        const SizedBox(height: 20),
        SearchableDropdown(
          label: 'Department',
          hint: 'Select Department',
          value: _selectedDepartment,
          items: _departments,
          prefixIcon: Icons.business_outlined,
          onChanged: _onDepartmentChanged,
        ),
        const SizedBox(height: 20),
        SearchableDropdown(
          label: 'Program Stream',
          hint: 'Select Stream',
          value: _selectedStream,
          items: _streams,
          prefixIcon: Icons.library_books_outlined,
          onChanged: (v) => setState(() => _selectedStream = v),
        ),
        const SizedBox(height: 20),
        CustomDropdown(
          label: 'Academic Year',
          hint: 'Select Year',
          value: _selectedYear,
          items: _years,
          prefixIcon: Icons.calendar_today_outlined,
          onChanged: (v) => setState(() => _selectedYear = v),
        ),
      ],
    );
  }

  Widget _buildSecurityStep() {
    return Column(
      children: [
        CustomTextField(
          label: 'Password',
          hint: 'Create a password',
          controller: _passwordController,
          isPassword: true,
          prefixIcon: Icons.lock_outline,
          validator: Validators.validatePassword,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Confirm Password',
          hint: 'Confirm your password',
          controller: _confirmPasswordController,
          isPassword: true,
          prefixIcon: Icons.lock_outline,
          validator: (v) => Validators.validateConfirmPassword(v, _passwordController.text),
        ),
        const SizedBox(height: 32),
        // Final Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lPrimary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lPrimary.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildSummaryRow(Icons.school, _selectedUniversity ?? ''),
              const Divider(height: 16),
              _buildSummaryRow(Icons.domain, _selectedDepartment ?? ''),
              const Divider(height: 16),
              _buildSummaryRow(Icons.person, _fullNameController.text),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.lPrimary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
