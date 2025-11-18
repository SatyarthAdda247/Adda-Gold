import AsyncStorage from "@react-native-async-storage/async-storage";

import { FeedProgress, QuizProgress } from "@app/types/content";

const KEYS = {
  quizProgress: "@adda-gold/quiz-progress",
  quizBookmarks: "@adda-gold/quiz-bookmarks",
  reelBookmarks: "@adda-gold/reel-bookmarks",
  reelLikes: "@adda-gold/reel-likes",
  feedProgress: "@adda-gold/feed-progress",
  settings: "@adda-gold/settings",
} as const;

export type SettingsPayload = {
  hapticsEnabled: boolean;
  soundEnabled: boolean;
  autoAdvanceDelayMs: number;
  thumbBarPosition: "left" | "right";
};

const defaultSettings: SettingsPayload = {
  hapticsEnabled: true,
  soundEnabled: true,
  autoAdvanceDelayMs: 1500,
  thumbBarPosition: "right",
};

type QuizProgressMap = Record<string, QuizProgress>;
type BookmarkMap = Record<string, boolean>;
type FeedProgressMap = {
  quizzes?: FeedProgress;
  reels?: FeedProgress;
};

const readJSON = async <T>(key: string, fallback: T): Promise<T> => {
  try {
    const value = await AsyncStorage.getItem(key);
    if (!value) {
      return fallback;
    }
    return JSON.parse(value) as T;
  } catch (error) {
    console.warn(`storage.readJSON failure for ${key}`, error);
    return fallback;
  }
};

const writeJSON = async <T>(key: string, value: T): Promise<void> => {
  try {
    await AsyncStorage.setItem(key, JSON.stringify(value));
  } catch (error) {
    console.warn(`storage.writeJSON failure for ${key}`, error);
  }
};

export const storage = {
  loadQuizProgress: () => readJSON<QuizProgressMap>(KEYS.quizProgress, {}),
  saveQuizProgress: (progress: QuizProgressMap) =>
    writeJSON(KEYS.quizProgress, progress),
  loadQuizBookmarks: () => readJSON<BookmarkMap>(KEYS.quizBookmarks, {}),
  saveQuizBookmarks: (bookmarks: BookmarkMap) =>
    writeJSON(KEYS.quizBookmarks, bookmarks),
  loadReelBookmarks: () => readJSON<BookmarkMap>(KEYS.reelBookmarks, {}),
  saveReelBookmarks: (bookmarks: BookmarkMap) =>
    writeJSON(KEYS.reelBookmarks, bookmarks),
  loadReelLikes: () => readJSON<BookmarkMap>(KEYS.reelLikes, {}),
  saveReelLikes: (likes: BookmarkMap) =>
    writeJSON(KEYS.reelLikes, likes),
  loadFeedProgress: () => readJSON<FeedProgressMap>(KEYS.feedProgress, {}),
  saveFeedProgress: (progress: FeedProgressMap) =>
    writeJSON(KEYS.feedProgress, progress),
  loadSettings: () => readJSON<SettingsPayload>(KEYS.settings, defaultSettings),
  saveSettings: (settings: SettingsPayload) =>
    writeJSON(KEYS.settings, settings),
  reset: () => AsyncStorage.multiRemove(Object.values(KEYS)),
};

