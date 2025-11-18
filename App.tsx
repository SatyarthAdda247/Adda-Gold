import "react-native-gesture-handler";
import React from "react";
import { useColorScheme } from "react-native";
import { NavigationContainer, useTheme } from "@react-navigation/native";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import { MaterialIcons } from "@expo/vector-icons";

import { HomeScreen } from "@screens/HomeScreen";
import { ProfileScreen } from "@screens/ProfileScreen";
import { buildNavigationTheme, AppTheme } from "@theme/index";

const Tab = createBottomTabNavigator();
const Stack = createNativeStackNavigator();

function MainTabs() {
  const theme = useTheme<AppTheme>();

  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.textSecondary,
        tabBarStyle: {
          backgroundColor: theme.colors.surface,
          borderTopColor: theme.colors.border,
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontFamily: theme.typography.fontFamily.medium,
        },
        tabBarIcon: ({ color, size }) => {
          const icon = route.name === "Home" ? "dashboard" : "person";
          return <MaterialIcons name={icon as any} size={size} color={color} />;
        },
        sceneContainerStyle: { backgroundColor: theme.colors.background },
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}

function RootNavigator() {
  const colorScheme = useColorScheme();
  const theme = React.useMemo(
    () => buildNavigationTheme(colorScheme === "dark" ? "dark" : "light"),
    [colorScheme]
  );

  return (
    <NavigationContainer theme={theme}>
      <StatusBar style={colorScheme === "dark" ? "light" : "dark"} />
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          contentStyle: { backgroundColor: theme.colors.background },
        }}
      >
        <Stack.Screen name="Main" component={MainTabs} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <RootNavigator />
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}


