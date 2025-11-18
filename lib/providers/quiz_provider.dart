import 'dart:math';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/content.dart';
import '../services/data_service.dart';
import '../services/storage_service.dart';

final _random = Random();
final dataServiceProvider = Provider<DataService>((ref) => DataService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class QuizState {
  final List<QuizItem> quizzes;
  final bool loading;
  final String? error;
  final int currentIndex;
  final Map<String, QuizProgress> answers;
  final Map<String, bool> bookmarks;
  final FeedProgress stats;

  QuizState({
    List<QuizItem>? quizzes,
    bool? loading,
    this.error,
    int? currentIndex,
    Map<String, QuizProgress>? answers,
    Map<String, bool>? bookmarks,
    FeedProgress? stats,
  })  : quizzes = quizzes ?? const [],
        loading = loading ?? false,
        currentIndex = currentIndex ?? 0,
        answers = answers ?? const {},
        bookmarks = bookmarks ?? const {},
        stats = stats ?? FeedProgress();

  QuizState copyWith({
    List<QuizItem>? quizzes,
    bool? loading,
    String? error,
    int? currentIndex,
    Map<String, QuizProgress>? answers,
    Map<String, bool>? bookmarks,
    FeedProgress? stats,
  }) {
    return QuizState(
      quizzes: quizzes ?? this.quizzes,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      bookmarks: bookmarks ?? this.bookmarks,
      stats: stats ?? this.stats,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  final DataService _dataService;
  final StorageService _storageService;

  QuizNotifier(this._dataService, this._storageService) : super(QuizState()) {
    _loadPersistedData();
    fetchQuizzes();
  }

  Future<void> _loadPersistedData() async {
    final answers = await _storageService.loadQuizProgress();
    final bookmarks = await _storageService.loadQuizBookmarks();
    final stats = await _storageService.loadQuizStats();
    state = state.copyWith(answers: answers, bookmarks: bookmarks, stats: stats);
  }

  Future<void> fetchQuizzes() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final quizzes = await _dataService.getQuizzes();
      final randomized = _randomizeQuizzes(quizzes);
      final boundedIndex = state.stats.lastSeenIndex.clamp(0, randomized.length - 1);
      state = state.copyWith(
        quizzes: randomized,
        loading: false,
        currentIndex: boundedIndex,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshQuizzes() async {
    state = state.copyWith(loading: true);
    try {
      final quizzes = await _dataService.refreshQuizzes();
      state = state.copyWith(quizzes: _randomizeQuizzes(quizzes), loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void setCurrentIndex(int index) {
    if (index < 0 || index >= state.quizzes.length) return;
    final bounded = index.clamp(0, state.quizzes.length - 1);
    state = state.copyWith(
      currentIndex: bounded,
      stats: state.stats.copyWith(
        lastSeenIndex: bounded > state.stats.lastSeenIndex ? bounded : state.stats.lastSeenIndex,
      ),
    );
    _storageService.saveQuizStats(state.stats);
  }

  QuizProgress? selectOption(String quizId, QuizOptionID option, int elapsedMs) {
    if (state.answers.containsKey(quizId)) {
      return state.answers[quizId];
    }
    final quiz = state.quizzes.firstWhere((q) => q.id == quizId, orElse: () => state.quizzes.first);
    final isCorrect = quiz.correct == option;
    final progress = QuizProgress(
      quizId: quizId,
      selected: option,
      isCorrect: isCorrect,
      answeredAt: DateTime.now().millisecondsSinceEpoch,
      elapsedMs: elapsedMs,
    );
    final newAnswers = Map<String, QuizProgress>.from(state.answers)..[quizId] = progress;
    final newStats = state.stats.copyWith(
      answered: state.stats.answered + 1,
      correct: state.stats.correct + (isCorrect ? 1 : 0),
      streak: isCorrect ? state.stats.streak + 1 : 0,
      totalTimeMs: state.stats.totalTimeMs + elapsedMs,
      lastSeenIndex: state.currentIndex > state.stats.lastSeenIndex ? state.currentIndex : state.stats.lastSeenIndex,
    );
    state = state.copyWith(answers: newAnswers, stats: newStats);
    _storageService.saveQuizProgress(newAnswers);
    _storageService.saveQuizStats(newStats);
    return progress;
  }

  void toggleBookmark(String quizId) {
    final newBookmarks = Map<String, bool>.from(state.bookmarks);
    if (newBookmarks[quizId] == true) {
      newBookmarks.remove(quizId);
    } else {
      newBookmarks[quizId] = true;
    }
    state = state.copyWith(bookmarks: newBookmarks);
    _storageService.saveQuizBookmarks(newBookmarks);
  }

  void resetProgress() {
    state = state.copyWith(answers: {}, stats: FeedProgress());
    _storageService.saveQuizProgress({});
    _storageService.saveQuizStats(FeedProgress());
  }

  void clearAllAnswers() {
    state = state.copyWith(answers: {});
    _storageService.saveQuizProgress({});
  }

  List<QuizItem> _randomizeQuizzes(List<QuizItem> quizzes) {
    final list = List<QuizItem>.from(quizzes);
    list.shuffle(_random);
    return list;
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(
    ref.read(dataServiceProvider),
    ref.read(storageServiceProvider),
  );
});

