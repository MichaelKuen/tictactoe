// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the App Verse Games Ko-fi page (apps only, never on web).
class KoFiButton extends StatelessWidget {
  const KoFiButton({super.key});

  static const _url = 'https://ko-fi.com/O3A323W17K';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: const Key('kofi'),
        onPressed: _launch,
        icon: const Icon(Icons.coffee, size: 18),
        label: const Text('Support on Ko-fi'),
      ),
    );
  }

  Future<void> _launch() async {
    final uri = Uri.parse(_url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
