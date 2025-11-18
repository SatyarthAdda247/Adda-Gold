import React from "react";
import {
  Pressable,
  StyleSheet,
  Text,
  View,
  AccessibilityRole,
} from "react-native";

import { QuizOptionID } from "@app/types/content";
import { useAppTheme } from "@theme/index";

type Props = {
  onSelect: (option: QuizOptionID) => void;
  selected?: QuizOptionID | null;
  disabled?: boolean;
  position?: "left" | "right";
};

const OPTIONS: QuizOptionID[] = ["A", "B", "C", "D"];

export const ThumbBar: React.FC<Props> = ({
  onSelect,
  selected,
  disabled = false,
  position = "right",
}) => {
  const theme = useAppTheme();

  return (
    <View
      accessibilityRole={"toolbar" as AccessibilityRole}
      style={[
        styles.container,
        {
          right: position === "right" ? 16 : undefined,
          left: position === "left" ? 16 : undefined,
          backgroundColor: theme.colors.surface,
          borderColor: theme.colors.border,
        },
      ]}
    >
      {OPTIONS.map((option) => {
        const isActive = selected === option;
        return (
          <Pressable
            key={option}
            disabled={disabled}
            onPress={() => onSelect(option)}
            accessibilityRole={"button" as AccessibilityRole}
            accessibilityLabel={`Select option ${option}`}
            accessibilityState={{ disabled, selected: isActive }}
            style={({ pressed }) => [
              styles.button,
              {
                backgroundColor: isActive
                  ? theme.colors.primary
                  : theme.colors.surfaceAlt,
                opacity: pressed ? 0.9 : 1,
              },
            ]}
          >
            <Text
              style={[
                styles.text,
                {
                  color: isActive
                    ? theme.colors.background
                    : theme.colors.text,
                  fontFamily: theme.typography.fontFamily.bold,
                },
              ]}
            >
              {option}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: "absolute",
    bottom: 40,
    borderRadius: 999,
    padding: 8,
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.12,
    shadowRadius: 6,
    elevation: 4,
  },
  button: {
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: "center",
    justifyContent: "center",
    marginHorizontal: 4,
  },
  text: {
    fontSize: 18,
  },
});

