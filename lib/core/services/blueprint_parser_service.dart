import 'package:flutter/foundation.dart';
import 'ai_service.dart';

class BlueprintParserService {
  final AIService _aiService = AIService();
  /// Extracts potential course names from the blueprint [text].
  ///
  /// This uses basic heuristics:
  /// 1. Look for lines that start with capitalized words.
  /// 2. Look for keywords like "Course", "Introduction", "Engineering", "System", "Programming".
  /// 3. Ignore short lines or common headers.
  Future<List<Map<String, dynamic>>> extractCourses(String text) async {
    if (_aiService.isEnabled) {
      try {
        final Map<String, dynamic> aiResult = await _aiService.extractDetailedCourses(text);
        if (aiResult.isNotEmpty && aiResult.containsKey('themes')) {
          final List<Map<String, dynamic>> flattenedCourses = [];
          final themes = aiResult['themes'] as List;
          final band = aiResult['band']?.toString();
          
          for (var theme in themes) {
            final courses = theme['courses'] as List;
            for (var course in courses) {
              flattenedCourses.add({
                ...Map<String, dynamic>.from(course),
                'theme_name': theme['theme_name'],
                'theme_share_percent': theme['theme_share_percent'],
                'band': band,
              });
            }
          }
          return flattenedCourses;
        }
        debugPrint('AI returned empty or invalid schema, falling back to heuristics.');
      } catch (e) {
        debugPrint('AI extraction failed, falling back to heuristics: $e');
      }
    }

    // Fallback to basic heuristics
    final List<Map<String, String>> courseData = _extractCoursesHeuristic(text);
    
    if (courseData.isEmpty) {
      // Safeguard: If heuristics completely fail (e.g., poor OCR or non-standard format),
      // provide a default module rather than throwing a fatal exception.
      courseData.add({
        'name': 'General Study Module',
        'theme': 'General Core'
      });
    }
    
    return courseData.map((data) => {
      'course_name': data['name'],
      'course_code': 'C${courseData.indexOf(data) + 1}',
      'credit_hours': 3,
      'theme_name': data['theme'] ?? 'General',
      'course_share_percent': 0.0,
      'item_count': 5,
      'learning_domains': ['Knowledge'],
      'learning_outcomes': [],
    }).toList();
  }

  List<Map<String, String>> _extractCoursesHeuristic(String text) {
    final List<Map<String, String>> courses = [];
    final lines = text.split('\n');
    
    // Expanded keywords covering many Ethiopian Engineering/Science curricula
    final courseKeywords = [
      // Computer Science / Software Engineering
      'Fundamentals of Programming', 'Object Oriented Programming', 'Algorithms',
      'Data Structure', 'Software Engineering', 'Database Systems', 'Project Management',
      'Digital Logic Design', 'Operating System', 'Intelligent Systems', 'Artificial Intelligence',
      'Computer Networking', 'Formal Language', 'Automata Theory', 'Data Communication',
      'Computer Organization', 'Architecture', 'Complexity', 'Compiler', 'Network Security',
      'Web Programming', 'Mobile Application', 'Human Computer Interaction', 'Cloud Computing',
      'Distributed Systems',
      // Electrical & Computer Engineering
      'Applied Electronics', 'Signals and System Analysis', 'Network Analysis and Synthesis',
      'Microcomputers and Interfacing', 'Embedded Systems', 'Microwave Devices', 'Antennas',
      'Wireless and Mobile Communication', 'Control Engineering', 'Power Systems',
      'Electrical Machines', 'Electronic Circuit', 'Communication System',
      // Industrial Chemistry
      'Organic Chemistry', 'Analytical Chemistry', 'Inorganic Chemistry', 'Physical Chemistry',
      'Applied Chemistry', 'Chemical Engineering Basics', 'Fluid Mechanics', 'Fluid Machines',
      'Mechanical Unit Operations', 'Thermal and Mass Transfer', 'Process Technology',
      'Process Engineering', 'Instrumental Analysis', 'Chemical Kinetics', 'Electrochemistry',
      'Polymer Chemistry', 'Industrial Polymer'
    ];
    
    String? currentTheme;
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.length < 5) continue;

      // Detection of Theme lines (usually shorter, bold-like, or end with percentage)
      if (line.contains('%') && line.length < 50 && !line.contains('Course')) {
        currentTheme = line.split(RegExp(r'\d')).first.replaceAll('(', '').trim();
      }
      
      // Pattern 1: Known course keywords (case insensitive partial match)
      for (var keyword in courseKeywords) {
        if (line.toLowerCase().contains(keyword.toLowerCase())) {
          // Verify it's not just a passing mention
          if (line.length < keyword.length + 20) { 
            if (!courses.any((c) => c['name'] == keyword)) {
              courses.add({'name': keyword, 'theme': currentTheme ?? 'General'});
              break; 
            }
          }
        }
      }

      // Pattern 2: Table entries like "Course Name | Code | 3 | 12.5%" or "Course Name 3 5.0"
      final tableRowPattern = RegExp(r'^([A-Z][a-zA-Z\s\(\)]{8,60})\s+([A-Z]{2,4}\d{3,4})?\s*([2345])\s+');
      final match = tableRowPattern.firstMatch(line);
      if (match != null) {
        final name = match.group(1)!.trim();
        if (!_isCommonHeader(name)) {
          if (!courses.any((c) => c['name'] == name)) {
            courses.add({'name': name, 'theme': currentTheme ?? 'General'});
          }
        }
      }
      
      // Pattern 3: Bullet points or numbered lists
      final listPattern = RegExp(r'^(\d+\.|\-|\u2022)\s+([A-Z][a-zA-Z\s\(\)]{8,60})');
      final listMatch = listPattern.firstMatch(line);
      if (listMatch != null) {
        final name = listMatch.group(2)!.trim();
        if (!courses.any((c) => c['name'] == name) && name.split(' ').length > 1) {
          if (!_isCommonHeader(name)) {
            courses.add({'name': name, 'theme': currentTheme ?? 'General'});
          }
        }
      }

      // Pattern 4: Loose lines that look like course titles (start with capitalized words, moderate length)
      if (line.split(' ').length >= 2 && line.split(' ').length <= 6) {
        if (RegExp(r'^[A-Z]').hasMatch(line) && !line.endsWith('.') && !line.endsWith(':')) {
           // Check if it contains keywords but was missed by Pattern 1
           if (courseKeywords.any((k) => line.toLowerCase().contains(k.toLowerCase().split(' ').first))) {
             if (!_isCommonHeader(line) && !courses.any((c) => c['name'] == line)) {
               courses.add({'name': line, 'theme': currentTheme ?? 'General'});
             }
           }
        }
      }
    }
    
    return courses;
  }

  bool _isCommonHeader(String name) {
    final n = name.toUpperCase();
    return n.contains('COURSE') || n.contains('TITLE') || n.contains('DEPARTMENT') || 
           n.contains('UNIVERSITY') || n.contains('BLUEPRINT') || n.contains('ANNEX') ||
           n.contains('TABLE') || n.contains('COMPETENCY') || n.contains('DOMAIN') ||
           n.contains('OUTCOME');
  }
}
