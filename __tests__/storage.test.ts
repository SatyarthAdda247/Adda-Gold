import AsyncStorage from "@react-native-async-storage/async-storage";

import { storage, SettingsPayload } from "@services/storage";
import { FeedProgress, QuizProgress } from "@app/types/content";

const sampleProgress: Record<string, QuizProgress> = {
  "quiz-1": {
    quizId: "quiz-1",
    selected: "A",
    isCorrect: false,
    elapsedMs: 1500,
    answeredAt: 111,
  },
  "quiz-2": {
    quizId: "quiz-2",
    selected: "B",
    isCorrect: true,
    elapsedMs: 1200,
    answeredAt: 222,
  },
};

const feedStats: FeedProgress = {
  answered: 2,
  correct: 1,
  streak: 1,
  totalTimeMs: 2700,
  lastSeenIndex: 4,
};

describe("storage service", () => {
  beforeEach(async () => {
    await AsyncStorage.clear();
  });

  it("persists and retrieves quiz progress", async () => {
    await storage.saveQuizProgress(sampleProgress);
    const loaded = await storage.loadQuizProgress();
    expect(loaded).toEqual(sampleProgress);
  });

  it("persists bookmarks maps", async () => {
    await storage.saveQuizBookmarks({ "quiz-1": true });
    const loaded = await storage.loadQuizBookmarks();
    expect(loaded).toEqual({ "quiz-1": true });
  });

  it("persists feed progress", async () => {
    await storage.saveFeedProgress({ quizzes: feedStats });
    const loaded = await storage.loadFeedProgress();
    expect(loaded.quizzes).toEqual(feedStats);
  });

  it("returns default settings and allows override", async () => {
    const defaultSettings = await storage.loadSettings();
    expect(defaultSettings.hapticsEnabled).toBe(true);
    const override: SettingsPayload = {
      hapticsEnabled: false,
      soundEnabled: false,
      autoAdvanceDelayMs: 900,
      thumbBarPosition: "left",
    };
    await storage.saveSettings(override);
    const loaded = await storage.loadSettings();
    expect(loaded).toEqual(override);
  });
});

