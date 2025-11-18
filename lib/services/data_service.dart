import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/content.dart';

class DataService {
  static List<QuizItem>? _quizCache;
  static List<ReelItem>? _reelCache;

  Future<List<QuizItem>> getQuizzes() async {
    if (_quizCache != null) return _quizCache!;
    await Future.delayed(const Duration(milliseconds: 180));
    final String assetPath = kIsWeb ? 'assets/assets/quizzes.json' : 'assets/quizzes.json';
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _quizCache = jsonList.map((json) => QuizItem.fromJson(json)).toList();
      return _quizCache!;
    } catch (e) {
      // Fallback to try the other path
      final String fallbackPath = kIsWeb ? 'assets/quizzes.json' : 'assets/assets/quizzes.json';
      try {
        final String jsonString = await rootBundle.loadString(fallbackPath);
        final List<dynamic> jsonList = json.decode(jsonString);
        _quizCache = jsonList.map((json) => QuizItem.fromJson(json)).toList();
        return _quizCache!;
      } catch (_) {
        return [];
      }
    }
  }

  Future<List<ReelItem>> getReels() async {
    if (_reelCache != null) return _reelCache!;
    await Future.delayed(const Duration(milliseconds: 180));
    final String assetPath = kIsWeb ? 'assets/assets/reels.json' : 'assets/reels.json';
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _reelCache = jsonList.map((json) => ReelItem.fromJson(json)).toList();
      return _reelCache!;
    } catch (e) {
      // Fallback to try the other path
      final String fallbackPath = kIsWeb ? 'assets/reels.json' : 'assets/assets/reels.json';
      try {
        final String jsonString = await rootBundle.loadString(fallbackPath);
        final List<dynamic> jsonList = json.decode(jsonString);
        _reelCache = jsonList.map((json) => ReelItem.fromJson(json)).toList();
        return _reelCache!;
      } catch (_) {
        return [];
      }
    }
  }

  Future<List<QuizItem>> refreshQuizzes() async {
    await Future.delayed(const Duration(milliseconds: 180));
    final String assetPath = kIsWeb ? 'assets/assets/quizzes.json' : 'assets/quizzes.json';
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _quizCache = jsonList.map((json) => QuizItem.fromJson(json)).toList();
      return _quizCache!;
    } catch (e) {
      final String fallbackPath = kIsWeb ? 'assets/quizzes.json' : 'assets/assets/quizzes.json';
      try {
        final String jsonString = await rootBundle.loadString(fallbackPath);
        final List<dynamic> jsonList = json.decode(jsonString);
        _quizCache = jsonList.map((json) => QuizItem.fromJson(json)).toList();
        return _quizCache!;
      } catch (_) {
        return [];
      }
    }
  }

  Future<List<ReelItem>> refreshReels() async {
    await Future.delayed(const Duration(milliseconds: 180));
    final String assetPath = kIsWeb ? 'assets/assets/reels.json' : 'assets/reels.json';
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _reelCache = jsonList.map((json) => ReelItem.fromJson(json)).toList();
      return _reelCache!;
    } catch (e) {
      final String fallbackPath = kIsWeb ? 'assets/reels.json' : 'assets/assets/reels.json';
      try {
        final String jsonString = await rootBundle.loadString(fallbackPath);
        final List<dynamic> jsonList = json.decode(jsonString);
        _reelCache = jsonList.map((json) => ReelItem.fromJson(json)).toList();
        return _reelCache!;
      } catch (_) {
        return [];
      }
    }
  }
}

