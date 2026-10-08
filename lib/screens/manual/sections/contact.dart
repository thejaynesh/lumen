import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
      final readingWidth = constraints.maxWidth / textScale;
      final wide = readingWidth >= 600;
      final heading = Semantics(
        header: true,
        child: Text(
          'Let’s talk software.',
          style: BroadsideText.editorial(
            size: readingWidth < 250 ? 30 : 40,
            color: Broadside.ink(dark),
            height: 1.15,
            letterSpacing: -0.025,
          ),
        ),
      );
      final sayHello = FilledButton(
        onPressed: () => openExternalLink(context, 'mailto:${settings.email}'),
        style: FilledButton.styleFrom(
          backgroundColor: Broadside.signal(dark),
          foregroundColor: Broadside.signalInk(dark),
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 15),
          shape: const StadiumBorder(),
          textStyle: BroadsideText.sans(size: 13, weight: FontWeight.w500),
        ),
        child: const Text('Email me ↗'),
      );
      return Container(
        margin: const EdgeInsets.only(top: 48),
        padding: const EdgeInsets.only(top: 30, bottom: 28),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Broadside.rule(dark))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (wide && settings.email.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 28),
                  sayHello,
                ],
              )
            else ...[
              heading,
              if (settings.email.isNotEmpty) ...[
                const SizedBox(height: 22),
                sayHello,
              ],
            ],
            if (settings.email.isNotEmpty || settings.phone.isNotEmpty) ...[
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (settings.email.isNotEmpty) ...[
                    _ContactLink(
                      label: '${settings.email} ↗',
                      href: 'mailto:${settings.email}',
                      dark: dark,
                    ),
                    IconButton(
                      tooltip: 'Copy email address',
                      color: Broadside.inkSoft(dark),
                      icon: const Icon(Icons.copy_outlined, size: 17),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: settings.email),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                            const SnackBar(
                              content: Text('Email address copied.'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                  if (settings.phone.isNotEmpty)
                    _ContactLink(
                      label: settings.phone,
                      href:
                          'tel:${settings.phone.replaceAll(RegExp(r'[^0-9+]'), '')}',
                      dark: dark,
                    ),
                ],
              ),
            ],
            Wrap(
              spacing: 22,
              runSpacing: 4,
              children: [
                if (settings.github?.isNotEmpty ?? false)
                  _ContactLink(
                    label: 'GitHub ↗',
                    href: settings.github!,
                    dark: dark,
                  ),
                if (settings.linkedin?.isNotEmpty ?? false)
                  _ContactLink(
                    label: 'LinkedIn ↗',
                    href: settings.linkedin!,
                    dark: dark,
                  ),
                if (settings.twitter?.isNotEmpty ?? false)
                  _ContactLink(
                    label: 'Twitter / X ↗',
                    href: settings.twitter!,
                    dark: dark,
                  ),
                if (settings.instagram?.isNotEmpty ?? false)
                  _ContactLink(
                    label: 'Instagram ↗',
                    href: settings.instagram!,
                    dark: dark,
                  ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 26),
              padding: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Broadside.rule(dark))),
              ),
              child: Wrap(
                spacing: 24,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '© ${DateTime.now().year} ${settings.name}',
                    style: BroadsideText.sans(
                      size: 11,
                      color: Broadside.inkSoft(dark),
                      height: 1.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/modes'),
                    style: TextButton.styleFrom(
                      foregroundColor: Broadside.inkSoft(dark),
                      minimumSize: const Size(44, 44),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: const StadiumBorder(),
                      textStyle: BroadsideText.sans(size: 12),
                    ),
                    child: const Text(
                      'Explore the presentation & personality →',
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

class _ContactLink extends StatelessWidget {
  final String label;
  final String href;
  final bool dark;
  const _ContactLink({
    required this.label,
    required this.href,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    child: TextButton(
      onPressed: () => openExternalLink(context, href),
      style: TextButton.styleFrom(
        foregroundColor: Broadside.inkSoft(dark),
        minimumSize: const Size(44, 44),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: const StadiumBorder(),
        textStyle: BroadsideText.sans(size: 12, height: 1.5),
      ),
      child: Text(label),
    ),
  );
}
