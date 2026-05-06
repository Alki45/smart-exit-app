import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/foundation.dart';

class DocumentService {
  /// Extracts text from a PDF file.
  static Future<String> extractTextFromPdf(File file) async {
    try {
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      String text = PdfTextExtractor(document).extractText();
      document.dispose();
      
      return _cleanExtractedText(text);
    } catch (e) {
      debugPrint('Error extracting PDF text: $e');
      rethrow;
    }
  }

  /// Extracts text from PDF bytes (useful for Web).
  static Future<String> extractTextFromBytes(Uint8List bytes) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      String text = PdfTextExtractor(document).extractText();
      document.dispose();
      
      return _cleanExtractedText(text);
    } catch (e) {
      debugPrint('Error extracting PDF bytes: $e');
      rethrow;
    }
  }

  /// Cleans the extracted text by removing redundant whitespace and common artifacts.
  static String _cleanExtractedText(String text) {
    return text
        .replaceAll(RegExp(r'\r\n'), '\n')
        .replaceAll(RegExp(r' {2,}'), ' ') // Remove multiple spaces
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Normalize multiple newlines
        .trim();
  }
}
