import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

/// Upload drop-zone card for the Material Lab screen.
class UploadZoneSection extends StatelessWidget {
  const UploadZoneSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Material Lab', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
        const SizedBox(height: 4),
        Text('Convert your study materials into interactive exam modules.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.lOnSurfaceVariant)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.uploadBlueprint),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.lPrimaryContainer, width: 2, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: AppColors.lPrimaryFixed, shape: BoxShape.circle),
                  child: const Icon(Icons.upload_file_rounded, color: AppColors.lPrimary, size: 30),
                ),
                const SizedBox(height: 16),
                Text('Upload PDF Material', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.lPrimary)),
                const SizedBox(height: 8),
                Text(
                  'Drag and drop your lecture notes, textbooks, or research papers.\nOur AI will analyse them for potential exam questions.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.lOnSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.uploadBlueprint),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: StadiumBorder(),
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  child: const Text('Browse Files'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
