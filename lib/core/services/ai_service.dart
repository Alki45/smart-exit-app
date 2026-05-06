import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AIService {
  late final GenerativeModel _model;
  final bool _isEnabled;

  AIService() : _isEnabled = dotenv.get('AI_ENABLED', fallback: 'false') == 'true' {
    if (_isEnabled) {
      final apiKey = dotenv.get('GEMINI_API_KEY', fallback: '');
      String modelName = dotenv.get('GEMINI_MODEL', fallback: 'gemini-1.5-flash-latest');
      
      // Clean model name (remove 'models/' prefix if user added it, as SDK adds it automatically)
      if (modelName.startsWith('models/')) {
        modelName = modelName.replaceFirst('models/', '');
      }

      if (apiKey.isNotEmpty && apiKey != 'your_free_gemini_api_key_here') {
        try {
          _model = GenerativeModel(
            model: modelName, 
            apiKey: apiKey,
          );
          debugPrint('AI initialized with model: $modelName');
        } catch (e) {
          debugPrint('Error initializing primary model: $e. Falling back to default.');
          _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
        }
      } else {
        debugPrint('Gemini API Key is missing or invalid.');
      }
    }
  }

  bool get isEnabled => _isEnabled;

  /// Extracts detailed course modules from blueprint text using a Schema-First strategy.
  Future<Map<String, dynamic>> extractDetailedCourses(String blueprintText, {String? modelOverride}) async {
    if (!_isEnabled) return {};

    try {
      final prompt = '''
        Act as an Academic Data Extractor for Ethiopian National Exit Exam Blueprints.
        Task: Extract structured data from the provided blueprint text.
        
        Strict Requirements:
        1. Identify the Department.
        2. Identify the Band/Category if mentioned.
        3. Extract all "Themes" and their associated "Courses".
        4. For each Course, extract:
           - Course Name
           - Course Code
           - Credit Hours
           - Item Count
           - Course Share Percentage
           - Learning Outcomes/Topics
        
        Output: Return ONLY valid JSON matching this schema. No preamble.
        
        Schema:
        {
          "department": "string",
          "band": "string",
          "themes": [
            {
              "theme_name": "string",
              "theme_share_percent": number,
              "courses": [
                {
                  "course_name": "string",
                  "course_code": "string",
                  "credit_hours": number,
                  "item_count": number,
                  "course_share_percent": number,
                  "learning_outcomes": ["string"]
                }
              ]
            }
          ]
        }

        Blueprint text:
        $blueprintText
      ''';

      final content = [Content.text(prompt)];
      
      final apiKey = dotenv.get('GEMINI_API_KEY', fallback: '');
      final modelToUse = modelOverride != null 
          ? GenerativeModel(model: modelOverride, apiKey: apiKey)
          : _model;
          
      final response = await modelToUse.generateContent(content);
      
      if (response.text != null) {
        String text = response.text!;
        if (text.contains('{')) {
          String jsonStr = text.substring(text.indexOf('{'), text.lastIndexOf('}') + 1);
          return Map<String, dynamic>.from(json.decode(jsonStr));
        }
      }
    } catch (e) {
      debugPrint('AI Detailed Extraction Error ($modelOverride): $e');
      
      // Fallback chain
      if (modelOverride == null) {
        debugPrint('Retrying with gemini-1.5-flash-latest...');
        return extractDetailedCourses(blueprintText, modelOverride: 'gemini-1.5-flash-latest');
      } else if (modelOverride == 'gemini-1.5-flash-latest') {
        debugPrint('Retrying with gemini-pro...');
        return extractDetailedCourses(blueprintText, modelOverride: 'gemini-pro');
      }
    }
    return {};
  }

  /// Analyzes raw material text to extract key concepts and structured metadata.
  Future<Map<String, dynamic>> analyzeStudyMaterial(String materialText) async {
    if (!_isEnabled) return {};

    final prompt = '''
      Act as an Academic Material Analyst. 
      Analyze the following course material and extract a structured knowledge map.
      
      Requirements:
      1. Identify the Main Subject.
      2. Breakdown the text into key "Topics".
      3. For each Topic, provide a "Summary" and "Key Concepts".
      4. Assign a "DifficultyLevel" (Beginner, Intermediate, Advanced).
      
      Return ONLY valid JSON.
      
      Schema:
      {
        "subject": "string",
        "topics": [
          {
            "title": "string",
            "summary": "string",
            "concepts": ["string", "string"],
            "importance_score": number (0-1)
          }
        ],
        "overall_difficulty": "string"
      }

      Material:
      $materialText
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text != null) {
        String text = response.text!;
        if (text.contains('{')) {
          String jsonStr = text.substring(text.indexOf('{'), text.lastIndexOf('}') + 1);
          return Map<String, dynamic>.from(json.decode(jsonStr));
        }
      }
    } catch (e) {
      debugPrint('Material Analysis Error: $e');
    }
    return {};
  }

  /// Generates quiz questions based on material text and blueprint outcomes.
  Future<String?> generateQuizJson(String materialText, {int count = 10, List<String>? outcomes}) async {
    if (!_isEnabled) return null;

    final outcomesText = outcomes != null && outcomes.isNotEmpty 
      ? "These are the specific Learning Outcomes to cover: ${outcomes.join(', ')}."
      : "Focus on the most important key concepts found in the material.";

    final prompt = '''
      Using the provided Course Material and $outcomesText, generate $count high-quality multiple-choice questions.
      
      Strict Guidelines:
      1. Distribution: ~84% Knowledge, ~10% Skills, ~6% Attitudes.
      2. Mix Cognitive Levels: Remembering (20%), Understanding (30%), Application (30%), Analysis (20%).
      3. Distractors must be plausible but clearly incorrect.
      4. Return ONLY a JSON array.
      
      Format:
      [
        {
          "questionText": "string",
          "options": ["A", "B", "C", "D"],
          "correctAnswerIndex": number,
          "explanation": "string",
          "domain": "Knowledge|Skills|Attitudes",
          "cognitiveLevel": "string"
        }
      ]

      Material:
      $materialText
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text;
    } catch (e) {
      debugPrint('AI Quiz Generation Error: $e');
      return null;
    }
  }
}
