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
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                showScrollHint.value = false;
              },
              child: AnimatedBuilder(
                animation: hintController,
                builder: (context, child) {
                  return AnimatedOpacity(
                    opacity: showScrollHint.value ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.translate(
                              offset: Offset(0, (hintController.value - 0.5) * 40),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 150,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Swipe down for more questions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.8),
                                      blurRadius: 15,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

