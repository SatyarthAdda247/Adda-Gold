import React from "react";
import {
  ActivityIndicator,
  Dimensions,
  FlatList,
  ListRenderItem,
  RefreshControl,
  StyleSheet,
  Text,
  View,
  ViewToken,
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { ReelCard } from "@components/ReelCard";
import { ReelItem } from "@app/types/content";
import { useReelStore } from "@store/useReelStore";
import { useAppTheme } from "@theme/index";

type Props = {
  refreshControl?: React.ReactElement<RefreshControl>;
};

const { height: WINDOW_HEIGHT } = Dimensions.get("window");
const ESTIMATED_HEADER = 140;
const ITEM_HEIGHT = WINDOW_HEIGHT - ESTIMATED_HEADER;

export const ReelFeedScreen: React.FC<Props> = ({ refreshControl }) => {
  const theme = useAppTheme();
  const insets = useSafeAreaInsets();
  const flatListRef = React.useRef<FlatList<ReelItem>>(null);

  const reels = useReelStore((state) => state.reels);
  const loading = useReelStore((state) => state.loading);
  const error = useReelStore((state) => state.error);
  const currentIndex = useReelStore((state) => state.currentIndex);
  const setCurrentIndex = useReelStore((state) => state.setCurrentIndex);
  const likes = useReelStore((state) => state.likes);
  const bookmarks = useReelStore((state) => state.bookmarks);
  const muted = useReelStore((state) => state.muted);
  const toggleLike = useReelStore((state) => state.toggleLike);
  const toggleBookmark = useReelStore((state) => state.toggleBookmark);
  const toggleMute = useReelStore((state) => state.toggleMute);

  React.useEffect(() => {
    if (reels.length === 0) {
      return;
    }
    requestAnimationFrame(() => {
      flatListRef.current?.scrollToIndex({
        index: currentIndex,
        animated: false,
      });
    });
  }, [reels.length, currentIndex]);

  const onViewableItemsChanged = React.useRef(
    ({ viewableItems }: { viewableItems: ViewToken[] }) => {
      const firstVisible = viewableItems.find((item) => item.isViewable);
      if (firstVisible?.index != null) {
        setCurrentIndex(firstVisible.index);
      }
    }
  );

  const viewabilityConfig = React.useMemo(
    () => ({
      itemVisiblePercentThreshold: 85,
      minimumViewTime: 200,
    }),
    []
  );

  const renderItem = React.useCallback<ListRenderItem<ReelItem>>(
    ({ item, index }) => (
      <View style={{ height: ITEM_HEIGHT + insets.bottom }}>
        <ReelCard
          item={item}
          isActive={index === currentIndex}
          liked={Boolean(likes[item.id])}
          bookmarked={Boolean(bookmarks[item.id])}
          muted={muted[item.id] ?? true}
          onToggleLike={toggleLike}
          onToggleBookmark={toggleBookmark}
          onToggleMute={toggleMute}
        />
      </View>
    ),
    [bookmarks, currentIndex, insets.bottom, likes, muted, toggleBookmark, toggleLike, toggleMute]
  );

  const keyExtractor = React.useCallback((item: ReelItem) => item.id, []);

  if (loading && reels.length === 0) {
    return (
      <View style={styles.loaderContainer}>
        <ActivityIndicator color={theme.colors.primary} />
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
          Pull to retry.
        </Text>
      </View>
    );
  }

  if (reels.length === 0) {
    return (
      <View style={styles.errorContainer}>
        <Text
          style={[
            styles.errorHint,
            { color: theme.colors.textSecondary },
          ]}
        >
          No reels available right now. Pull to refresh.
        </Text>
      </View>
    );
  }

  return (
    <FlatList
      ref={flatListRef}
      data={reels}
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
      windowSize={3}
      maxToRenderPerBatch={3}
      initialNumToRender={2}
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

