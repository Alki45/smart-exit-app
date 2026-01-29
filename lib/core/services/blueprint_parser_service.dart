class BlueprintParserService {
  /// Extracts potential course names from the blueprint [text].
  ///
  /// This uses basic heuristics:
  /// 1. Look for lines that start with capitalized words.
  /// 2. Look for keywords like "Course", "Introduction", "Engineering", "System", "Programming".
  /// 3. Ignore short lines or common headers.
  List<String> extractCourses(String text) {
    final List<String> courses = [];
    final lines = text.split('\n');
    
    // Keywords often found in course titles
    final courseKeywords = [
      'Introduction', 'Engineering', 'Systems', 'Programming', 'Network',
      'Database', 'Signal', 'Communication', 'Electronics', 'Power',
      'Control', 'Algorithm', 'Data Structure', 'Architecture', 'Logic'
    ];
    
    // Regex for numbered lists often used in blueprints (e.g. "1. Course Name")
    final numberedCourse = RegExp(r'^\d+\.\s+([A-Z][a-zA-Z\s]+)');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      // Filter out likely headers/footers
      if (line.toLowerCase().contains('assosa university')) continue;
      if (line.toLowerCase().contains('page')) continue;

      // Strategy A: Numbered list detection
      final match = numberedCourse.firstMatch(line);
      if (match != null) {
        courses.add(match.group(1)!.trim());
        continue;
      }

      // Strategy B: Keyword matching
      bool hasKeyword = false;
      for (var keyword in courseKeywords) {
        if (line.contains(keyword)) {
          hasKeyword = true;
          break;
        }
      }

      if (hasKeyword && line.length > 10 && line.length < 60) {
        // Clean up common prefixes
        String cleaned = line.replaceAll(RegExp(r'^[-•*]\s*'), '');
        // Avoid duplicates
        if (!courses.contains(cleaned)) {
           courses.add(cleaned);
        }
      }
    }

    // Fallback if no specific courses found (for testing with generic text)
    if (courses.isEmpty) {
        // Just return a dummy list if it looks completely empty, or maybe the user uploaded wrong file
        // But for "Basic AI", we return nothing and let UI handle "0 courses found".
    }

    return courses;
  }
}
