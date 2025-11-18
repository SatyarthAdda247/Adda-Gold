import React from "react";
import {
  Pressable,
  StyleSheet,
  Text,
  View,
  Share,
  AccessibilityRole,
} from "react-native";
import { Video, ResizeMode, AVPlaybackStatus } from "expo-av";
import { MaterialIcons } from "@expo/vector-icons";

import { ReelItem } from "@app/types/content";
import { useAppTheme } from "@theme/index";

type Props = {
  item: ReelItem;
  isActive: boolean;
  liked: boolean;
  bookmarked: boolean;
  muted: boolean;
  onToggleLike: (id: string) => void;
  onToggleBookmark: (id: string) => void;
  onToggleMute: (id: string) => void;
};

const DOUBLE_TAP_DELAY = 220;

export const ReelCard: React.FC<Props> = ({
  item,
  isActive,
  liked,
  bookmarked,
  muted,
  onToggleLike,
  onToggleBookmark,
  onToggleMute,
}) => {
  const theme = useAppTheme();
  const videoRef = React.useRef<Video>(null);
  const lastTapRef = React.useRef<number>(0);
  const [progress, setProgress] = React.useState(0);

  React.useEffect(() => {
    const video = videoRef.current;
    if (!video) {
      return;
    }

    const handleStatusUpdate = (status: AVPlaybackStatus) => {
      if (!status.isLoaded || !status.durationMillis) {
        return;
      }
      setProgress(status.positionMillis / status.durationMillis);
    };

    video.setOnPlaybackStatusUpdate(handleStatusUpdate);

    return () => {
      video.setOnPlaybackStatusUpdate(undefined);
    };
  }, [item.id]);

  React.useEffect(() => {
    setProgress(0);
  }, [item.id]);

  React.useEffect(() => {
    const prepare = async () => {
      const video = videoRef.current;
      if (!video) return;
      try {
        const status = await video.getStatusAsync();
        if (!status.isLoaded) {
          return;
        }
        if (isActive) {
          await video.playAsync();
        } else {
          await video.pauseAsync();
        }
      } catch (error) {
        console.warn("Failed to control reel playback", error);
      }
    };
    prepare();
  }, [isActive]);

  React.useEffect(() => {
    const video = videoRef.current;
    if (!video) return;
    const applyMute = async () => {
      try {
        const status = await video.getStatusAsync();
        if (!status.isLoaded) {
          return;
        }
        await video.setIsMutedAsync(muted);
      } catch (error) {
        console.warn("Failed to toggle mute", error);
      }
    };
    applyMute();
  }, [muted]);

  const handlePress = () => {
    const now = Date.now();
    if (now - lastTapRef.current < DOUBLE_TAP_DELAY) {
      onToggleLike(item.id);
    } else {
      onToggleMute(item.id);
    }
    lastTapRef.current = now;
  };

  const handleShare = async () => {
    try {
      await Share.share({
        message: `${item.title} • Watch on Adda Gold`,
        url: item.videoUrl,
      });
    } catch (error) {
      console.warn("Share failed", error);
    }
  };

  return (
    <Pressable
      style={styles.container}
      onPress={handlePress}
      accessibilityRole={"imagebutton" as AccessibilityRole}
      accessibilityLabel={`${item.title}. Double tap to like. Single tap to toggle mute.`}
      accessibilityHint="Swipe vertically to move between reels"
    >
      <Video
        ref={videoRef}
        source={{ uri: item.videoUrl }}
        style={StyleSheet.absoluteFill}
        resizeMode={ResizeMode.COVER}
        shouldPlay={isActive}
        isLooping
        isMuted={muted}
        posterSource={
          item.thumbnailUrl ? { uri: item.thumbnailUrl } : undefined
        }
        posterStyle={StyleSheet.absoluteFill}
        usePoster={!isActive}
      />
      <View style={[styles.overlay, { backgroundColor: theme.colors.reelOverlay }]} />
      <View style={styles.content}>
        <View style={styles.meta}>
          <Text
            style={[
              styles.title,
              {
                color: theme.colors.surface,
                fontFamily: theme.typography.fontFamily.bold,
              },
            ]}
            accessibilityRole={"text"}
          >
            {item.title}
          </Text>
          {item.source ? (
            <Text
              style={[
                styles.source,
                {
                  color: theme.colors.textSecondary,
                  fontFamily: theme.typography.fontFamily.regular,
                },
              ]}
              accessibilityRole={"text"}
            >
              {item.source}
            </Text>
          ) : null}
        </View>
        <View style={styles.actions}>
          <ActionButton
            icon={liked ? "favorite" : "favorite-border"}
            label="Like"
            active={liked}
            onPress={() => onToggleLike(item.id)}
          />
          <ActionButton
            icon={bookmarked ? "bookmark" : "bookmark-border"}
            label="Save"
            active={bookmarked}
            onPress={() => onToggleBookmark(item.id)}
          />
          <ActionButton
            icon="share"
            label="Share"
            onPress={handleShare}
          />
          <ActionButton
            icon={muted ? "volume-off" : "volume-up"}
            label={muted ? "Muted" : "Sound"}
            onPress={() => onToggleMute(item.id)}
          />
        </View>
      </View>
      <View style={styles.progressTrack}>
        <View
          style={[
            styles.progressBar,
            { width: `${Math.min(progress * 100, 100)}%`, backgroundColor: theme.colors.primary },
          ]}
        />
      </View>
    </Pressable>
  );
};

type ActionButtonProps = {
  icon: keyof typeof MaterialIcons.glyphMap;
  label: string;
  active?: boolean;
  onPress: () => void;
};

const ActionButton: React.FC<ActionButtonProps> = ({
  icon,
  label,
  active = false,
  onPress,
}) => {
  const theme = useAppTheme();
  return (
    <Pressable
      accessibilityRole={"button" as AccessibilityRole}
      accessibilityLabel={label}
      onPress={onPress}
      style={({ pressed }) => [
        styles.actionButton,
        { opacity: pressed ? 0.8 : 1 },
      ]}
    >
      <MaterialIcons
        name={icon}
        size={26}
        color={active ? theme.colors.primary : theme.colors.surface}
      />
      <Text
        style={[
          styles.actionLabel,
          {
            color: theme.colors.surface,
            fontFamily: theme.typography.fontFamily.medium,
          },
        ]}
      >
        {label}
      </Text>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    position: "relative",
    justifyContent: "flex-end",
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
  },
  content: {
    flexDirection: "row",
    justifyContent: "space-between",
    paddingHorizontal: 18,
    paddingBottom: 80,
    paddingTop: 24,
  },
  meta: {
    flex: 1,
    paddingRight: 16,
  },
  title: {
    fontSize: 20,
    marginBottom: 6,
  },
  source: {
    fontSize: 14,
  },
  actions: {
    alignItems: "center",
    gap: 18,
  },
  actionButton: {
    alignItems: "center",
  },
  actionLabel: {
    fontSize: 12,
    marginTop: 4,
  },
  progressTrack: {
    position: "absolute",
    bottom: 16,
    left: 16,
    right: 16,
    height: 4,
    borderRadius: 2,
    backgroundColor: "rgba(255,255,255,0.25)",
  },
  progressBar: {
    height: "100%",
    borderRadius: 2,
  },
});

