// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';

const _sections = <(String, String)>[
  (
    'The aim',
    'Get three of your marks in a row: across, down or diagonally. The '
        'first player to do it wins.',
  ),
  (
    'Taking turns',
    'Players take turns placing one mark on an empty square. X always moves '
        'first. If all nine squares fill up and nobody has three in a row, '
        'the game is a draw.',
  ),
  (
    'Modes',
    'Play against the computer on Easy, Medium or Hard, or with a friend on '
        'the same device. Against the computer you choose who moves first: '
        'you, the computer, or take turns. Whoever starts plays X.',
  ),
  (
    'Tips',
    'The centre square is on four lines and the corners on three, so they '
        'are the strongest squares. Block your opponent whenever they have '
        'two in a row. Make two threats at once (a fork) and your opponent '
        'can only block one. With perfect play from both sides, every game '
        'is a draw, so Hard can never be beaten, only held to a draw.',
  ),
  (
    'Watch and Learn',
    'Two computers play each other while a comment box explains every move '
        'and why it was chosen. Pause, step back or change the speed at any '
        'time.',
  ),
  (
    'Keyboard',
    'Number keys 1 to 9 place a mark, in reading order (1 is top left). On '
        'the number pad, the keys match the board. Arrow keys move the '
        'cursor and Enter or Space places a mark. N starts a new game.',
  ),
];

/// The rules, shared by the How to Play page and the web rules dialog.
class RulesText extends StatelessWidget {
  const RulesText({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (title, body) in _sections) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(title, style: text.titleMedium),
          ),
          Text(body, style: text.bodyMedium),
        ],
      ],
    );
  }
}

/// The rules in a dialog, for the web build's game controls.
Future<void> showRulesDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    title: Text(isWebBuild ? 'How to play' : 'How to play Tic Tac Toe'),
    content: const SizedBox(
      width: 520,
      child: SingleChildScrollView(child: RulesText()),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('OK'),
      ),
    ],
  ),
);
