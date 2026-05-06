import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/foundation.dart';

class FilePickerService {
  /// Picks a PDF file and returns its text content.
  Future<String?> pickAndExtractText() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase();

        if (extension == 'pdf') {
          return _extractTextFromPdf(file);
        } else {
          return await file.readAsString();
        }
      }
    } catch (e) {
      debugPrint('File Picking/Extraction Error: $e');
    }
    return null;
  }

  String _extractTextFromPdf(File file) {
    try {
      final PdfDocument document = PdfDocument(inputBytes: file.readAsBytesSync());
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      document.dispose();
      return text;
    } catch (e) {
      debugPrint('PDF Extraction Error: $e');
      return '';
    }
  }
}
