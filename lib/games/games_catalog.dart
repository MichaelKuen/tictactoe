// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import 'game_entry.dart';

/// Google Play developer page — lists all published FullStackShack apps automatically.
const String devPageUrl =
    'https://play.google.com/store/apps/developer?id=FullStackShack';

/// Master list of FullStackShack games shown in the Games Hub.
///
/// To add a new game:
///   1. Add a [GameEntry] below with the correct [playStoreId].
///   2. Set [isCurrent] to true only for the app the user is currently inside.
///   3. Leave [playStoreId] null for games still in development ("Coming Soon").
const List<GameEntry> fullStackShackGames = [
  GameEntry(
    name: 'Tic Tac Toe',
    tagline: 'Classic strategy — challenge the AI or a friend.',
    icon: Icons.grid_3x3,
    iconColor: Color(0xFFFF5252),
    playStoreId: 'com.fullstackshack.tictactoe',
    isCurrent: true,
  ),
  // ── Add future games below ───────────────────────────────────────────────
  // GameEntry(
  //   name: 'Snake',
  //   tagline: 'Eat, grow, survive.',
  //   icon: Icons.linear_scale,
  //   iconColor: Color(0xFF69F0AE),
  //   playStoreId: 'com.fullstackshack.snake',   // set once published
  // ),
  // ────────────────────────────────────────────────────────────────────────
  GameEntry(
    name: 'More games coming soon!',
    tagline: 'Follow FullStackShack on Google Play for updates.',
    icon: Icons.hourglass_bottom,
    iconColor: Color(0xFF5A5A7A),
  ),
];
