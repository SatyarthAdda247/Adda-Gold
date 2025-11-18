import 'package:flutter/material.dart';
import '../models/content.dart';

class ThumbBar extends StatelessWidget {
  final Function(QuizOptionID) onSelect;
  final QuizOptionID? selected;
  final bool disabled;
  final String position;

  const ThumbBar({
    super.key,
    required this.onSelect,
    this.selected,
    this.disabled = false,
    this.position = 'right',
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(context, QuizOptionID.A),
              const SizedBox(width: 8),
              _buildButton(context, QuizOptionID.B),
              const SizedBox(width: 8),
              _buildButton(context, QuizOptionID.C),
              const SizedBox(width: 8),
              _buildButton(context, QuizOptionID.D),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, QuizOptionID option) {
    final isActive = selected == option;
    return InkWell(
      onTap: disabled ? null : () => onSelect(option),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          option.label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

