import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../widgets/upload_widgets.dart';
import 'upload_logic.dart';

class UploadBlueprintScreen extends StatefulWidget {
  const UploadBlueprintScreen({Key? key}) : super(key: key);
  @override State<UploadBlueprintScreen> createState() => _UploadBlueprintScreenState();
}

class _UploadBlueprintScreenState extends State<UploadBlueprintScreen> {
  late UploadLogic _logic;
  String? _courseName;

  @override void initState() { 
    super.initState(); 
    
    // Defer reading arguments until after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final courseId = args?['courseId'];
      final departmentId = args?['departmentId'];
      _courseName = args?['courseName'];
      
      _logic = UploadLogic(context, () => setState(() {}), courseId: courseId, departmentId: departmentId);
      setState(() {});
    });
    
    // Initial placeholder logic
    _logic = UploadLogic(context, () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Upload Resource')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        _HeaderIcon(),
        const SizedBox(height: 32),
        Text('Upload Resource', style: AppTextStyles.h2),
        if (_courseName != null) ...[
          const SizedBox(height: 8),
          Text(
            'For: $_courseName',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cyan, fontWeight: FontWeight.bold),
          ),
        ],
        const SizedBox(height: 24),
        TypeToggle(logic: _logic),
        const SizedBox(height: 24),
        StatusArea(
          logic: _logic, name: _logic.fileName, 
          onPick: _logic.pickFile, onClear: _logic.clearFile, 
          onUpload: _logic.upload
        ),
        const SizedBox(height: 32),
        const ManualLink(),
      ]),
    ),
  );
}

class _HeaderIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 100, height: 100,
    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.cardBackground, boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.2), blurRadius: 20)]),
    child: const Icon(Icons.menu_book_rounded, size: 50, color: AppColors.cyan),
  );
}
