import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final bool isCompleted;
  final int? expReward;

  const StatusBadge({
    super.key,
    required this.isCompleted,
    this.expReward,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isCompleted ? Colors.green.shade800 : Colors.amber.shade900;
    const fgColor = Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.hourglass_top,
                size: 13,
                color: fgColor,
              ),
              const SizedBox(width: 4),
              Text(
                isCompleted ? 'Cleared' : 'In Progress',
                style: const TextStyle(
                  color: fgColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (expReward != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+$expReward EXP',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }
}