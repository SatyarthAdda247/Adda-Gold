import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String label;
  final String text;
  final VoidCallback onPress;
  final bool disabled;
  final bool selected;
  final bool revealed;
  final bool isCorrect;

  const OptionButton({
    super.key,
    required this.label,
    required this.text,
    required this.onPress,
    this.disabled = false,
    this.selected = false,
    this.revealed = false,
    this.isCorrect = false,
  });

  Color _getBackgroundColor(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    if (!revealed) {
      return selected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surface;
    }
    if (isCorrect) {
      return const Color(0xFF2ECC71);
    }
    if (selected && !isCorrect) {
      // More subtle red for light theme
      return isLight ? const Color(0xFFC85A5A) : const Color(0xFFE74C3C);
    }
    return Theme.of(context).colorScheme.surface.withOpacity(0.5);
  }

  Color _getTextColor(BuildContext context) {
    if (revealed) {
      return Colors.white;
    }
    return selected ? Colors.black : Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    final minHeight = isSmallScreen ? 52.0 : 56.0;
    final horizontalPadding = isSmallScreen ? 12.0 : 14.0;
    final verticalPadding = isSmallScreen ? 10.0 : 12.0;
    final iconSize = isSmallScreen ? 32.0 : 36.0;
    final fontSize = isSmallScreen ? 14.0 : 15.0;
    final labelFontSize = isSmallScreen ? 14.0 : 15.0;
    
    return InkWell(
      onTap: disabled ? null : onPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: revealed
                    ? Colors.black.withOpacity(0.2)
                    : Theme.of(context).colorScheme.surface.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 10 : 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(context),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

