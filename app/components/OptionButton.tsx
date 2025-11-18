import React from "react";
import {
  Pressable,
  StyleSheet,
  Text,
  View,
  ViewStyle,
  AccessibilityRole,
} from "react-native";

import { useAppTheme } from "@theme/index";

type Props = {
  label: string;
  text: string;
  onPress: () => void;
  disabled?: boolean;
  selected?: boolean;
  revealed?: boolean;
  isCorrect?: boolean;
  style?: ViewStyle;
};

export const OptionButton: React.FC<Props> = ({
  label,
  text,
  onPress,
  disabled = false,
  selected = false,
  revealed = false,
  isCorrect = false,
  style,
}) => {
  const theme = useAppTheme();
  const backgroundColor = React.useMemo(() => {
    if (!revealed) {
      return selected ? theme.colors.primary : theme.colors.surface;
    }
    if (isCorrect) {
      return theme.colors.success;
    }
    if (selected && !isCorrect) {
      return theme.colors.error;
    }
    return theme.colors.surfaceAlt;
  }, [
    revealed,
    isCorrect,
    selected,
    theme.colors.error,
    theme.colors.primary,
    theme.colors.success,
    theme.colors.surface,
    theme.colors.surfaceAlt,
  ]);

  const textColor = revealed
    ? theme.colors.background
    : selected
    ? theme.colors.background
    : theme.colors.text;

  return (
    <Pressable
      accessibilityRole={"button" as AccessibilityRole}
      accessibilityState={{ disabled, selected }}
      accessibilityHint="Double tap to choose this answer"
      disabled={disabled}
      onPress={onPress}
      style={({ pressed }) => [
        styles.container,
        {
          backgroundColor,
          borderColor: theme.colors.border,
          opacity: pressed ? 0.8 : 1,
        },
        style,
      ]}
    >
      <View
        style={[
          styles.labelPill,
          {
            backgroundColor: revealed
              ? theme.colors.overlay
              : theme.colors.surfaceAlt,
          },
        ]}
      >
        <Text
          style={[
            styles.labelText,
            { color: theme.colors.text, fontFamily: theme.typography.fontFamily.bold },
          ]}
        >
          {label}
        </Text>
      </View>
      <Text
        style={[
          styles.bodyText,
          {
            color: textColor,
            fontFamily: theme.typography.fontFamily.medium,
          },
        ]}
        accessibilityRole={"text"}
        numberOfLines={3}
        adjustsFontSizeToFit
        minimumFontScale={0.8}
      >
        {text}
      </Text>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  container: {
    minHeight: 64,
    borderRadius: 18,
    paddingHorizontal: 16,
    paddingVertical: 14,
    marginBottom: 12,
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
  },
  labelPill: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: 12,
    alignItems: "center",
    justifyContent: "center",
  },
  labelText: {
    fontSize: 16,
  },
  bodyText: {
    fontSize: 16,
    flex: 1,
  },
});

