import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/searchable_dropdown.dart';
import '../../../../shared/widgets/loading_indicator.dart';
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
  late TextEditingController _bioController;
  
  // Academic information
  Map<String, dynamic> _universityData = {};
  String? _selectedUniversity;
  String? _selectedCollege;
  String? _selectedDepartment;
  String? _selectedStream;
  String? _selectedYear;
  DateTime? _selectedExamDate;
  TimeOfDay? _selectedReminderTime;

  List<String> _universities = [];
  List<String> _colleges = [];
  List<String> _departments = [];
  List<String> _streams = [];
  List<String> _years = [];
  
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _bioController = TextEditingController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/universities.json');
      final data = json.decode(response);
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      
      setState(() {
        _universityData = data;
        _universities = (data['universities'] as List)
            .map((u) => u['name'] as String)
            .toList();
        _years = (data['years'] as List<dynamic>)
            .map((y) => y as String)
            .toList();

        if (user != null) {
          _fullNameController.text = user.fullName;
          _bioController.text = user.bioGoals ?? '';
          _selectedUniversity = user.universityName;
          _selectedCollege = user.college;
          _selectedDepartment = user.department;
          _selectedStream = user.stream;
          _selectedYear = user.academicYear?.toString();
          _selectedExamDate = user.examDate;
          if (user.reminderTime != null) {
            try {
              final parts = user.reminderTime!.split(RegExp(r'[: ]'));
              if (parts.length >= 2) {
                int hour = int.parse(parts[0]);
                final int minute = int.parse(parts[1]);
                if (parts.length == 3 && parts[2].toUpperCase() == 'PM' && hour < 12) hour += 12;
                if (parts.length == 3 && parts[2].toUpperCase() == 'AM' && hour == 12) hour = 0;
                _selectedReminderTime = TimeOfDay(hour: hour, minute: minute);
              }
            } catch (e) {
              debugPrint('Error parsing reminder time: $e');
            }
          }

          if (_selectedUniversity != null) {
            final university = (_universityData['universities'] as List)
                .firstWhere((u) => u['name'] == _selectedUniversity, orElse: () => null);
            if (university != null) {
              _colleges = (university['colleges'] as List).map((c) => c['name'] as String).toList();
              if (_selectedCollege != null) {
                final college = (university['colleges'] as List)
                    .firstWhere((c) => c['name'] == _selectedCollege, orElse: () => null);
                if (college != null) {
                  _departments = (college['departments'] as List).map((d) => d['name'] as String).toList();
                  if (_selectedDepartment != null) {
                    final dept = (college['departments'] as List)
                        .firstWhere((d) => d['name'] == _selectedDepartment, orElse: () => null);
                    if (dept != null) {
                      _streams = (dept['streams'] as List).map((s) => s as String).toList();
                    }
                  }
                }
              }
            }
          }
        }
        _isLoadingData = false;
      });
    } catch (e) {
      debugPrint('Error loading initial profile data: $e');
      setState(() => _isLoadingData = false);
    }
  }

  void _onUniversityChanged(String? value) {
    setState(() {
      _selectedUniversity = value;
      _selectedCollege = null;
      _selectedDepartment = null;
      _selectedStream = null;
      if (value != null) {
        final university = (_universityData['universities'] as List).firstWhere((u) => u['name'] == value);
        _colleges = (university['colleges'] as List).map((c) => c['name'] as String).toList();
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
        final university = (_universityData['universities'] as List).firstWhere((u) => u['name'] == _selectedUniversity);
        final college = (university['colleges'] as List).firstWhere((c) => c['name'] == value);
        _departments = (college['departments'] as List).map((d) => d['name'] as String).toList();
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
      if (value != null && _selectedCollege != null && _selectedUniversity != null) {
        final university = (_universityData['universities'] as List).firstWhere((u) => u['name'] == _selectedUniversity);
        final college = (university['colleges'] as List).firstWhere((c) => c['name'] == _selectedCollege);
        final dept = (college['departments'] as List).firstWhere((d) => d['name'] == value);
        
        final rawStreams = (dept['streams'] as List).map((s) => s as String).toList();
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
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateProfile(
        fullName: _fullNameController.text.trim(),
        universityName: _selectedUniversity,
        universityCollege: _selectedCollege,
        bio: _bioController.text.trim(),
        department: _selectedDepartment,
        stream: _selectedStream,
        academicYear: _selectedYear,
        examDate: _selectedExamDate,
        reminderTime: _selectedReminderTime != null 
            ? '${_selectedReminderTime!.hourOfPeriod.toString().padLeft(2, '0')}:${_selectedReminderTime!.minute.toString().padLeft(2, '0')} ${_selectedReminderTime!.period == DayPeriod.am ? 'AM' : 'PM'}'
            : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editProfile),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.personalInfo, style: AppTextStyles.h3.copyWith(color: AppColors.lPrimary)),
              const SizedBox(height: 16),
              CustomTextField(
                label: AppStrings.fullName,
                controller: _fullNameController,
                prefixIcon: Icons.person,
                validator: (v) => Validators.validateRequired(v, 'Full Name'),
              ),
              const SizedBox(height: 16),
              SearchableDropdown(
                label: 'University',
                items: _universities,
                value: _selectedUniversity,
                hint: 'Select University',
                onChanged: _onUniversityChanged,
                prefixIcon: Icons.school,
              ),
              const SizedBox(height: 16),
              SearchableDropdown(
                label: 'College',
                items: _colleges,
                value: _selectedCollege,
                hint: 'Select College',
                onChanged: _onCollegeChanged,
                prefixIcon: Icons.account_balance,
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
              Text(AppStrings.academicDetails, style: AppTextStyles.h3.copyWith(color: AppColors.lPrimary)),
              const SizedBox(height: 16),
              SearchableDropdown(
                label: AppStrings.department,
                items: _departments,
                value: _selectedDepartment,
                hint: 'Select Department',
                onChanged: _onDepartmentChanged,
                prefixIcon: Icons.domain,
              ),
              const SizedBox(height: 16),
              SearchableDropdown(
                label: AppStrings.stream,
                items: _streams,
                value: _selectedStream,
                hint: 'Select Stream',
                onChanged: (val) => setState(() => _selectedStream = val),
                prefixIcon: Icons.alt_route,
              ),
              const SizedBox(height: 16),
              SearchableDropdown(
                label: AppStrings.academicYear,
                items: _years,
                value: _selectedYear,
                hint: 'Select Year',
                onChanged: (val) => setState(() => _selectedYear = val),
                prefixIcon: Icons.calendar_today,
              ),
              const SizedBox(height: 32),
              Text('Study Goals & Reminders', style: AppTextStyles.h3.copyWith(color: AppColors.lPrimary)),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event, color: AppColors.lPrimary),
                title: Text('National Exit Exam Date', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  _selectedExamDate != null 
                    ? '${_selectedExamDate!.day}/${_selectedExamDate!.month}/${_selectedExamDate!.year}'
                    : 'Not set',
                  style: AppTextStyles.bodySmall,
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedExamDate ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (date != null) setState(() => _selectedExamDate = date);
                  },
                  child: const Text('Set Date'),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.alarm, color: AppColors.lPrimary),
                title: Text('Daily Study Reminder', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  _selectedReminderTime != null 
                    ? _selectedReminderTime!.format(context)
                    : 'Not set',
                  style: AppTextStyles.bodySmall,
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedReminderTime ?? const TimeOfDay(hour: 18, minute: 0),
                    );
                    if (time != null) setState(() => _selectedReminderTime = time);
                  },
                  child: const Text('Set Time'),
                ),
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return CustomButton(
                    text: AppStrings.saveProfile,
                    onPressed: _saveProfile,
                    isLoading: auth.isLoading,
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Logout',
                type: ButtonType.outline,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      title: Text('Logout', style: AppTextStyles.h3),
                      content: Text('Are you sure you want to logout? This will end your current session.', style: AppTextStyles.bodyMedium),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lOutline)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx); // Close dialog
                            Navigator.pop(context); // Close edit screen
                            Provider.of<AuthProvider>(context, listen: false).logout();
                          },
                          child: Text('Logout', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lError, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
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
}
