// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/how_to_play_page.dart';
import 'games_sheet.dart';
import 'rules_text.dart';

final privacyPolicyUrl = Uri.parse('https://appversegames.com/privacy-policy/');

/// What the in-app privacy note says. Keep it in step with what is saved:
/// only settings, game choices, scores and a signed-in flag in
/// shared_preferences / localStorage.
const privacyText =
    'Tic Tac Toe needs no account and collects no personal data unless you '
    'choose to sign in.\n\n'
    'Signing in with Google (Android app, in Settings) is optional. It only '
    'links future purchases to you across App Verse Games apps. If you sign '
    'in, Google gives the app your account ID, name and email address. They '
    'are kept in memory while the app runs, not stored or sent anywhere '
    'else, and signing out forgets them.\n\n'
    'The Android app shows ads from Google AdMob between some games, and an '
    'optional ad you can watch for a hint. Where the law requires it, you '
    'are asked first whether ads may be personalised, and you can change '
    'that under Ad privacy choices. To show ads, Google receives device '
    'information, which may include your device\'s advertising ID, under '
    'its own privacy policy. The web version shows no ads inside the game.\n\n'
    'Your settings (theme, sound, vibration), game choices (mode, computer '
    'level, who moves first, Watch and Learn speed and levels), your scores '
    'and whether you are signed in are saved only on this device (in the '
    'app\'s storage, or your browser\'s local storage on the web), so they '
    'are remembered next time. Uninstalling the app or clearing site data '
    'removes them. The play-time reminder is not saved.\n\n'
    'Links to Ko-fi, Google Play and appversegames.com open in your browser '
    'or store app, under those sites\' own privacy policies.';

Future<void> showPrivacyDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Privacy'),
    content: const SingleChildScrollView(child: Text(privacyText)),
    actions: [
      TextButton(
        onPressed: () => launchUrl(privacyPolicyUrl),
        child: const Text('Full privacy policy'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('OK'),
      ),
    ],
  ),
);

void openSettings(BuildContext context, CoreKit kit) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          kit: kit,
          onPrivacyPolicy: () => showPrivacyDialog(context),
        ),
      ),
    );

/// The app bar on mobile and desktop; null on web, where the page around
/// the iframe already shows the title.
PreferredSizeWidget? gameAppBar(
  BuildContext context,
  CoreKit kit,
  String title,
) => isWebBuild
    ? null
    : AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'How to play',
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const HowToPlayPage())),
          ),
          IconButton(
            tooltip: 'More Games',
            icon: const Icon(Icons.sports_esports_outlined),
            onPressed: () => GamesSheet.show(context),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => openSettings(context, kit),
          ),
        ],
      );

/// Rules and light/dark buttons for the web build's game controls.
List<Widget> webButtons(BuildContext context, CoreKit kit) {
  if (!isWebBuild) return const [];
  final brightness = Theme.of(context).brightness;
  return [
    IconButton.outlined(
      key: const Key('rules'),
      tooltip: 'How to play',
      icon: const Icon(Icons.help_outline),
      onPressed: () => showRulesDialog(context),
    ),
    IconButton.outlined(
      key: const Key('themeToggle'),
      tooltip: brightness == Brightness.dark ? 'Light mode' : 'Dark mode',
      icon: Icon(
        brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
      ),
      onPressed: () => kit.settings.toggleTheme(brightness),
    ),
  ];
}
