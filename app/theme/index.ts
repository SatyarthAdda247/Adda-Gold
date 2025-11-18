import { DefaultTheme, DarkTheme, Theme } from "@react-navigation/native";
import { useColorScheme } from "react-native";

import { getThemeColors, ThemeColors } from "./colors";
import { spacing } from "./spacing";
import { typography } from "./typography";

export interface AppTheme extends Theme {
  colors: Theme["colors"] &
    ThemeColors & {
      cardBackground: string;
      overlay: string;
    };
  spacing: typeof spacing;
  typography: typeof typography;
  radius: {
    sm: number;
    md: number;
    lg: number;
    full: number;
  };
}

const baseThemeProps = {
  spacing,
  typography,
  radius: {
    sm: 8,
    md: 12,
    lg: 16,
    full: 999,
  },
};

export const buildNavigationTheme = (scheme: "light" | "dark"): AppTheme => {
  const colors = getThemeColors(scheme);
  const navigationBase = scheme === "dark" ? DarkTheme : DefaultTheme;
  return {
    ...navigationBase,
    colors: {
      ...navigationBase.colors,
      ...colors,
      card: colors.surface,
      background: colors.background,
      text: colors.text,
      primary: colors.primary,
      border: colors.border,
      notification: colors.primary,
      cardBackground: colors.surface,
      overlay: scheme === "dark" ? "rgba(0,0,0,0.7)" : "rgba(0,0,0,0.45)",
    },
    ...baseThemeProps,
  };
};

export const useAppTheme = (): AppTheme => {
  const scheme = useColorScheme() === "dark" ? "dark" : "light";
  return buildNavigationTheme(scheme);
};

export { spacing } from "./spacing";
export { typography } from "./typography";
export { getThemeColors } from "./colors";

