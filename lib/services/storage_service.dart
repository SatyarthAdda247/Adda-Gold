import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content.dart';

class StorageService {
  static const String _quizProgressKey = '@adda-gold/quiz-progress';
  static const String _quizBookmarksKey = '@adda-gold/quiz-bookmarks';
  static const String _reelBookmarksKey = '@adda-gold/reel-bookmarks';
  static const String _reelLikesKey = '@adda-gold/reel-likes';
  static const String _quizStatsKey = '@adda-gold/quiz-stats';
  static const String _reelStatsKey = '@adda-gold/reel-stats';
  static const String _settingsKey = '@adda-gold/settings';

  Future<Map<String, QuizProgress>> loadQuizProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_quizProgressKey);
    if (jsonString == null) return {};
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return json.map((key, value) =>
        MapEntry(key, QuizProgress.fromJson(value as Map<String, dynamic>)));
  }

  Future<void> saveQuizProgress(Map<String, QuizProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(progress.map((key, value) => MapEntry(key, value.toJson())));
    await prefs.setString(_quizProgressKey, json);
  }

  Future<Map<String, bool>> loadQuizBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_quizBookmarksKey);
    if (jsonString == null) return {};
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return json.map((key, value) => MapEntry(key, value as bool));
  }

  Future<void> saveQuizBookmarks(Map<String, bool> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quizBookmarksKey, jsonEncode(bookmarks));
  }

  Future<Map<String, bool>> loadReelBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_reelBookmarksKey);
    if (jsonString == null) return {};
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return json.map((key, value) => MapEntry(key, value as bool));
  }

  Future<void> saveReelBookmarks(Map<String, bool> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reelBookmarksKey, jsonEncode(bookmarks));
  }

  Future<Map<String, bool>> loadReelLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_reelLikesKey);
    if (jsonString == null) return {};
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return json.map((key, value) => MapEntry(key, value as bool));
  }

  Future<void> saveReelLikes(Map<String, bool> likes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reelLikesKey, jsonEncode(likes));
  }

  Future<FeedProgress> loadQuizStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_quizStatsKey);
    if (jsonString == null) return FeedProgress();
    return FeedProgress.fromJson(jsonDecode(jsonString));
  }

  Future<void> saveQuizStats(FeedProgress stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quizStatsKey, jsonEncode(stats.toJson()));
  }

  Future<FeedProgress> loadReelStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_reelStatsKey);
    if (jsonString == null) return FeedProgress();
    return FeedProgress.fromJson(jsonDecode(jsonString));
  }

  Future<void> saveReelStats(FeedProgress stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reelStatsKey, jsonEncode(stats.toJson()));
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hapticsEnabled': prefs.getBool('hapticsEnabled') ?? true,
      'soundEnabled': prefs.getBool('soundEnabled') ?? true,
      'autoAdvanceDelayMs': prefs.getInt('autoAdvanceDelayMs') ?? 1500,
      'thumbBarPosition': prefs.getString('thumbBarPosition') ?? 'right',
      'themeMode': prefs.getString('themeMode') ?? 'system',
      'autoScrollEnabled': prefs.getBool('autoScrollEnabled') ?? false,
    };
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticsEnabled', settings['hapticsEnabled'] as bool);
    await prefs.setBool('soundEnabled', settings['soundEnabled'] as bool);
    await prefs.setInt('autoAdvanceDelayMs', settings['autoAdvanceDelayMs'] as int);
    await prefs.setString('thumbBarPosition', settings['thumbBarPosition'] as String);
    await prefs.setString('themeMode', settings['themeMode'] as String);
    await prefs.setBool('autoScrollEnabled', settings['autoScrollEnabled'] as bool);
  }
}

