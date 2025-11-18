import { ColorSchemeName } from "react-native";

export const palette = {
  gold: "#F5C542",
  goldDark: "#C9981A",
  navy: "#1A2433",
  slate: "#2D3648",
  slateLight: "#5C6B82",
  green: "#2ECC71",
  red: "#E74C3C",
  orange: "#FF7F50",
  gray100: "#F7F8FA",
  gray200: "#E5E7EB",
  gray300: "#D1D5DB",
  gray500: "#6B7280",
  gray700: "#374151",
  gray900: "#111827",
  white: "#FFFFFF",
  black: "#000000",
};

export const lightColors = {
  primary: palette.gold,
  primaryMuted: palette.goldDark,
  background: palette.gray100,
  surface: palette.white,
  surfaceAlt: "#FAFAFA",
  text: palette.navy,
  textSecondary: palette.gray500,
  border: palette.gray200,
  success: palette.green,
  error: palette.red,
  muted: palette.gray300,
  reelOverlay: "rgba(17, 24, 39, 0.65)",
  skeletonBase: "#E3E7ED",
  skeletonHighlight: "#F2F5F9",
};

export const darkColors = {
  primary: palette.gold,
  primaryMuted: palette.goldDark,
  background: palette.gray900,
  surface: palette.slate,
  surfaceAlt: "#1F2937",
  text: palette.white,
  textSecondary: palette.gray300,
  border: "rgba(255,255,255,0.08)",
  success: "#3EDC97",
  error: "#FF6B6B",
  muted: "rgba(255,255,255,0.2)",
  reelOverlay: "rgba(0, 0, 0, 0.55)",
  skeletonBase: "#2B3446",
  skeletonHighlight: "#3C475E",
};

export type ThemeColors = typeof lightColors;

export const getThemeColors = (scheme: ColorSchemeName | null): ThemeColors =>
  scheme === "dark" ? darkColors : lightColors;

