import React from "react";
import {
  ActivityIndicator,
  Dimensions,
  FlatList,
  ListRenderItem,
  StyleSheet,
  Text,
  View,
  ViewToken,
  RefreshControl,
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { QuizCard } from "@components/QuizCard";
import { Skeleton } from "@components/Skeleton";
import { QuizItem, QuizOptionID } from "@app/types/content";
import { useQuizStore } from "@store/useQuizStore";
import { useSettingsStore } from "@store/useSettingsStore";
import { useAppTheme } from "@theme/index";

type Props = {
  refreshControl?: React.ReactElement<RefreshControl>;
};

const { height: WINDOW_HEIGHT } = Dimensions.get("window");
const ESTIMATED_HEADER = 140;
const ITEM_HEIGHT = WINDOW_HEIGHT - ESTIMATED_HEADER;

export const QuizFeedScreen: React.FC<Props> = ({ refreshControl }) => {
  const theme = useAppTheme();
  const insets = useSafeAreaInsets();
  const flatListRef = React.useRef<FlatList<QuizItem>>(null);
  const questionStartRef = React.useRef<number>(Date.now());
  const autoAdvanceTimer = React.useRef<NodeJS.Timeout | null>(null);

  const quizzes = useQuizStore((state) => state.quizzes);
  const loading = useQuizStore((state) => state.loading);
  const error = useQuizStore((state) => state.error);
  const currentIndex = useQuizStore((state) => state.currentIndex);
  const setCurrentIndex = useQuizStore((state) => state.setCurrentIndex);
  const answers = useQuizStore((state) => state.answers);
  const selectOption = useQuizStore((state) => state.selectOption);
  const bookmarks = useQuizStore((state) => state.bookmarks);
  const toggleBookmark = useQuizStore((state) => state.toggleBookmark);

  const autoAdvanceDelayMs = useSettingsStore(
    (state) => state.autoAdvanceDelayMs
  );

  React.useEffect(() => {
    return () => {
      if (autoAdvanceTimer.current) {
        clearTimeout(autoAdvanceTimer.current);
      }
    };
  }, []);

  React.useEffect(() => {
    if (quizzes.length === 0) return;
    requestAnimationFrame(() => {
      flatListRef.current?.scrollToIndex({
        index: currentIndex,
        animated: false,
      });
    });
  }, [quizzes.length, currentIndex]);

  const scrollToIndex = React.useCallback(
    (index: number) => {
      if (index < 0 || index >= quizzes.length) {
        return;
      }
      flatListRef.current?.scrollToIndex({
        index,
        animated: true,
      });
      setCurrentIndex(index);
      questionStartRef.current = Date.now();
    },
    [quizzes.length, setCurrentIndex]
  );

  const handleSelect = React.useCallback(
    (item: QuizItem, option: QuizOptionID) => {
      const elapsedMs = Date.now() - questionStartRef.current;
      const result = selectOption({
        quizId: item.id,
        option,
        elapsedMs,
      });
      if (!result) {
        return;
      }
      if (autoAdvanceTimer.current) {
        clearTimeout(autoAdvanceTimer.current);
      }
      if (autoAdvanceDelayMs > 0) {
        autoAdvanceTimer.current = setTimeout(() => {
          scrollToIndex(Math.min(currentIndex + 1, quizzes.length - 1));
        }, autoAdvanceDelayMs);
      }
    },
    [autoAdvanceDelayMs, currentIndex, quizzes.length, scrollToIndex, selectOption]
  );

  const onViewableItemsChanged = React.useRef(
    ({ viewableItems }: { viewableItems: ViewToken[] }) => {
      const firstItem = viewableItems.find((item) => item.isViewable);
      if (firstItem?.index != null) {
        if (firstItem.index !== currentIndex) {
          setCurrentIndex(firstItem.index);
        }
        questionStartRef.current = Date.now();
      }
    }
  );

  const viewabilityConfig = React.useMemo(
    () => ({
      itemVisiblePercentThreshold: 80,
      minimumViewTime: 200,
    }),
    []
  );

  const renderItem = React.useCallback<ListRenderItem<QuizItem>>(
    ({ item }) => {
      const answer = answers[item.id];
      return (
        <View style={{ height: ITEM_HEIGHT + insets.bottom }}>
          <QuizCard
            item={item}
            selectedOption={answer?.selected}
            revealAnswer={Boolean(answer)}
            onSelect={(option) => handleSelect(item, option)}
            bookmarked={Boolean(bookmarks[item.id])}
            onToggleBookmark={() => toggleBookmark(item.id)}
          />
        </View>
      );
    },
    [answers, bookmarks, handleSelect, insets.bottom, toggleBookmark]
  );

  const keyExtractor = React.useCallback((item: QuizItem) => item.id, []);

  if (loading && quizzes.length === 0) {
    return (
      <View style={styles.loaderContainer}>
        <Skeleton height={48} width="70%" />
        <Skeleton height={48} width="90%" style={{ marginTop: 12 }} />
        <ActivityIndicator style={{ marginTop: 24 }} color={theme.colors.primary} />
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Text
          style={[
            styles.errorText,
            { color: theme.colors.text, fontFamily: theme.typography.fontFamily.medium },
          ]}
        >
          {error}
        </Text>
        <Text
          style={[
            styles.errorHint,
            { color: theme.colors.textSecondary },
          ]}
        >
          Pull to retry or check your connection.
        </Text>
      </View>
    );
  }

  if (quizzes.length === 0) {
    return (
      <View style={styles.errorContainer}>
        <Text
          style={[
            styles.errorHint,
            { color: theme.colors.textSecondary },
          ]}
        >
          No quizzes available right now. Pull to refresh.
        </Text>
      </View>
    );
  }

  return (
    <FlatList
      ref={flatListRef}
      data={quizzes}
      keyExtractor={keyExtractor}
      renderItem={renderItem}
      pagingEnabled
      snapToAlignment="start"
      decelerationRate="fast"
      showsVerticalScrollIndicator={false}
      onViewableItemsChanged={onViewableItemsChanged.current}
      viewabilityConfig={viewabilityConfig}
      refreshControl={refreshControl}
      getItemLayout={(_, index) => ({
        length: ITEM_HEIGHT,
        offset: ITEM_HEIGHT * index,
        index,
      })}
      removeClippedSubviews
      windowSize={5}
      initialNumToRender={3}
      maxToRenderPerBatch={3}
      style={{ flex: 1 }}
      contentContainerStyle={{ minHeight: ITEM_HEIGHT }}
    />
  );
};

const styles = StyleSheet.create({
  loaderContainer: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 24,
  },
  errorContainer: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: 32,
  },
  errorText: {
    fontSize: 16,
    textAlign: "center",
  },
  errorHint: {
    fontSize: 14,
    textAlign: "center",
    marginTop: 8,
  },
});

