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

type PillOption<T extends string> = {
  label: string;
  value: T;
  accessibilityLabel?: string;
};

type Props<T extends string> = {
  options: PillOption<T>[];
  value: T;
  onChange: (value: T) => void;
  style?: ViewStyle;
};

export function PillSwitch<T extends string>({
  options,
  value,
  onChange,
  style,
}: Props<T>) {
  const theme = useAppTheme();

  return (
    <View style={[styles.container, style]}>
      {options.map((option) => {
        const isActive = option.value === value;
        return (
          <Pressable
            key={option.value}
            accessibilityRole={"tab" as AccessibilityRole}
            accessibilityLabel={option.accessibilityLabel ?? option.label}
            accessibilityState={{ selected: isActive }}
            onPress={() => onChange(option.value)}
            style={[
              styles.pill,
              {
                backgroundColor: isActive
                  ? theme.colors.primary
                  : theme.colors.surfaceAlt,
                borderColor: isActive
                  ? theme.colors.primary
                  : theme.colors.border,
              },
            ]}
          >
            <Text
              style={[
                styles.label,
                {
                  color: isActive
                    ? theme.colors.background
                    : theme.colors.textSecondary,
                  fontFamily: theme.typography.fontFamily.medium,
                },
              ]}
            >
              {option.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: "row",
    padding: 4,
    borderRadius: 20,
  },
  pill: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 16,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
  },
  label: {
    fontSize: 16,
  },
});

