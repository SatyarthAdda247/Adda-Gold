import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'quiz_feed_screen.dart';
import 'reel_feed_screen.dart';
import '../widgets/category_filter.dart';

class HomeScreen extends HookConsumerWidget {
  final String activeFeed;
  final Function(String) onFeedChanged;
  
  const HomeScreen({
    super.key,
    required this.activeFeed,
    required this.onFeedChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = useState<String>('All');
    final pageController = usePageController(initialPage: activeFeed == 'quizzes' ? 0 : 1);
    final categories = ['All', 'SSC', 'UPSC', 'Banking', 'Railways'];

    useEffect(() {
      final index = activeFeed == 'quizzes' ? 0 : 1;
      if (pageController.hasClients) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      return null;
    }, [activeFeed]);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: activeFeed == 'quizzes'
                  ? CategoryFilter(
                      selectedCategory: selectedCategory.value,
                      onCategoryChanged: (category) {
                        selectedCategory.value = category;
                      },
                      categories: categories,
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  onFeedChanged(index == 0 ? 'quizzes' : 'reels');
                },
                children: [
                  QuizFeedScreen(selectedCategory: selectedCategory.value),
                  const ReelFeedScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

