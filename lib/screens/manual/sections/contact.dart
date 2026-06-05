// Broadside Contact / Footer — §6.6
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/portfolio_data.dart';
import '../../../theme/broadside_theme.dart';
import '../../../widgets/broadside/primitives.dart';

class BroadsideContact extends StatelessWidget {
  final PortfolioSettings settings;
  final bool dark;

  const BroadsideContact({
    required this.settings,
    required this.dark,
    super.key,
  });

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 48),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Broadside.ink(dark), width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main 3-col row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 44,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Col 1 — email + phone (flex 14)
                Expanded(
                  flex: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Kicker('Get in touch', dark: dark),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () => _launch('mailto:${settings.email}'),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Broadside.accent(dark),
                                ),
                              ),
                            ),
                            child: Text(
                              settings.email,
                              style: BroadsideText.serif(
                                size: 36,
                                color: Broadside.ink(dark),
                                style: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (settings.phone.isNotEmpty)
                        Kicker(settings.phone, dark: dark),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // Col 2 — links (flex 10)
                Expanded(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Kicker('Links', dark: dark),
                      const SizedBox(height: 12),
                      if (settings.github != null &&
                          settings.github!.isNotEmpty)
                        _LinkItem(
                          label: '↳ GitHub',
                          dark: dark,
                          url: 'https://${settings.github}',
                        ),
                      const SizedBox(height: 8),
                      if (settings.linkedin != null &&
                          settings.linkedin!.isNotEmpty)
                        _LinkItem(
                          label: '↳ LinkedIn',
                          dark: dark,
                          url: 'https://${settings.linkedin}',
                        ),
                      const SizedBox(height: 8),
                      _LinkItem(
                        label: '↳ Email',
                        dark: dark,
                        url: 'mailto:${settings.email}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // Col 3 — colophon (flex 10)
                Expanded(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Kicker('Colophon', dark: dark),
                      const SizedBox(height: 12),
                      Text(
                        'Set in Instrument Serif & Inter Tight, with Geist Mono for the small print. Designed in the Broadside style — bold, numbered, and direct.',
                        style: BroadsideText.sans(
                          size: 12.5,
                          color: Broadside.inkSoft(dark),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Broadside.rule(dark)),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Kicker('© 2026 ${settings.name}', dark: dark),
                Kicker(
                  'Built with care, one weekend at a time',
                  dark: dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkItem extends StatefulWidget {
  final String label;
  final bool dark;
  final String url;

  const _LinkItem({
    required this.label,
    required this.dark,
    required this.url,
  });

  @override
  State<_LinkItem> createState() => _LinkItemState();
}

class _LinkItemState extends State<_LinkItem> {
  bool _hover = false;

  Future<void> _launch() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _launch,
        child: Text(
          widget.label,
          style: BroadsideText.sans(
            size: 13,
            color: _hover
                ? Broadside.accent(widget.dark)
                : Broadside.ink(widget.dark),
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
