// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';

import '../game/difficulty.dart';
import '../game/game_setup.dart';

/// Lets the player choose the mode and its options. Returns the new setup,
/// or null if cancelled.
Future<GameSetup?> showNewGameDialog(BuildContext context, GameSetup current) =>
    showDialog<GameSetup>(
      context: context,
      builder: (_) => _NewGameDialog(initial: current),
    );

class _NewGameDialog extends StatefulWidget {
  const _NewGameDialog({required this.initial});

  final GameSetup initial;

  @override
  State<_NewGameDialog> createState() => _NewGameDialogState();
}

class _NewGameDialogState extends State<_NewGameDialog> {
  late GameSetup _setup = widget.initial;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget label(String s) => Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(s, style: text.labelLarge),
    );
    Widget segments<T>(
      Key key,
      List<T> values,
      String Function(T) name,
      T selected,
      void Function(T) onChanged,
    ) => SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        key: key,
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: [
          for (final v in values) ButtonSegment(value: v, label: _fit(name(v))),
        ],
        selected: {selected},
        onSelectionChanged: (s) => setState(() => onChanged(s.first)),
      ),
    );

    return AlertDialog(
      // Tight insets so the whole dialog fits a 320×560 screen unscrolled.
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      title: const Text('New game'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              label('Mode'),
              segments(
                const Key('mode'),
                GameMode.values,
                (m) => m.label,
                _setup.mode,
                (m) => _setup = _setup.copyWith(mode: m),
              ),
              if (_setup.mode == GameMode.vsComputer) ...[
                label('Computer level'),
                segments(
                  const Key('difficulty'),
                  Difficulty.values,
                  (d) => d.label,
                  _setup.difficulty,
                  (d) => _setup = _setup.copyWith(difficulty: d),
                ),
                label('First move'),
                segments(
                  const Key('firstMove'),
                  FirstMove.values,
                  (f) => f.label,
                  _setup.firstMove,
                  (f) => _setup = _setup.copyWith(firstMove: f),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Whoever moves first plays X.',
                    style: text.bodySmall,
                  ),
                ),
              ],
              if (_setup.mode == GameMode.twoPlayer)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Two players share this device. X moves first.',
                    style: text.bodyMedium,
                  ),
                ),
              if (_setup.mode == GameMode.watch) ...[
                label('X computer'),
                segments(
                  const Key('xLevel'),
                  Difficulty.values,
                  (d) => d.label,
                  _setup.xLevel,
                  (d) => _setup = _setup.copyWith(xLevel: d),
                ),
                label('O computer'),
                segments(
                  const Key('oLevel'),
                  Difficulty.values,
                  (d) => d.label,
                  _setup.oLevel,
                  (d) => _setup = _setup.copyWith(oLevel: d),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Two computers play each other and explain every move.',
                    style: text.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('start'),
          onPressed: () => Navigator.pop(context, _setup),
          child: const Text('Start'),
        ),
      ],
    );
  }

  static Widget _fit(String s) =>
      FittedBox(fit: BoxFit.scaleDown, child: Text(s, maxLines: 1));
}
