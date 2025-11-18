import AsyncStorage from "@react-native-async-storage/async-storage";
import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import { dataService } from "@services/dataService";
import {
  FeedProgress,
  QuizItem,
  QuizOptionID,
  QuizProgress,
} from "@app/types/content";
import { createQuizProgress, updateFeedStats } from "@store/quizLogic";

type QuizStoreState = {
  quizzes: QuizItem[];
  loading: boolean;
  error: string | null;
  currentIndex: number;
  answers: Record<string, QuizProgress>;
  bookmarks: Record<string, boolean>;
  stats: FeedProgress;
  fetchQuizzes: () => Promise<void>;
  refreshQuizzes: () => Promise<void>;
  selectOption: (params: {
    quizId: string;
    option: QuizOptionID;
    elapsedMs: number;
  }) => QuizProgress | null;
  setCurrentIndex: (index: number) => void;
  toggleBookmark: (quizId: string) => void;
  resetProgress: () => void;
};

const INITIAL_STATS: FeedProgress = {
  answered: 0,
  correct: 0,
  streak: 0,
  totalTimeMs: 0,
  lastSeenIndex: 0,
};

export const useQuizStore = create<QuizStoreState>()(
  persist(
    (set, get) => ({
      quizzes: [],
      loading: false,
      error: null,
      currentIndex: 0,
      answers: {},
      bookmarks: {},
      stats: INITIAL_STATS,
      fetchQuizzes: async () => {
        try {
          set({ loading: true, error: null });
          const data = await dataService.getQuizzes();
          const { stats } = get();
          const boundedIndex = Math.min(
            stats.lastSeenIndex,
            Math.max(data.length - 1, 0)
          );
          set({
            quizzes: data,
            currentIndex: boundedIndex,
            loading: false,
          });
        } catch (error) {
          set({
            loading: false,
            error:
              error instanceof Error
                ? error.message
                : "Failed to load quizzes",
          });
        }
      },
      refreshQuizzes: async () => {
        try {
          set({ loading: true });
          const data = await dataService.refreshQuizzes();
          set({ quizzes: data, loading: false });
        } catch (error) {
          set({
            loading: false,
            error:
              error instanceof Error
                ? error.message
                : "Failed to refresh quizzes",
          });
        }
      },
      selectOption: ({ quizId, option, elapsedMs }) => {
        const state = get();
        if (state.answers[quizId]) {
          return state.answers[quizId];
        }
        const quiz = state.quizzes.find((item) => item.id === quizId);
        if (!quiz) {
          return null;
        }
        const answer = createQuizProgress(quiz, option, elapsedMs);
        const updatedAnswers = {
          ...state.answers,
          [quizId]: answer,
        };
        const newStats = updateFeedStats(
          state.stats,
          answer.isCorrect,
          elapsedMs,
          state.currentIndex
        );
        set({ answers: updatedAnswers, stats: newStats });
        return answer;
      },
      setCurrentIndex: (index: number) => {
        const state = get();
        const bounded = Math.max(0, Math.min(index, state.quizzes.length - 1));
        if (bounded === state.currentIndex) {
          return;
        }
        set({
          currentIndex: bounded,
          stats: {
            ...state.stats,
            lastSeenIndex: Math.max(bounded, state.stats.lastSeenIndex),
          },
        });
      },
      toggleBookmark: (quizId: string) => {
        const { bookmarks } = get();
        const updated = { ...bookmarks };
        if (updated[quizId]) {
          delete updated[quizId];
        } else {
          updated[quizId] = true;
        }
        set({ bookmarks: updated });
      },
      resetProgress: () => {
        set({ answers: {}, stats: INITIAL_STATS });
      },
    }),
    {
      name: "@adda-gold/quiz-store",
      version: 1,
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        answers: state.answers,
        bookmarks: state.bookmarks,
        stats: state.stats,
        currentIndex: state.currentIndex,
      }),
      merge: (persistedState, currentState) => ({
        ...currentState,
        ...persistedState,
        quizzes: currentState.quizzes,
        loading: currentState.loading,
        error: currentState.error,
      }),
    }
  )
);
