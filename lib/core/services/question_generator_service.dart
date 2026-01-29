import 'dart:math';
import '../../features/quizzes/data/models/question_model.dart';

class QuestionGeneratorService {
  /// Generates a list of questions from the provided [text].
  /// 
  /// This is a "Basic AI" implementation that:
  /// 1. Splits text into sentences.
  /// 2. Filters for sentences that look like definitions or factual statements.
  /// 3. Identifies keywords (capitalized words, terms before 'is', etc.).
  /// 4. Creates a fill-in-the-blank style question.
  Future<List<QuestionModel>> generateQuestions(String text, {int limit = 10}) async {
    final List<QuestionModel> questions = [];
    final Random random = Random();
    
    // 1. Clean and Split Text
    // Normalize spaces and split by sentence terminators.
    final cleanText = text.replaceAll(RegExp(r'\s+'), ' ');
    final sentences = cleanText.split(RegExp(r'(?<=[.!?])\s+'));

    // 2. Identify Potential Keywords (Simple Frequency/Capitalization Analysis)
    // We'll collect all capitalized words (excluding start of sentence) to use as distractors.
    final Set<String> potentialDistractors = {};
    final RegExp capitalizedWord = RegExp(r'\b[A-Z][a-z]+\b');
    
    for (var sentence in sentences) {
      final matches = capitalizedWord.allMatches(sentence);
      for (var match in matches) {
        // Skip if it's the start of the sentence (approximate check)
        if (match.start > 0) {
           potentialDistractors.add(match.group(0)!);
        }
      }
    }

    // 3. Generate Questions
    for (var sentence in sentences) {
      if (questions.length >= limit) break;
      
      if (sentence.length < 20 || sentence.length > 200) continue; // Skip too short/long
      if (sentence.contains('?')) continue; // Skip existing questions

      // Strategy A: "Key Term" masking (matches 'Term is a...')
      final RegExp definitional = RegExp(r'^([A-Z][a-zA-Z\s]+)\s+(is|are|refers to|means)\s+');
      final match = definitional.firstMatch(sentence);

      if (match != null) {
        final term = match.group(1)!.trim();
        final body = sentence.substring(match.end).trim();
        
        // Ensure term is long enough to be a valid answer
        if (term.split(' ').length > 3) continue; 

        final questionText = '___ ${match.group(2)} $body';
        
        // Generate options
        final options = _generateOptions(term, potentialDistractors, random);
        final answerIndex = options.indexOf(term);

        questions.add(QuestionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + questions.length.toString(),
          questionText: questionText,
          options: options,
          correctAnswerIndex: answerIndex,
          explanation: sentence,
        ));
        continue;
      }

      // Strategy B: Keyword Masking (Mask a random significant word)
      // We look for a keyword that is in our distractor list (i.e., a noun/proper noun)
      String? targetWord;
      for (var word in potentialDistractors) {
        if (sentence.contains(word)) {
          targetWord = word;
          break;
        }
      }

      if (targetWord != null) {
        final questionText = sentence.replaceFirst(targetWord, '__________');
        final options = _generateOptions(targetWord, potentialDistractors, random);
        final answerIndex = options.indexOf(targetWord);

        questions.add(QuestionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + questions.length.toString(),
          questionText: questionText,
          options: options,
          correctAnswerIndex: answerIndex,
          explanation: sentence,
        ));
      }
    }

    return questions;
  }

  List<String> _generateOptions(String correctAnswer, Set<String> allDistractors, Random random) {
    final List<String> options = [correctAnswer];
    final List<String> pool = allDistractors.where((d) => d != correctAnswer).toList();
    
    // Add 3 random distractors
    for (int i = 0; i < 3; i++) {
        if (pool.isNotEmpty) {
           final index = random.nextInt(pool.length);
           options.add(pool[index]);
           pool.removeAt(index);
        } else {
            // Fallback if not enough text distractors
            options.add('Option ${String.fromCharCode(66+i)}'); 
        }
    }
    
    options.shuffle(random);
    return options;
  }
}
