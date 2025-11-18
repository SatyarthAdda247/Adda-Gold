import AsyncStorage from "@react-native-async-storage/async-storage";
import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import { dataService } from "@services/dataService";
import { FeedProgress, ReelItem } from "@app/types/content";

type ReelStoreState = {
  reels: ReelItem[];
  loading: boolean;
  error: string | null;
  currentIndex: number;
  likes: Record<string, boolean>;
  bookmarks: Record<string, boolean>;
  muted: Record<string, boolean>;
  stats: FeedProgress;
  fetchReels: () => Promise<void>;
  refreshReels: () => Promise<void>;
  setCurrentIndex: (index: number) => void;
  toggleLike: (reelId: string) => void;
  toggleBookmark: (reelId: string) => void;
  toggleMute: (reelId: string) => boolean;
  reset: () => void;
};

const INITIAL_STATS: FeedProgress = {
  answered: 0,
  correct: 0,
  totalTimeMs: 0,
  streak: 0,
  lastSeenIndex: 0,
};

export const useReelStore = create<ReelStoreState>()(
  persist(
    (set, get) => ({
      reels: [],
      loading: false,
      error: null,
      currentIndex: 0,
      likes: {},
      bookmarks: {},
      muted: {},
      stats: INITIAL_STATS,
      fetchReels: async () => {
        try {
          set({ loading: true, error: null });
          const data = await dataService.getReels();
          const { stats } = get();
          const boundedIndex = Math.min(
            stats.lastSeenIndex,
            Math.max(data.length - 1, 0)
          );
          set({
            reels: data,
            currentIndex: boundedIndex,
            loading: false,
          });
        } catch (error) {
          set({
            loading: false,
            error:
              error instanceof Error
                ? error.message
                : "Failed to load reels",
          });
        }
      },
      refreshReels: async () => {
        try {
          set({ loading: true });
          const data = await dataService.refreshReels();
          set({
            reels: data,
            loading: false,
          });
        } catch (error) {
          set({
            loading: false,
            error:
              error instanceof Error
                ? error.message
                : "Failed to refresh reels",
          });
        }
      },
      setCurrentIndex: (index: number) => {
        const state = get();
        const bounded = Math.max(0, Math.min(index, state.reels.length - 1));
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
      toggleLike: (reelId: string) => {
        const { likes } = get();
        const updated = { ...likes, [reelId]: !likes[reelId] };
        set({ likes: updated });
      },
      toggleBookmark: (reelId: string) => {
        const { bookmarks } = get();
        const updated = { ...bookmarks };
        if (updated[reelId]) {
          delete updated[reelId];
        } else {
          updated[reelId] = true;
        }
        set({ bookmarks: updated });
      },
      toggleMute: (reelId: string) => {
        const { muted } = get();
        const current = muted[reelId];
        const next = current === undefined ? false : !current;
        set({
          muted: {
            ...muted,
            [reelId]: next,
          },
        });
        return next;
      },
      reset: () => {
        set({
          likes: {},
          bookmarks: {},
          muted: {},
          stats: INITIAL_STATS,
        });
      },
    }),
    {
      name: "@adda-gold/reel-store",
      version: 1,
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        likes: state.likes,
        bookmarks: state.bookmarks,
        muted: state.muted,
        stats: state.stats,
        currentIndex: state.currentIndex,
      }),
      merge: (persisted, current) => ({
        ...current,
        ...persisted,
        reels: current.reels,
        loading: current.loading,
        error: current.error,
      }),
    }
  )
);

