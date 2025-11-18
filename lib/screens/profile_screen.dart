import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/quiz_provider.dart';
import '../providers/reel_provider.dart';
import '../providers/settings_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _delayController = TextEditingController();

  @override
  void dispose() {
    _delayController.dispose();
    super.dispose();
  }

  String _formatDuration(int ms) {
    if (ms == 0) return '0 min';
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    if (minutes > 0) {
      return '$minutes min ${seconds.toString().padLeft(2, '0')} s';
    }
    return '${seconds}s';
  }

  void _handleReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text('This will clear quiz answers and reel preferences.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(quizProvider.notifier).resetProgress();
              ref.read(reelProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAllProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Progress?'),
        content: const Text(
          'This will clear all selected quiz answers. Your stats and bookmarks will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(quizProvider.notifier).clearAllAnswers();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All quiz answers cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizStats = ref.watch(quizProvider).stats;
    final reelStats = ref.watch(reelProvider).stats;
    final reelBookmarks = ref.watch(reelProvider).bookmarks;
    final reelLikes = ref.watch(reelProvider).likes;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    final accuracy = quizStats.answered == 0
        ? 0
        : ((quizStats.correct / quizStats.answered) * 100).round();

    _delayController.text = settings.autoAdvanceDelayMs.toString();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile & Stats',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quiz Performance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatBadge(
                              label: 'Answered',
                              value: quizStats.answered.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBadge(
                              label: 'Correct',
                              value: quizStats.correct.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBadge(
                              label: 'Accuracy',
                              value: '$accuracy%',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatBadge(
                              label: 'Current streak',
                              value: quizStats.streak.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _StatBadge(
                              label: 'Time spent',
                              value: _formatDuration(quizStats.totalTimeMs),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reels Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatBadge(
                              label: 'Watched',
                              value: (reelStats.lastSeenIndex + 1).toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBadge(
                              label: 'Bookmarks',
                              value: reelBookmarks.length.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBadge(
                              label: 'Likes',
                              value: reelLikes.length.toString(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preferences',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Sound effects'),
                        subtitle: const Text('Play subtle sound cues for actions'),
                        value: settings.soundEnabled,
                        onChanged: (value) => settingsNotifier.setSoundEnabled(value),
                      ),
                      SwitchListTile(
                        title: const Text('Haptics'),
                        subtitle: const Text('Vibrate on answer selection'),
                        value: settings.hapticsEnabled,
                        onChanged: (value) => settingsNotifier.setHapticsEnabled(value),
                      ),
                      SwitchListTile(
                        title: const Text('Auto-scroll'),
                        subtitle: const Text('Automatically move to next quiz after answering'),
                        value: settings.autoScrollEnabled,
                        onChanged: (value) => settingsNotifier.setAutoScrollEnabled(value),
                      ),
                      SwitchListTile(
                        title: const Text('Left-handed thumb bar'),
                        subtitle: const Text('Move quick actions to the left side'),
                        value: settings.thumbBarPosition == 'left',
                        onChanged: (value) => settingsNotifier.setThumbBarPosition(value ? 'left' : 'right'),
                      ),
                      const SizedBox(height: 4),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        title: const Text('Theme'),
                        subtitle: const Text('Choose app appearance'),
                        trailing: DropdownButton<String>(
                          value: settings.themeMode,
                          isDense: true,
                          items: const [
                            DropdownMenuItem(value: 'system', child: Text('System')),
                            DropdownMenuItem(value: 'light', child: Text('Light')),
                            DropdownMenuItem(value: 'dark', child: Text('Dark')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              settingsNotifier.setThemeMode(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Auto-advance delay (ms)'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _delayController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                hintText: '1500',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              final value = int.tryParse(_delayController.text);
                              if (value != null && value >= 0 && value <= 10000) {
                                settingsNotifier.setAutoAdvanceDelayMs(value);
                              }
                            },
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data Management',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _handleDeleteAllProgress,
                        icon: const Icon(Icons.delete_outline, size: 20),
                        label: const Text('Delete All Quiz Answers'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _handleReset,
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Reset All Progress'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          minimumSize: const Size(double.infinity, 48),
                        ),
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
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;

  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

