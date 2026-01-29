import 'package:hive/hive.dart';

class ProgressService {
  late final Box _box;

  ProgressService() {
    _box = Hive.box('progressBox');
  }

  // Keys
  static const String _streakKey = 'streak';
  static const String _lastLoginKey = 'lastLoginDate';
  static const String _quizzesTakenKey = 'quizzesTaken';
  static const String _totalScoreKey = 'totalScore';

  /// Updates the user's daily study streak.
  void updateStreak() {
    final lastLoginStr = _box.get(_lastLoginKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastLoginStr == null) {
      // First login ever
      _box.put(_streakKey, 1);
      _box.put(_lastLoginKey, today.toIso8601String());
      return;
    }

    final lastLogin = DateTime.parse(lastLoginStr);
    final lastDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);

    final difference = today.difference(lastDate).inDays;

    if (difference == 1) {
      // Consecutive day
      int currentStreak = _box.get(_streakKey, defaultValue: 0);
      _box.put(_streakKey, currentStreak + 1);
    } else if (difference > 1) {
      // Streak broken
      _box.put(_streakKey, 1);
    }
    // If difference == 0, same day, do nothing.

    _box.put(_lastLoginKey, today.toIso8601String());
  }

  int getStreak() {
    return _box.get(_streakKey, defaultValue: 0);
  }

  void incrementQuizzesTaken(double score) {
    int current = _box.get(_quizzesTakenKey, defaultValue: 0);
    _box.put(_quizzesTakenKey, current + 1);

    double total = _box.get(_totalScoreKey, defaultValue: 0.0);
    _box.put(_totalScoreKey, total + score);
  }

  int getQuizzesTaken() {
    return _box.get(_quizzesTakenKey, defaultValue: 0);
  }

  double getAverageScore() {
    final count = getQuizzesTaken();
    if (count == 0) return 0.0;
    final total = _box.get(_totalScoreKey, defaultValue: 0.0);
    return total / count;
  }
}
