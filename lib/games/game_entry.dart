// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';

class GameEntry {
  final String name;
  final String tagline;
  final IconData icon;
  final Color iconColor;

  /// Play Store package ID. Null means "coming soon".
  final String? playStoreId;

  /// True for the game the user is currently playing.
  final bool isCurrent;

  const GameEntry({
    required this.name,
    required this.tagline,
    required this.icon,
    required this.iconColor,
    this.playStoreId,
    this.isCurrent = false,
  });

  bool get isReleased => playStoreId != null;

  String? get playStoreUrl => playStoreId != null
      ? 'https://play.google.com/store/apps/details?id=$playStoreId'
      : null;
}
