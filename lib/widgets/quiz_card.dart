import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/content.dart';
import 'option_button.dart';

class QuizCard extends StatefulWidget {
  final QuizItem quiz;
  final QuizOptionID? selectedOption;
  final bool revealAnswer;
  final bool bookmarked;
  final Function(QuizOptionID) onSelect;
  final VoidCallback onToggleBookmark;
  final bool hapticsEnabled;

  const QuizCard({
    super.key,
    required this.quiz,
    this.selectedOption,
    this.revealAnswer = false,
    this.bookmarked = false,
    required this.onSelect,
    required this.onToggleBookmark,
    required this.hapticsEnabled,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  bool _showExplanation = false;

  void _handleSelect(QuizOptionID option) {
    if (widget.selectedOption != null) return;
    if (widget.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    widget.onSelect(option);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.quiz.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              IconButton(
                icon: Icon(
                  widget.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 20,
                  color: widget.bookmarked
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: widget.onToggleBookmark,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.quiz.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OptionButton(
                  label: QuizOptionID.A.label,
                  text: widget.quiz.options[QuizOptionID.A]!,
                  onPress: () => _handleSelect(QuizOptionID.A),
                  disabled: widget.selectedOption != null,
                  selected: widget.selectedOption == QuizOptionID.A,
                  revealed: widget.revealAnswer,
                  isCorrect: widget.quiz.correct == QuizOptionID.A,
                ),
                const SizedBox(height: 8),
                OptionButton(
                  label: QuizOptionID.B.label,
                  text: widget.quiz.options[QuizOptionID.B]!,
                  onPress: () => _handleSelect(QuizOptionID.B),
                  disabled: widget.selectedOption != null,
                  selected: widget.selectedOption == QuizOptionID.B,
                  revealed: widget.revealAnswer,
                  isCorrect: widget.quiz.correct == QuizOptionID.B,
                ),
                const SizedBox(height: 8),
                OptionButton(
                  label: QuizOptionID.C.label,
                  text: widget.quiz.options[QuizOptionID.C]!,
                  onPress: () => _handleSelect(QuizOptionID.C),
                  disabled: widget.selectedOption != null,
                  selected: widget.selectedOption == QuizOptionID.C,
                  revealed: widget.revealAnswer,
                  isCorrect: widget.quiz.correct == QuizOptionID.C,
                ),
                const SizedBox(height: 8),
                OptionButton(
                  label: QuizOptionID.D.label,
                  text: widget.quiz.options[QuizOptionID.D]!,
                  onPress: () => _handleSelect(QuizOptionID.D),
                  disabled: widget.selectedOption != null,
                  selected: widget.selectedOption == QuizOptionID.D,
                  revealed: widget.revealAnswer,
                  isCorrect: widget.quiz.correct == QuizOptionID.D,
                ),
                const SizedBox(height: 24),
                if (widget.quiz.explanation != null && widget.revealAnswer)
                  (!_showExplanation
                      ? ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showExplanation = true;
                            });
                          },
                          icon: const Icon(Icons.lightbulb_outline, size: 16),
                          label: const Text('See Solution', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 2,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Solution',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.quiz.explanation!,
                                style: const TextStyle(fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

