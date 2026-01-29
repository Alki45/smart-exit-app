import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _universityController;
  late TextEditingController _bioController;
  
  // Dropdown values
  String? _selectedDepartment;
  String? _selectedStream;
  String? _selectedYear;

  // Mock Data for Dropdowns
  final List<String> _departments = [
    'Electrical & Computer Engineering',
    'Civil Engineering',
    'Mechanical Engineering',
    'Software Engineering',
  ];

  final List<String> _streams = [
    'Computer Stream',
    'Communication Stream',
    'Power Stream',
    'Control Stream',
  ];

  final List<String> _years = [
    '2024',
    '2025',
    '2026',
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _universityController = TextEditingController(text: user?.universityName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _selectedDepartment = user?.department;
    _selectedStream = user?.stream;
    _selectedYear = user?.academicYear;

    // Check if dropdown values valid, if not reset or add logic (omitted for simplicity)
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _universityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.updateProfile(
        fullName: _fullNameController.text.trim(),
        universityName: _universityController.text.trim(),
        bio: _bioController.text.trim(),
        department: _selectedDepartment,
        stream: _selectedStream,
        academicYear: _selectedYear,
      );

      if (success && mounted) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Go back
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editProfile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Personal Info
              Text(
                AppStrings.personalInfo,
                style: AppTextStyles.h4.copyWith(color: AppColors.cyan),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                label: AppStrings.fullName,
                controller: _fullNameController,
                prefixIcon: Icons.person,
                validator: (v) => Validators.validateRequired(v, 'Full Name'),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                label: AppStrings.universityName,
                controller: _universityController,
                prefixIcon: Icons.school,
                hint: 'e.g. Assosa University',
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                label: AppStrings.bioGoals,
                controller: _bioController,
                prefixIcon: Icons.notes,
                hint: 'Share your goals...',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Section: Academic Details
              Text(
                AppStrings.academicDetails,
                style: AppTextStyles.h4.copyWith(color: AppColors.cyan),
              ),
              const SizedBox(height: 16),

              _buildDropdown(
                label: AppStrings.department,
                value: _selectedDepartment,
                items: _departments,
                icon: Icons.domain,
                onChanged: (val) => setState(() => _selectedDepartment = val),
              ),
              const SizedBox(height: 16),

              _buildDropdown(
                label: AppStrings.stream,
                value: _selectedStream,
                items: _streams,
                icon: Icons.alt_route,
                onChanged: (val) => setState(() => _selectedStream = val),
              ),
              const SizedBox(height: 16),

              _buildDropdown(
                label: AppStrings.academicYear,
                value: _selectedYear,
                items: _years,
                icon: Icons.calendar_today,
                onChanged: (val) => setState(() => _selectedYear = val),
              ),
              const SizedBox(height: 32),

              // Save Button
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return CustomButton(
                    text: AppStrings.saveProfile,
                    onPressed: _saveProfile,
                    isLoading: auth.isLoading,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary),
              dropdownColor: AppColors.cardBackground,
              style: AppTextStyles.bodyLarge,
              hint: Row(
                children: [
                   Icon(icon, color: AppColors.textTertiary, size: 20),
                   const SizedBox(width: 12),
                   Text('Select $label', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
                ],
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, color: AppColors.textTertiary, size: 20),
                      const SizedBox(width: 12),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
