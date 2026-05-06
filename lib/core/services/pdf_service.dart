import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  /// Extracts all text from a PDF file.
  Future<String> extractText({String? path, Uint8List? bytes}) async {
    try {
      List<int> inputBytes;
      if (bytes != null) {
        inputBytes = bytes;
      } else if (path != null) {
        final File file = File(path);
        inputBytes = await file.readAsBytes();
      } else {
        throw Exception("No file data provided");
      }

      final PdfDocument document = PdfDocument(inputBytes: inputBytes);

      // Create a new instance of the PdfTextExtractor.
      PdfTextExtractor extractor = PdfTextExtractor(document);

      // Extract all the text from the document.
      String text = extractor.extractText();

      // Dispose the document.
      document.dispose();

      return text;
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }
}
