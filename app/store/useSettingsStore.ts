import AsyncStorage from "@react-native-async-storage/async-storage";
import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

import { SettingsPayload } from "@services/storage";

type SettingsState = SettingsPayload & {
  setSoundEnabled: (value: boolean) => void;
  setHapticsEnabled: (value: boolean) => void;
  setAutoAdvanceDelayMs: (value: number) => void;
  setThumbBarPosition: (position: "left" | "right") => void;
  reset: () => void;
};

const initialState: SettingsPayload = {
  soundEnabled: true,
  hapticsEnabled: true,
  autoAdvanceDelayMs: 1500,
  thumbBarPosition: "right",
};

export const useSettingsStore = create<SettingsState>()(
  persist(
    (set) => ({
      ...initialState,
      setSoundEnabled: (value) => set({ soundEnabled: value }),
      setHapticsEnabled: (value) => set({ hapticsEnabled: value }),
      setAutoAdvanceDelayMs: (value) =>
        set({ autoAdvanceDelayMs: Math.max(0, value) }),
      setThumbBarPosition: (position) =>
        set({ thumbBarPosition: position }),
      reset: () => set(initialState),
    }),
    {
      name: "@adda-gold/settings",
      version: 1,
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);

