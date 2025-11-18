import { QuizItem, ReelItem } from "@app/types/content";

import quizzesMock from "@mock/quizzes.json";
import reelsMock from "@mock/reels.json";

type DataState<T> = {
  cache: T[] | null;
  lastFetched: number | null;
};

const QUIZ_STATE: DataState<QuizItem> = {
  cache: null,
  lastFetched: null,
};

const REEL_STATE: DataState<ReelItem> = {
  cache: null,
  lastFetched: null,
};

const MOCK_NETWORK_DELAY = 180;

const toQuizItems = (data: unknown): QuizItem[] => {
  return (data as QuizItem[]).map((item) => ({
    ...item,
    options: {
      A: item.options.A,
      B: item.options.B,
      C: item.options.C,
      D: item.options.D,
    },
  }));
};

const toReelItems = (data: unknown): ReelItem[] => {
  return data as ReelItem[];
};

const simulateNetwork = async () =>
  new Promise((resolve) => setTimeout(resolve, MOCK_NETWORK_DELAY));

export const dataService = {
  getQuizzes: async (): Promise<QuizItem[]> => {
    if (QUIZ_STATE.cache) {
      return QUIZ_STATE.cache;
    }
    await simulateNetwork();
    const parsed = toQuizItems(quizzesMock);
    QUIZ_STATE.cache = parsed;
    QUIZ_STATE.lastFetched = Date.now();
    return parsed;
  },
  getReels: async (): Promise<ReelItem[]> => {
    if (REEL_STATE.cache) {
      return REEL_STATE.cache;
    }
    await simulateNetwork();
    const parsed = toReelItems(reelsMock);
    REEL_STATE.cache = parsed;
    REEL_STATE.lastFetched = Date.now();
    return parsed;
  },
  refreshQuizzes: async (): Promise<QuizItem[]> => {
    await simulateNetwork();
    const parsed = toQuizItems(quizzesMock);
    QUIZ_STATE.cache = parsed;
    QUIZ_STATE.lastFetched = Date.now();
    return parsed;
  },
  refreshReels: async (): Promise<ReelItem[]> => {
    await simulateNetwork();
    const parsed = toReelItems(reelsMock);
    REEL_STATE.cache = parsed;
    REEL_STATE.lastFetched = Date.now();
    return parsed;
  },
};

