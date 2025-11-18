import React, { useMemo } from "react";
import { Animated, StyleProp, StyleSheet, ViewStyle } from "react-native";

import { useAppTheme } from "@theme/index";

const AnimatedView = Animated.View;

type Props = {
  height?: number | string;
  width?: number | string;
  radius?: number;
  style?: StyleProp<ViewStyle>;
};

export const Skeleton: React.FC<Props> = ({
  height = 16,
  width = "100%",
  radius,
  style,
}) => {
  const theme = useAppTheme();
  const shimmer = useMemo(() => new Animated.Value(0), []);

  React.useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(shimmer, {
          toValue: 1,
          duration: 800,
          useNativeDriver: true,
        }),
        Animated.timing(shimmer, {
          toValue: 0,
          duration: 800,
          useNativeDriver: true,
        }),
      ])
    );
    loop.start();
    return () => {
      loop.stop();
    };
  }, [shimmer]);

  const opacity = shimmer.interpolate({
    inputRange: [0, 1],
    outputRange: [0.3, 0.9],
  });

  return (
    <AnimatedView
      style={[
        styles.container,
        {
          backgroundColor: theme.colors.skeletonBase,
          opacity,
          height,
          width,
          borderRadius: radius ?? theme.radius.md,
        },
        style,
      ]}
    />
  );
};

const styles = StyleSheet.create({
  container: {
    overflow: "hidden",
  },
});

