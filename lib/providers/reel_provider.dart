import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/content.dart';
import '../services/data_service.dart';
import '../services/storage_service.dart';
import 'quiz_provider.dart';

class ReelState {
  final List<ReelItem> reels;
  final bool loading;
  final String? error;
  final int currentIndex;
  final Map<String, bool> likes;
  final Map<String, bool> bookmarks;
  final Map<String, bool> muted;
  final FeedProgress stats;

  ReelState({
    List<ReelItem>? reels,
    bool? loading,
    this.error,
    int? currentIndex,
    Map<String, bool>? likes,
    Map<String, bool>? bookmarks,
    Map<String, bool>? muted,
    FeedProgress? stats,
  })  : reels = reels ?? const [],
        loading = loading ?? false,
        currentIndex = currentIndex ?? 0,
        likes = likes ?? const {},
        bookmarks = bookmarks ?? const {},
        muted = muted ?? const {},
        stats = stats ?? FeedProgress();

  ReelState copyWith({
    List<ReelItem>? reels,
    bool? loading,
    String? error,
    int? currentIndex,
    Map<String, bool>? likes,
    Map<String, bool>? bookmarks,
    Map<String, bool>? muted,
    FeedProgress? stats,
  }) {
    return ReelState(
      reels: reels ?? this.reels,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      currentIndex: currentIndex ?? this.currentIndex,
      likes: likes ?? this.likes,
      bookmarks: bookmarks ?? this.bookmarks,
      muted: muted ?? this.muted,
      stats: stats ?? this.stats,
    );
  }
}

class ReelNotifier extends StateNotifier<ReelState> {
  final DataService _dataService;
  final StorageService _storageService;

  ReelNotifier(this._dataService, this._storageService) : super(ReelState()) {
    _loadPersistedData();
    fetchReels();
  }

  Future<void> _loadPersistedData() async {
    final likes = await _storageService.loadReelLikes();
    final bookmarks = await _storageService.loadReelBookmarks();
    final stats = await _storageService.loadReelStats();
    state = state.copyWith(likes: likes, bookmarks: bookmarks, stats: stats);
  }

  Future<void> fetchReels() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final reels = await _dataService.getReels();
      final boundedIndex = state.stats.lastSeenIndex.clamp(0, reels.length - 1);
      state = state.copyWith(
        reels: reels,
        loading: false,
        currentIndex: boundedIndex,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> refreshReels() async {
    state = state.copyWith(loading: true);
    try {
      final reels = await _dataService.refreshReels();
      state = state.copyWith(reels: reels, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void setCurrentIndex(int index) {
    if (index < 0 || index >= state.reels.length) return;
    final bounded = index.clamp(0, state.reels.length - 1);
    state = state.copyWith(
      currentIndex: bounded,
      stats: state.stats.copyWith(
        lastSeenIndex: bounded > state.stats.lastSeenIndex ? bounded : state.stats.lastSeenIndex,
      ),
    );
    _storageService.saveReelStats(state.stats);
  }

  void toggleLike(String reelId) {
    final newLikes = Map<String, bool>.from(state.likes);
    newLikes[reelId] = !(newLikes[reelId] ?? false);
    state = state.copyWith(likes: newLikes);
    _storageService.saveReelLikes(newLikes);
  }

  void toggleBookmark(String reelId) {
    final newBookmarks = Map<String, bool>.from(state.bookmarks);
    if (newBookmarks[reelId] == true) {
      newBookmarks.remove(reelId);
    } else {
      newBookmarks[reelId] = true;
    }
    state = state.copyWith(bookmarks: newBookmarks);
    _storageService.saveReelBookmarks(newBookmarks);
  }

  void toggleMute(String reelId) {
    final newMuted = Map<String, bool>.from(state.muted);
    final current = newMuted[reelId];
    newMuted[reelId] = current == null ? false : !current;
    state = state.copyWith(muted: newMuted);
  }

  void reset() {
    state = state.copyWith(
      likes: {},
      bookmarks: {},
      muted: {},
      stats: FeedProgress(),
    );
    _storageService.saveReelLikes({});
    _storageService.saveReelBookmarks({});
    _storageService.saveReelStats(FeedProgress());
  }
}

final reelProvider = StateNotifierProvider<ReelNotifier, ReelState>((ref) {
  return ReelNotifier(
    ref.read(dataServiceProvider),
    ref.read(storageServiceProvider),
  );
});

