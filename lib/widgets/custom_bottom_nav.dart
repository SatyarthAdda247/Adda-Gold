import 'package:flutter/material.dart';
import 'dart:ui';

class CustomBottomNav extends StatelessWidget {
  final String activeFeed;
  final Function(String) onFeedChanged;
  final int currentTab;
  final Function(int) onTabChanged;

  const CustomBottomNav({
    super.key,
    required this.activeFeed,
    required this.onFeedChanged,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.8)
            : Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.quiz_outlined,
                    selectedIcon: Icons.quiz,
                    label: 'Quizzes',
                    isSelected: currentTab == 0 && activeFeed == 'quizzes',
                    onTap: () {
                      onTabChanged(0);
                      onFeedChanged('quizzes');
                    },
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.video_library_outlined,
                    selectedIcon: Icons.video_library,
                    label: 'Reels',
                    isSelected: currentTab == 0 && activeFeed == 'reels',
                    onTap: () {
                      onTabChanged(0);
                      onFeedChanged('reels');
                    },
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person,
                    label: 'Profile',
                    isSelected: currentTab == 1,
                    onTap: () => onTabChanged(1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  size: 24,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

