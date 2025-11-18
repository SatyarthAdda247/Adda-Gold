import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_bottom_nav.dart';
import 'providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: AddaGoldApp()));
}

class AddaGoldApp extends ConsumerWidget {
  const AddaGoldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = switch (settings.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      title: 'Adda Gold',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const MainTabs(),
    );
  }
}

class MainTabs extends HookWidget {
  const MainTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(0);
    final activeFeed = useState<String>('quizzes');

    return Scaffold(
      body: IndexedStack(
        index: currentIndex.value,
        children: [
          HomeScreen(
            activeFeed: activeFeed.value,
            onFeedChanged: (feed) {
              activeFeed.value = feed;
            },
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        activeFeed: activeFeed.value,
        onFeedChanged: (feed) {
          activeFeed.value = feed;
        },
        currentTab: currentIndex.value,
        onTabChanged: (index) {
          currentIndex.value = index;
        },
      ),
    );
  }
}

