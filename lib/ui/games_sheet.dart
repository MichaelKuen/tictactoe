// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../games/game_entry.dart';
import '../games/games_catalog.dart';
import 'kofi_button.dart';
import 'privacy_policy_screen.dart';

class GamesSheet extends StatelessWidget {
  const GamesSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GamesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.sports_esports,
                        color: theme.colorScheme.primary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'FullStackShack Games',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              Divider(color: theme.colorScheme.outline),

              // Game cards
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  itemCount: fullStackShackGames.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _GameCard(entry: fullStackShackGames[i]),
                ),
              ),

              // Footer: Ko-fi + View all + house-ads note
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const KoFiButton(),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _launch(devPageUrl),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('View all on Google Play'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ads from FullStackShack games may appear above to support development.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => PrivacyPolicyScreen.show(context),
                      child: Text(
                        'Privacy Policy',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.8),
                          decoration: TextDecoration.underline,
                          decorationColor: theme.colorScheme.primary
                              .withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Game card ──────────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  final GameEntry entry;
  const _GameCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF252540) : Colors.white;
    final borderColor = entry.isCurrent
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon bubble
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: entry.iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(entry.icon, color: entry.iconColor, size: 28),
          ),
          const SizedBox(width: 14),

          // Name + tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.tagline,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Action badge / button
          _buildAction(context, theme),
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context, ThemeData theme) {
    if (entry.isCurrent) {
      return _Badge(
        label: 'Playing',
        color: theme.colorScheme.primary,
      );
    }
    if (entry.isReleased) {
      return FilledButton(
        onPressed: () => _launch(entry.playStoreUrl!),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          minimumSize: const Size(60, 36),
        ),
        child: const Text('Play'),
      );
    }
    return _Badge(
      label: 'Soon',
      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── URL helper ─────────────────────────────────────────────────────────────

Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
