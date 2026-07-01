// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen privacy policy with a Summary tab and a Full Policy tab.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static void show(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Policy'),
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.list_alt_outlined), text: 'Summary'),
              Tab(icon: Icon(Icons.article_outlined), text: 'Full Policy'),
            ],
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: theme.colorScheme.primary,
          ),
        ),
        body: const TabBarView(
          children: [
            _SummaryTab(),
            _FullPolicyTab(),
          ],
        ),
      ),
    );
  }
}

// ── Summary Tab ────────────────────────────────────────────────────────────

class _SummaryTab extends StatelessWidget {
  const _SummaryTab();

  @override
  Widget build(BuildContext context) {
    const items = [
      _SummaryItem(
        icon: Icons.manage_search_outlined,
        iconColor: Color(0xFF40C4FF),
        title: 'What We Collect',
        body:
            'We do not collect your name, email, location, or any personal '
            'identifiers. The only external data flow comes from Google AdMob, '
            'which may read your device\'s Advertising ID to serve relevant ads.',
      ),
      _SummaryItem(
        icon: Icons.campaign_outlined,
        iconColor: Color(0xFFFFD740),
        title: 'Ads & Advertising ID',
        body:
            'Ads are served by Google AdMob. AdMob may use your device\'s '
            'Advertising ID to show personalised ads. You can opt out at any '
            'time via your device\'s Privacy or Ads settings — the app still '
            'works fully with non-personalised ads.',
      ),
      _SummaryItem(
        icon: Icons.phone_android_outlined,
        iconColor: Color(0xFF69F0AE),
        title: 'Data Stays on Your Device',
        body:
            'Your game scores are saved in your device\'s local storage '
            '(SharedPreferences). This data never leaves your device and is '
            'not transmitted to us or any third party.',
      ),
      _SummaryItem(
        icon: Icons.child_friendly_outlined,
        iconColor: Color(0xFFFF5252),
        title: 'Children\'s Privacy',
        body:
            'This app is not directed at children under 13. We do not knowingly '
            'collect data from children. If you believe a child has provided '
            'data, please contact us and we will act promptly.',
      ),
      _SummaryItem(
        icon: Icons.tune_outlined,
        iconColor: Color(0xFFCE93D8),
        title: 'Your Controls',
        body:
            'You can reset ad personalisation via Android Settings → Privacy → '
            'Ads → Reset Advertising ID. You can also delete all locally stored '
            'scores by tapping the reset icon on the scoreboard.',
      ),
      _SummaryItem(
        icon: Icons.mail_outline,
        iconColor: Color(0xFFF48FB1),
        title: 'Contact Us',
        body:
            'Questions about this policy? Reach us at:\n'
            'michaelkuen888@gmail.com\n\n'
            'We aim to respond within 5 business days.',
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      itemCount: items.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        if (i == 0) return _EffectiveDateBanner();
        return items[i - 1];
      },
    );
  }
}

class _EffectiveDateBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E38) : const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A5A) : const Color(0xFFC5CAE9),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF7986CB)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Effective date: 1 July 2026  ·  App: Tic Tac Toe  ·  Developer: FullStackShack',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  const _SummaryItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E38) : Colors.white;
    final border = isDark ? const Color(0xFF3A3A5A) : const Color(0xFFE0E0E0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full Policy Tab ────────────────────────────────────────────────────────

class _FullPolicyTab extends StatelessWidget {
  const _FullPolicyTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: const [
        _PolicySection(
          number: null,
          heading: 'Privacy Policy',
          content:
              'Effective date: 1 July 2026\n'
              'Developer: FullStackShack\n'
              'App: Tic Tac Toe (com.fullstackshack.tictactoe)\n'
              'Contact: michaelkuen888@gmail.com\n\n'
              'This Privacy Policy explains how FullStackShack ("we", "us", or "our") '
              'handles information in connection with the Tic Tac Toe mobile application '
              '("App"). Please read this policy carefully. By using the App, you '
              'acknowledge you have read and understood this policy.',
        ),
        _PolicySection(
          number: '1',
          heading: 'Information We Collect',
          content: '',
          children: [
            _PolicySubSection(
              heading: '1.1  Advertising Identifiers (via Google AdMob)',
              content:
                  'The App uses Google AdMob to display advertisements. AdMob is operated '
                  'by Google LLC and may collect and process your device\'s Advertising ID '
                  '(also known as Google Advertising ID / GAID on Android). This identifier '
                  'may be used to:\n\n'
                  '  • Show personalised advertisements based on your interests.\n'
                  '  • Measure ad performance and frequency.\n'
                  '  • Prevent fraudulent ad activity.\n\n'
                  'We do not directly access, store, or process your Advertising ID. '
                  'All ad-related data collection and processing is performed by Google '
                  'AdMob under Google\'s own privacy policy.',
            ),
            _PolicySubSection(
              heading: '1.2  Locally Stored Data',
              content:
                  'The App stores the following data exclusively on your device using '
                  'Android SharedPreferences (local storage):\n\n'
                  '  • Game scores: wins, losses, and draws for vs-AI and vs-Human modes.\n\n'
                  'This data is:\n'
                  '  • Never transmitted to our servers or any third party.\n'
                  '  • Never linked to your identity.\n'
                  '  • Deleted when you uninstall the App or clear App data.',
            ),
            _PolicySubSection(
              heading: '1.3  Session Timer',
              content:
                  'The App tracks in-session play time to provide health-awareness reminders '
                  '(e.g., 20-minute eye-break nudges, 60-minute session alerts). This '
                  'data is held in memory only and is not persisted between app launches '
                  'or transmitted anywhere.',
            ),
            _PolicySubSection(
              heading: '1.4  Information We Do NOT Collect',
              content:
                  'We do not collect:\n\n'
                  '  • Names, usernames, or account information.\n'
                  '  • Email addresses or phone numbers.\n'
                  '  • Location data (GPS or IP-based).\n'
                  '  • Camera or microphone access.\n'
                  '  • Contacts or calendar information.\n'
                  '  • Usage analytics or crash reports (beyond what AdMob captures).\n'
                  '  • Any data from children under the age of 13.',
            ),
          ],
        ),
        _PolicySection(
          number: '2',
          heading: 'How We Use Your Information',
          content:
              'We use the information described above solely to:\n\n'
              '  • Display relevant advertisements through Google AdMob to support '
              'the continued free availability of the App.\n'
              '  • Persist your game scores locally so they are available the next '
              'time you open the App.\n'
              '  • Provide health-awareness reminders during gameplay.\n\n'
              'We do not use your information for profiling, marketing, or any purpose '
              'beyond what is listed above.',
        ),
        _PolicySection(
          number: '3',
          heading: 'Third-Party Services',
          content: '',
          children: [
            _PolicySubSection(
              heading: '3.1  Google AdMob',
              content:
                  'Google AdMob is a mobile advertising platform operated by Google LLC '
                  '(1600 Amphitheatre Parkway, Mountain View, CA 94043, USA).\n\n'
                  'AdMob may collect device identifiers and usage data in accordance with '
                  'Google\'s Privacy Policy. We encourage you to review it at:\n'
                  'https://policies.google.com/privacy\n\n'
                  'You can opt out of personalised advertising at any time:\n'
                  '  • Android: Settings → Privacy → Ads → Opt out of Ads Personalisation\n'
                  '  • You can also reset your Advertising ID from the same menu.\n\n'
                  'Opting out does not remove ads from the App — it switches to '
                  'non-personalised ads.',
            ),
          ],
        ),
        _PolicySection(
          number: '4',
          heading: 'Data Retention and Security',
          content:
              'Locally stored score data is retained on your device until you:\n'
              '  • Tap the reset icon on the in-app scoreboard, or\n'
              '  • Clear the App\'s data via Android Settings, or\n'
              '  • Uninstall the App.\n\n'
              'We do not operate servers or databases containing your data. As a result, '
              'there is no server-side data to delete or request.\n\n'
              'Ad-related data retained by Google AdMob is subject to Google\'s '
              'own retention policies.',
        ),
        _PolicySection(
          number: '5',
          heading: 'Children\'s Privacy',
          content:
              'The App is not directed at children under the age of 13 (or the applicable '
              'age of digital consent in your jurisdiction). We do not knowingly collect '
              'personal information from children.\n\n'
              'If you are a parent or guardian and believe your child has provided personal '
              'information to us, please contact us at michaelkuen888@gmail.com. We will '
              'investigate and take steps to remove any such information promptly.\n\n'
              'Ad content displayed by AdMob is subject to Google\'s policies on '
              'child-directed content.',
        ),
        _PolicySection(
          number: '6',
          heading: 'Your Privacy Rights',
          content: '',
          children: [
            _PolicySubSection(
              heading: '6.1  General Rights',
              content:
                  'Depending on your location, you may have the right to:\n\n'
                  '  • Access — request a copy of any personal data we hold about you.\n'
                  '  • Erasure — request that your personal data be deleted.\n'
                  '  • Correction — request that inaccurate data be corrected.\n'
                  '  • Portability — receive your data in a machine-readable format.\n'
                  '  • Objection — object to certain types of data processing.\n\n'
                  'As we do not store personal data on our servers, most of these rights '
                  'are exercised directly on your device (e.g., clearing App data). '
                  'For data held by Google AdMob, please use Google\'s privacy tools at '
                  'https://myaccount.google.com/data-and-privacy.',
            ),
            _PolicySubSection(
              heading: '6.2  EU/EEA Users (GDPR)',
              content:
                  'If you are located in the European Union or European Economic Area, '
                  'you have additional rights under the General Data Protection Regulation '
                  '(GDPR), including the right to lodge a complaint with your local data '
                  'protection authority.\n\n'
                  'The legal basis for AdMob\'s processing of your data is either:\n'
                  '  • Consent (for personalised ads, where applicable), or\n'
                  '  • Legitimate interests (for non-personalised ads and fraud prevention).',
            ),
            _PolicySubSection(
              heading: '6.3  California Users (CCPA)',
              content:
                  'If you are a California resident, you have rights under the California '
                  'Consumer Privacy Act (CCPA), including the right to know what personal '
                  'information is collected, the right to delete it, and the right to '
                  'opt out of its sale.\n\n'
                  'We do not sell personal information. Ad-related data sharing with '
                  'Google AdMob may constitute a "sale" under California law — you may '
                  'opt out via the Advertising ID controls described in Section 3.1.',
            ),
          ],
        ),
        _PolicySection(
          number: '7',
          heading: 'Changes to This Policy',
          content:
              'We may update this Privacy Policy from time to time. When we do, we will '
              'update the effective date at the top of this page. Continued use of the '
              'App after changes are posted constitutes your acceptance of the revised policy.\n\n'
              'For significant changes, we will make reasonable efforts to notify you '
              'through an in-app notice.',
        ),
        _PolicySection(
          number: '8',
          heading: 'Contact Us',
          content:
              'If you have any questions, concerns, or requests regarding this Privacy '
              'Policy or the way we handle data, please contact us:\n\n'
              'Email: michaelkuen888@gmail.com\n'
              'Developer: FullStackShack\n\n'
              'We aim to respond to all enquiries within 5 business days.',
          showContactButton: true,
        ),
      ],
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String? number;
  final String heading;
  final String content;
  final List<_PolicySubSection> children;
  final bool showContactButton;

  const _PolicySection({
    required this.number,
    required this.heading,
    required this.content,
    this.children = const [],
    this.showContactButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headingStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      height: 1.65,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number != null ? '$number.  $heading' : heading,
            style: number != null
                ? headingStyle
                : theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(content, style: bodyStyle),
          ],
          if (children.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...children,
          ],
          if (showContactButton) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _launchEmail(),
              icon: const Icon(Icons.mail_outline, size: 16),
              label: const Text('Send us an email'),
            ),
          ],
        ],
      ),
    );
  }
}

class _PolicySubSection extends StatelessWidget {
  final String heading;
  final String content;

  const _PolicySubSection({
    required this.heading,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.65,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

Future<void> _launchEmail() async {
  final uri = Uri(
    scheme: 'mailto',
    path: 'michaelkuen888@gmail.com',
    queryParameters: {
      'subject': 'Privacy Policy Enquiry — Tic Tac Toe',
    },
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
