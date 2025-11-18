enum QuizOptionID { A, B, C, D }

extension QuizOptionIDExtension on QuizOptionID {
  String get label {
    switch (this) {
      case QuizOptionID.A:
        return 'A';
      case QuizOptionID.B:
        return 'B';
      case QuizOptionID.C:
        return 'C';
      case QuizOptionID.D:
        return 'D';
    }
  }

  static QuizOptionID fromString(String value) {
    switch (value) {
      case 'A':
        return QuizOptionID.A;
      case 'B':
        return QuizOptionID.B;
      case 'C':
        return QuizOptionID.C;
      case 'D':
        return QuizOptionID.D;
      default:
        return QuizOptionID.A;
    }
  }
}

enum Difficulty { easy, medium, hard }

class QuizItem {
  final String id;
  final String category;
  final Difficulty difficulty;
  final String question;
  final Map<QuizOptionID, String> options;
  final QuizOptionID correct;
  final String? explanation;

  QuizItem({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correct,
    this.explanation,
  });

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    final optionsMap = json['options'] as Map<String, dynamic>;
    return QuizItem(
      id: json['id'] as String,
      category: json['category'] as String,
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      question: json['question'] as String,
      options: {
        QuizOptionID.A: optionsMap['A'] as String,
        QuizOptionID.B: optionsMap['B'] as String,
        QuizOptionID.C: optionsMap['C'] as String,
        QuizOptionID.D: optionsMap['D'] as String,
      },
      correct: QuizOptionIDExtension.fromString(json['correct'] as String),
      explanation: json['explanation'] as String?,
    );
  }
}

class ReelItem {
  final String id;
  final String title;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? source;
  final int? durationSec;

  ReelItem({
    required this.id,
    required this.title,
    required this.videoUrl,
    this.thumbnailUrl,
    this.source,
    this.durationSec,
  });

  factory ReelItem.fromJson(Map<String, dynamic> json) {
    return ReelItem(
      id: json['id'] as String,
      title: json['title'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      source: json['source'] as String?,
      durationSec: json['durationSec'] as int?,
    );
  }
}

class QuizProgress {
  final String quizId;
  final QuizOptionID selected;
  final bool isCorrect;
  final int answeredAt;
  final int elapsedMs;

  QuizProgress({
    required this.quizId,
    required this.selected,
    required this.isCorrect,
    required this.answeredAt,
    required this.elapsedMs,
  });

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'selected': selected.label,
      'isCorrect': isCorrect,
      'answeredAt': answeredAt,
      'elapsedMs': elapsedMs,
    };
  }

  factory QuizProgress.fromJson(Map<String, dynamic> json) {
    return QuizProgress(
      quizId: json['quizId'] as String,
      selected: QuizOptionIDExtension.fromString(json['selected'] as String),
      isCorrect: json['isCorrect'] as bool,
      answeredAt: json['answeredAt'] as int,
      elapsedMs: json['elapsedMs'] as int,
    );
  }
}

class FeedProgress {
  final int lastSeenIndex;
  final int streak;
  final int answered;
  final int correct;
  final int totalTimeMs;

  FeedProgress({
    this.lastSeenIndex = 0,
    this.streak = 0,
    this.answered = 0,
    this.correct = 0,
    this.totalTimeMs = 0,
  });

  FeedProgress copyWith({
    int? lastSeenIndex,
    int? streak,
    int? answered,
    int? correct,
    int? totalTimeMs,
  }) {
    return FeedProgress(
      lastSeenIndex: lastSeenIndex ?? this.lastSeenIndex,
      streak: streak ?? this.streak,
      answered: answered ?? this.answered,
      correct: correct ?? this.correct,
      totalTimeMs: totalTimeMs ?? this.totalTimeMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastSeenIndex': lastSeenIndex,
      'streak': streak,
      'answered': answered,
      'correct': correct,
      'totalTimeMs': totalTimeMs,
    };
  }

  factory FeedProgress.fromJson(Map<String, dynamic> json) {
    return FeedProgress(
      lastSeenIndex: json['lastSeenIndex'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      answered: json['answered'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      totalTimeMs: json['totalTimeMs'] as int? ?? 0,
    );
  }
}

