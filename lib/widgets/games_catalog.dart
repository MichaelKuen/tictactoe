// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';

import 'game_entry.dart';

/// Every App Verse Games title, on the website.
const String allGamesUrl = 'https://appversegames.com/games/';

/// Games shown in the Games Hub.
///
/// To add a game: add a [GameEntry] with its Play Store [GameEntry.playStoreId]
/// once it is published. Set [GameEntry.isCurrent] only for this app.
const List<GameEntry> appverseGames = [
  GameEntry(
    name: 'Tic Tac Toe',
    tagline: 'Classic strategy: challenge the computer or a friend.',
    icon: Icons.grid_3x3,
    iconColor: AppverseColors.amber,
    playStoreId: 'com.appversegames.tictactoe',
    isCurrent: true,
  ),
];
