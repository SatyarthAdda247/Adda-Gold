import React from "react";
import {
  Alert,
  Pressable,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  TextInput,
  View,
} from "react-native";
import { z } from "zod";

import { useAppTheme } from "@theme/index";
import { useQuizStore } from "@store/useQuizStore";
import { useReelStore } from "@store/useReelStore";
import { useSettingsStore } from "@store/useSettingsStore";

const delaySchema = z
  .string()
  .regex(/^[0-9]+$/, "Enter delay in milliseconds")
  .transform((val) => parseInt(val, 10))
  .refine((val) => val >= 0 && val <= 10000, {
    message: "Delay must be between 0 and 10000 ms",
  });

const formatDuration = (ms: number) => {
  if (ms === 0) return "0 min";
  const minutes = Math.floor(ms / 60000);
  const seconds = Math.floor((ms % 60000) / 1000);
  if (minutes > 0) {
    return `${minutes} min ${seconds.toString().padStart(2, "0")} s`;
  }
  return `${seconds}s`;
};

export const ProfileScreen: React.FC = () => {
  const theme = useAppTheme();
  const quizStats = useQuizStore((state) => state.stats);
  const reelStats = useReelStore((state) => state.stats);
  const reelBookmarks = useReelStore((state) => state.bookmarks);
  const reelLikes = useReelStore((state) => state.likes);
  const resetQuiz = useQuizStore((state) => state.resetProgress);
  const resetReels = useReelStore((state) => state.reset);

  const soundEnabled = useSettingsStore((state) => state.soundEnabled);
  const setSoundEnabled = useSettingsStore((state) => state.setSoundEnabled);
  const hapticsEnabled = useSettingsStore((state) => state.hapticsEnabled);
  const setHapticsEnabled = useSettingsStore((state) => state.setHapticsEnabled);
  const thumbBarPosition = useSettingsStore((state) => state.thumbBarPosition);
  const setThumbBarPosition = useSettingsStore((state) => state.setThumbBarPosition);
  const autoAdvanceDelayMs = useSettingsStore((state) => state.autoAdvanceDelayMs);
  const setAutoAdvanceDelayMs = useSettingsStore(
    (state) => state.setAutoAdvanceDelayMs
  );

  const [delayValue, setDelayValue] = React.useState(String(autoAdvanceDelayMs));
  const [delayError, setDelayError] = React.useState<string | null>(null);

  React.useEffect(() => {
    setDelayValue(String(autoAdvanceDelayMs));
  }, [autoAdvanceDelayMs]);

  const accuracy =
    quizStats.answered === 0
      ? 0
      : Math.round((quizStats.correct / quizStats.answered) * 100);

  const handleApplyDelay = () => {
    const result = delaySchema.safeParse(delayValue.trim());
    if (!result.success) {
      setDelayError(result.error.issues[0]?.message ?? "Invalid value");
      return;
    }
    setDelayError(null);
    setAutoAdvanceDelayMs(result.data);
  };

  const handleReset = () => {
    Alert.alert(
      "Reset progress?",
      "This will clear quiz answers and reel preferences.",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Reset",
          style: "destructive",
          onPress: () => {
            resetQuiz();
            resetReels();
          },
        },
      ]
    );
  };

  return (
    <SafeAreaView
      style={[
        styles.safeArea,
        { backgroundColor: theme.colors.background },
      ]}
    >
      <ScrollView
        contentContainerStyle={[
          styles.content,
          { paddingBottom: 32 },
        ]}
      >
        <Text
          style={[
            styles.heading,
            {
              color: theme.colors.text,
              fontFamily: theme.typography.fontFamily.bold,
            },
          ]}
          accessibilityRole="header"
          accessibilityLevel={1}
        >
          Profile & Stats
        </Text>

        <View style={styles.card} accessibilityRole="summary">
          <Text
            style={[
              styles.cardTitle,
              {
                color: theme.colors.text,
                fontFamily: theme.typography.fontFamily.medium,
              },
            ]}
          >
            Quiz Performance
          </Text>
          <View style={styles.row}>
            <StatBadge label="Answered" value={String(quizStats.answered)} />
            <StatBadge label="Correct" value={String(quizStats.correct)} />
            <StatBadge label="Accuracy" value={`${accuracy}%`} />
          </View>
          <View style={styles.row}>
            <StatBadge label="Current streak" value={`${quizStats.streak}`} />
            <StatBadge
              label="Time spent"
              value={formatDuration(quizStats.totalTimeMs)}
              wide
            />
          </View>
        </View>

        <View style={styles.card}>
          <Text
            style={[
              styles.cardTitle,
              {
                color: theme.colors.text,
                fontFamily: theme.typography.fontFamily.medium,
              },
            ]}
          >
            Reels Activity
          </Text>
          <View style={styles.row}>
            <StatBadge label="Watched" value={String(reelStats.lastSeenIndex + 1)} />
            <StatBadge label="Bookmarks" value={String(Object.keys(reelBookmarks).length)} />
            <StatBadge label="Likes" value={String(Object.keys(reelLikes).length)} />
          </View>
        </View>

        <View style={styles.card} accessibilityRole="form">
          <Text
            style={[
              styles.cardTitle,
              {
                color: theme.colors.text,
                fontFamily: theme.typography.fontFamily.medium,
              },
            ]}
          >
            Preferences
          </Text>
          <PreferenceRow
            label="Sound effects"
            description="Play subtle sound cues for actions"
            value={soundEnabled}
            onValueChange={setSoundEnabled}
          />
          <PreferenceRow
            label="Haptics"
            description="Vibrate on answer selection"
            value={hapticsEnabled}
            onValueChange={setHapticsEnabled}
          />
          <PreferenceRow
            label="Left-handed thumb bar"
            description="Move quick actions to the left side"
            value={thumbBarPosition === "left"}
            onValueChange={(val) => setThumbBarPosition(val ? "left" : "right")}
          />
          <View style={styles.delaySection}>
            <Text
              style={[
                styles.delayLabel,
                { color: theme.colors.text },
              ]}
            >
              Auto-advance delay (ms)
            </Text>
            <View style={styles.delayInputRow}>
              <TextInput
                keyboardType="numeric"
                value={delayValue}
                onChangeText={(text) => {
                  setDelayValue(text);
                  if (delayError) setDelayError(null);
                }}
                placeholder="1500"
                style={[
                  styles.input,
                  {
                    borderColor: delayError
                      ? theme.colors.error
                      : theme.colors.border,
                    color: theme.colors.text,
                  },
                ]}
                accessibilityLabel="Auto advance delay in milliseconds"
              />
              <Pressable
                style={({ pressed }) => [
                  styles.applyButton,
                  {
                    backgroundColor: theme.colors.primary,
                    opacity: pressed ? 0.85 : 1,
                  },
                ]}
                onPress={handleApplyDelay}
                accessibilityRole="button"
              >
                <Text
                  style={[
                    styles.applyLabel,
                    { color: theme.colors.background },
                  ]}
                >
                  Apply
                </Text>
              </Pressable>
            </View>
            {delayError ? (
              <Text style={[styles.errorText, { color: theme.colors.error }]}>
                {delayError}
              </Text>
            ) : null}
          </View>
        </View>

        <Pressable
          style={({ pressed }) => [
            styles.resetButton,
            {
              borderColor: theme.colors.error,
              opacity: pressed ? 0.85 : 1,
            },
          ]}
          onPress={handleReset}
          accessibilityRole="button"
        >
          <Text
            style={[
              styles.resetText,
              { color: theme.colors.error },
            ]}
          >
            Reset progress
          </Text>
        </Pressable>
      </ScrollView>
    </SafeAreaView>
  );
};

type StatBadgeProps = {
  label: string;
  value: string;
  wide?: boolean;
};

const StatBadge: React.FC<StatBadgeProps> = ({ label, value, wide = false }) => {
  const theme = useAppTheme();
  return (
    <View
      style={[
        styles.statBadge,
        {
          backgroundColor: theme.colors.surface,
          flexBasis: wide ? "60%" : "30%",
        },
      ]}
      accessibilityRole="text"
    >
      <Text
        style={[
          styles.statLabel,
          { color: theme.colors.textSecondary },
        ]}
      >
        {label}
      </Text>
      <Text
        style={[
          styles.statValue,
          {
            color: theme.colors.text,
            fontFamily: theme.typography.fontFamily.bold,
          },
        ]}
      >
        {value}
      </Text>
    </View>
  );
};

type PreferenceRowProps = {
  label: string;
  description: string;
  value: boolean;
  onValueChange: (value: boolean) => void;
};

const PreferenceRow: React.FC<PreferenceRowProps> = ({
  label,
  description,
  value,
  onValueChange,
}) => {
  const theme = useAppTheme();
  return (
    <View style={styles.preferenceRow}>
      <View style={{ flex: 1, paddingRight: 12 }}>
        <Text
          style={[
            styles.preferenceLabel,
            { color: theme.colors.text },
          ]}
        >
          {label}
        </Text>
        <Text
          style={[
            styles.preferenceDescription,
            { color: theme.colors.textSecondary },
          ]}
        >
          {description}
        </Text>
      </View>
      <Switch
        value={value}
        onValueChange={onValueChange}
        accessibilityLabel={label}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 16,
    gap: 20,
  },
  heading: {
    fontSize: 24,
  },
  card: {
    borderRadius: 20,
    padding: 20,
    gap: 16,
    backgroundColor: "rgba(0,0,0,0.04)",
  },
  cardTitle: {
    fontSize: 16,
  },
  row: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 12,
  },
  statBadge: {
    padding: 16,
    borderRadius: 16,
  },
  statLabel: {
    fontSize: 12,
    textTransform: "uppercase",
    letterSpacing: 0.6,
  },
  statValue: {
    marginTop: 4,
    fontSize: 18,
  },
  preferenceRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  preferenceLabel: {
    fontSize: 16,
  },
  preferenceDescription: {
    marginTop: 2,
    fontSize: 13,
  },
  delaySection: {
    gap: 8,
  },
  delayLabel: {
    fontSize: 14,
  },
  delayInputRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  input: {
    flex: 1,
    borderWidth: 1,
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
  },
  applyButton: {
    borderRadius: 12,
    paddingHorizontal: 18,
    paddingVertical: 12,
  },
  applyLabel: {
    fontSize: 14,
    fontWeight: "600",
  },
  errorText: {
    fontSize: 12,
  },
  resetButton: {
    borderWidth: 1,
    borderRadius: 16,
    paddingVertical: 14,
    alignItems: "center",
  },
  resetText: {
    fontSize: 16,
    fontWeight: "600",
  },
});

