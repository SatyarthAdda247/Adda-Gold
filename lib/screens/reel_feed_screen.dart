import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/reel_provider.dart';
import '../widgets/reel_card.dart';

class ReelFeedScreen extends HookConsumerWidget {
  const ReelFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reelState = ref.watch(reelProvider);
    final reelNotifier = ref.read(reelProvider.notifier);
    final pageController = usePageController(
      initialPage: reelState.currentIndex,
    );

    useEffect(() {
      if (reelState.reels.isNotEmpty && pageController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          pageController.jumpToPage(reelState.currentIndex);
        });
      }
      return null;
    }, [reelState.reels.length]);

    if (reelState.loading && reelState.reels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reelState.error != null && reelState.reels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(reelState.error!),
            const SizedBox(height: 8),
            const Text('Pull to retry'),
          ],
        ),
      );
    }

    if (reelState.reels.isEmpty) {
      return const Center(child: Text('No reels available. Pull to refresh.'));
    }

    return RefreshIndicator(
      onRefresh: () => reelNotifier.refreshReels(),
      child: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          reelNotifier.setCurrentIndex(index);
        },
        itemCount: reelState.reels.length,
        itemBuilder: (context, index) {
          final reel = reelState.reels[index];
          return ReelCard(
            reel: reel,
            isActive: index == reelState.currentIndex,
            liked: reelState.likes[reel.id] ?? false,
            bookmarked: reelState.bookmarks[reel.id] ?? false,
            muted: reelState.muted[reel.id] ?? true,
            onToggleLike: () => reelNotifier.toggleLike(reel.id),
            onToggleBookmark: () => reelNotifier.toggleBookmark(reel.id),
            onToggleMute: () => reelNotifier.toggleMute(reel.id),
          );
        },
      ),
    );
  }
}

