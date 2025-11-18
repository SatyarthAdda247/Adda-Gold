import React from "react";
import {
  LayoutAnimation,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  UIManager,
  View,
  AccessibilityRole,
} from "react-native";
import * as Haptics from "expo-haptics";
import { MaterialIcons } from "@expo/vector-icons";

import { QuizItem, QuizOptionID } from "@app/types/content";
import { OptionButton } from "./OptionButton";
import { ThumbBar } from "./ThumbBar";
import { useAppTheme } from "@theme/index";
import { useSettingsStore } from "@store/useSettingsStore";

if (Platform.OS === "android" && UIManager.setLayoutAnimationEnabledExperimental) {
  UIManager.setLayoutAnimationEnabledExperimental(true);
}

type Props = {
  item: QuizItem;
  onSelect: (option: QuizOptionID) => void;
  selectedOption?: QuizOptionID | null;
  revealAnswer?: boolean;
  bookmarked?: boolean;
  onToggleBookmark?: () => void;
};

export const QuizCard: React.FC<Props> = ({
  item,
  onSelect,
  selectedOption,
  revealAnswer = false,
  bookmarked = false,
  onToggleBookmark,
}) => {
  const theme = useAppTheme();
  const hapticsEnabled = useSettingsStore((state) => state.hapticsEnabled);
  const thumbBarPosition = useSettingsStore((state) => state.thumbBarPosition);
  const [showExplanation, setShowExplanation] = React.useState(false);

  React.useEffect(() => {
    if (revealAnswer && item.explanation) {
      LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
      setShowExplanation(true);
    }
  }, [revealAnswer, item.explanation]);

  const handleSelect = (option: QuizOptionID) => {
    if (selectedOption) return;
    if (hapticsEnabled) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {});
    }
    onSelect(option);
  };

  const difficultyLabel = {
    easy: "Easy",
    medium: "Medium",
    hard: "Hard",
  }[item.difficulty];

  return (
    <View
      style={[
        styles.container,
        { backgroundColor: theme.colors.background },
      ]}
    >
      <View style={styles.header}>
        <View>
          <Text
            style={[
              styles.category,
              {
                color: theme.colors.textSecondary,
                fontFamily: theme.typography.fontFamily.medium,
              },
            ]}
            accessibilityRole={"text"}
          >
            {item.category.toUpperCase()} • {difficultyLabel}
          </Text>
        </View>
        <Pressable
          onPress={onToggleBookmark}
          accessibilityRole={"button" as AccessibilityRole}
          accessibilityLabel="Toggle bookmark"
          hitSlop={12}
        >
          <MaterialIcons
            name={bookmarked ? "bookmark" : "bookmark-border"}
            size={28}
            color={bookmarked ? theme.colors.primary : theme.colors.textSecondary}
          />
        </Pressable>
      </View>
      <View style={styles.questionBlock}>
        <Text
          style={[
            styles.question,
            {
              color: theme.colors.text,
              fontFamily: theme.typography.fontFamily.bold,
            },
          ]}
          accessibilityRole={"header" as AccessibilityRole}
          accessibilityLevel={2}
          adjustsFontSizeToFit
          numberOfLines={3}
          minimumFontScale={0.8}
        >
          {item.question}
        </Text>
      </View>
      <View style={styles.options}>
        {(Object.keys(item.options) as QuizOptionID[]).map((key) => (
          <OptionButton
            key={key}
            label={key}
            text={item.options[key]}
            onPress={() => handleSelect(key)}
            disabled={Boolean(selectedOption)}
            selected={selectedOption === key}
            revealed={revealAnswer}
            isCorrect={key === item.correct}
          />
        ))}
      </View>
      {item.explanation && revealAnswer && showExplanation ? (
        <View
          style={[
            styles.explanationContainer,
            { backgroundColor: theme.colors.surface },
          ]}
        >
          <Text
            style={[
              styles.explanationTitle,
              {
                color: theme.colors.textSecondary,
                fontFamily: theme.typography.fontFamily.medium,
              },
            ]}
          >
            Explanation
          </Text>
          <Text
            style={[
              styles.explanationText,
              {
                color: theme.colors.text,
                fontFamily: theme.typography.fontFamily.regular,
              },
            ]}
            accessibilityRole={"text"}
          >
            {item.explanation}
          </Text>
        </View>
      ) : null}
      <ThumbBar
        onSelect={handleSelect}
        selected={selectedOption ?? null}
        disabled={Boolean(selectedOption)}
        position={thumbBarPosition}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 28,
    paddingHorizontal: 18,
    paddingBottom: 120,
    justifyContent: "flex-start",
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  category: {
    fontSize: 14,
  },
  questionBlock: {
    marginTop: 16,
    marginBottom: 20,
  },
  question: {
    fontSize: 22,
    lineHeight: 30,
  },
  options: {
    flexGrow: 1,
  },
  explanationContainer: {
    marginTop: 16,
    padding: 16,
    borderRadius: 16,
  },
  explanationTitle: {
    fontSize: 14,
    marginBottom: 8,
  },
  explanationText: {
    fontSize: 15,
    lineHeight: 22,
  },
});

