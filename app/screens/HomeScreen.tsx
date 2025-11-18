import React from "react";
import {
  SafeAreaView,
  StyleSheet,
  Text,
  View,
  RefreshControl,
} from "react-native";
import Animated, { FadeInDown } from "react-native-reanimated";

import { PillSwitch } from "@components/PillSwitch";
import { QuizFeedScreen } from "./QuizFeedScreen";
import { ReelFeedScreen } from "./ReelFeedScreen";
import { useAppTheme } from "@theme/index";
import { useQuizStore } from "@store/useQuizStore";
import { useReelStore } from "@store/useReelStore";

type FeedType = "quizzes" | "reels";

export const HomeScreen: React.FC = () => {
  const theme = useAppTheme();
  const [activeFeed, setActiveFeed] = React.useState<FeedType>("quizzes");
  const quizLoading = useQuizStore((state) => state.loading);
  const reelLoading = useReelStore((state) => state.loading);
  const fetchQuizzes = useQuizStore((state) => state.fetchQuizzes);
  const fetchReels = useReelStore((state) => state.fetchReels);
  const refreshQuizzes = useQuizStore((state) => state.refreshQuizzes);
  const refreshReels = useReelStore((state) => state.refreshReels);

  React.useEffect(() => {
    fetchQuizzes().catch((error) => console.warn(error));
    fetchReels().catch((error) => console.warn(error));
  }, [fetchQuizzes, fetchReels]);

  const isRefreshing =
    activeFeed === "quizzes" ? quizLoading : reelLoading;

  const handleRefresh = React.useCallback(() => {
    if (activeFeed === "quizzes") {
      refreshQuizzes().catch((error) => console.warn(error));
    } else {
      refreshReels().catch((error) => console.warn(error));
    }
  }, [activeFeed, refreshQuizzes, refreshReels]);

  return (
    <SafeAreaView
      style={[
        styles.safeArea,
        { backgroundColor: theme.colors.background },
      ]}
    >
      <View style={[styles.header, { backgroundColor: theme.colors.background }]}>
        <View>
          <Text
            style={[
              styles.title,
              {
                color: theme.colors.text,
                fontFamily: theme.typography.fontFamily.bold,
              },
            ]}
            accessibilityRole="header"
            accessibilityLevel={1}
          >
            Adda Gold
          </Text>
          <Text
            style={[
              styles.subtitle,
              {
                color: theme.colors.textSecondary,
                fontFamily: theme.typography.fontFamily.medium,
              },
            ]}
          >
            Power up your prep with daily quizzes & reels
          </Text>
        </View>
        <Animated.View entering={FadeInDown.duration(240)}>
          <PillSwitch
            value={activeFeed}
            onChange={setActiveFeed}
            options={[
              { label: "Quizzes", value: "quizzes" },
              { label: "Reels", value: "reels" },
            ]}
            style={{
              backgroundColor: theme.colors.surfaceAlt,
              borderRadius: 20,
            }}
          />
        </Animated.View>
      </View>
      {activeFeed === "quizzes" ? (
        <QuizFeedScreen
          refreshControl={
            <RefreshControl refreshing={isRefreshing} onRefresh={handleRefresh} />
          }
        />
      ) : (
        <ReelFeedScreen
          refreshControl={
            <RefreshControl refreshing={isRefreshing} onRefresh={handleRefresh} />
          }
        />
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 16,
  },
  title: {
    fontSize: 28,
  },
  subtitle: {
    fontSize: 14,
    marginTop: 4,
  },
});

