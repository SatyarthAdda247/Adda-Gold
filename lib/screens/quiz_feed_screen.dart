import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/quiz_card.dart';

class QuizFeedScreen extends HookConsumerWidget {
  final String selectedCategory;
  
  const QuizFeedScreen({
    super.key,
    this.selectedCategory = 'All',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final quizNotifier = ref.read(quizProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final pageController = usePageController(
      initialPage: 0,
    );
    final questionStartTime = useRef<DateTime>(DateTime.now());
    final showScrollHint = useState(false);
    final hintController = useAnimationController(duration: const Duration(milliseconds: 1100));
    final lifecycleState = useAppLifecycleState();

    // Filter quizzes by category
    final filteredQuizzes = selectedCategory == 'All'
        ? quizState.quizzes
        : quizState.quizzes.where((quiz) => quiz.category == selectedCategory).toList();

    void triggerHint() {
      if (filteredQuizzes.isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showScrollHint.value = true;
      });
    }

    useEffect(() {
      if (filteredQuizzes.isNotEmpty) {
        triggerHint();
      }
      return null;
    }, [filteredQuizzes.length]);

    useEffect(() {
      if (lifecycleState == AppLifecycleState.resumed && filteredQuizzes.isNotEmpty) {
        triggerHint();
      }
      return null;
    }, [lifecycleState, filteredQuizzes.length]);

    useEffect(() {
      if (!showScrollHint.value || filteredQuizzes.isEmpty) {
        hintController.stop();
        return null;
      }
      hintController.repeat(reverse: true);
      final timer = Timer(const Duration(seconds: 5), () {
        if (showScrollHint.value) {
          showScrollHint.value = false;
        }
      });
      return () {
        hintController.stop();
        timer.cancel();
      };
    }, [showScrollHint.value, filteredQuizzes.length, hintController]);

    useEffect(() {
      if (filteredQuizzes.isNotEmpty && pageController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          pageController.jumpToPage(0);
        });
      }
      return null;
    }, [selectedCategory, quizState.quizzes.length]);

    if (quizState.loading && quizState.quizzes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quizState.error != null && quizState.quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(quizState.error!),
            const SizedBox(height: 8),
            const Text('Pull to retry'),
          ],
        ),
      );
    }

    if (filteredQuizzes.isEmpty) {
      return Center(
        child: Text(
          selectedCategory == 'All'
              ? 'No quizzes available. Pull to refresh.'
              : 'No quizzes found for $selectedCategory.',
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => quizNotifier.refreshQuizzes(),
          child: PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              questionStartTime.value = DateTime.now();
              if (showScrollHint.value) {
                showScrollHint.value = false;
              }
            },
            itemCount: filteredQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = filteredQuizzes[index];
              final answer = quizState.answers[quiz.id];
              return QuizCard(
                quiz: quiz,
                selectedOption: answer?.selected,
                revealAnswer: answer != null,
                bookmarked: quizState.bookmarks[quiz.id] ?? false,
                onSelect: (option) {
                  final elapsedMs = DateTime.now().difference(questionStartTime.value).inMilliseconds;
                  final progress = quizNotifier.selectOption(quiz.id, option, elapsedMs);
                  if (progress != null && settings.autoScrollEnabled && settings.autoAdvanceDelayMs > 0) {
                    Future.delayed(Duration(milliseconds: settings.autoAdvanceDelayMs), () {
                      if (index < filteredQuizzes.length - 1 && pageController.hasClients) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  }
                },
                onToggleBookmark: () => quizNotifier.toggleBookmark(quiz.id),
                hapticsEnabled: settings.hapticsEnabled,
              );
            },
          ),
        ),
        if (showScrollHint.value)
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: hintController,
              builder: (context, child) {
                return AnimatedOpacity(
                  opacity: showScrollHint.value ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Transform.translate(
                    offset: Offset(0, (hintController.value - 0.5) * 16),
                    child: child,
                  ),
                );
              },
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.swipe, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Scroll down for more questions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_downward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

