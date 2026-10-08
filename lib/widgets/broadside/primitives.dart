import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/broadside_theme.dart';
import '../../utils/external_links.dart';

Future<void> openExternalLink(BuildContext context, String value) async {
  final normalized = normalizeExternalUrl(value);
  try {
    if (normalized.isNotEmpty && await launchUrl(Uri.parse(normalized))) {
      return;
    }
  } catch (_) {
    // Leave the portfolio usable if the visitor has no external app configured.
  }
  if (context.mounted) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('Could not open this link. Please try again.'),
      ),
    );
  }
}

class Kicker extends StatelessWidget {
  final String text;
  final bool dark;
  final double size;
  final Color? color;
  final double trackingEm;
  const Kicker(
    this.text, {
    required this.dark,
    this.size = 11,
    this.color,
    this.trackingEm = 0.08,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: BroadsideText.mono(
      size: size,
      color: color ?? Broadside.inkSoft(dark),
      trackingEm: trackingEm,
      weight: FontWeight.w500,
    ),
  );
}

class SectionHead extends StatelessWidget {
  final String number;
  final String title;
  final String sub;
  final bool dark;
  final String? id;
  final bool compact;
  const SectionHead({
    required this.number,
    required this.title,
    required this.sub,
    required this.dark,
    this.id,
    this.compact = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(top: compact ? 28 : 48),
    padding: const EdgeInsets.only(top: 18, bottom: 24),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Broadside.rule(dark))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: Kicker(sub, dark: dark))],
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            title,
            style: BroadsideText.editorial(
              size: compact
                  ? 27
                  : MediaQuery.sizeOf(context).width < 760
                  ? 32
                  : 40,
              color: Broadside.ink(dark),
              height: 1.06,
              letterSpacing: -0.02,
            ),
          ),
        ),
      ],
    ),
  );
}

class BroadTag extends StatelessWidget {
  final String text;
  final bool dark;
  final bool mini;
  const BroadTag(this.text, {required this.dark, this.mini = false, super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: mini ? 9 : 11, vertical: 6),
    decoration: BoxDecoration(
      color: Broadside.paperDeep(dark),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: BroadsideText.sans(
        size: mini ? 11 : 12,
        color: Broadside.inkSoft(dark),
      ),
    ),
  );
}

class BtnPrimary extends StatelessWidget {
  final String label;
  final bool dark;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? href;
  const BtnPrimary({
    required this.label,
    required this.dark,
    this.trailing,
    this.onTap,
    this.href,
    super.key,
  });

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed:
        onTap ??
        (href == null || href!.isEmpty
            ? null
            : () => openExternalLink(context, href!)),
    style: FilledButton.styleFrom(
      backgroundColor: Broadside.signal(dark),
      foregroundColor: Broadside.signalInk(dark),
      minimumSize: const Size(44, 48),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: const StadiumBorder(),
      textStyle: BroadsideText.sans(size: 13, weight: FontWeight.w500),
    ),
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      children: [Text(label), if (trailing != null) trailing!],
    ),
  );
}

class BtnGhost extends StatelessWidget {
  final String label;
  final bool dark;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? href;
  const BtnGhost({
    required this.label,
    required this.dark,
    this.trailing,
    this.onTap,
    this.href,
    super.key,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed:
        onTap ??
        (href == null || href!.isEmpty
            ? null
            : () => openExternalLink(context, href!)),
    style: OutlinedButton.styleFrom(
      foregroundColor: Broadside.ink(dark),
      side: BorderSide(color: Broadside.rule(dark)),
      minimumSize: const Size(44, 48),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: const StadiumBorder(),
      textStyle: BroadsideText.sans(size: 13, weight: FontWeight.w500),
    ),
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      children: [Text(label), if (trailing != null) trailing!],
    ),
  );
}

class BroadsideLink extends StatelessWidget {
  final String label;
  final String href;
  final bool dark;
  const BroadsideLink({
    required this.label,
    required this.href,
    required this.dark,
    super.key,
  });
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => openExternalLink(context, href),
    style: TextButton.styleFrom(
      foregroundColor: Broadside.accent(dark),
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      shape: const RoundedRectangleBorder(),
      textStyle: BroadsideText.sans(size: 14),
    ),
    child: Text(label),
  );
}

class ImagePlaceholder extends StatelessWidget {
  final double aspect;
  final String label;
  final bool dark;
  final String? imageUrl;
  const ImagePlaceholder({
    required this.aspect,
    required this.label,
    required this.dark,
    this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(
        color: Broadside.paperDeep(dark),
        border: Border.all(color: Broadside.rule(dark)),
      ),
      child: AspectRatio(
        aspectRatio: aspect,
        child: Image.network(
          resolveAssetUrl(imageUrl!),
          fit: BoxFit.cover,
          semanticLabel: label,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              'Image unavailable',
              style: BroadsideText.sans(color: Broadside.inkSoft(dark)),
            ),
          ),
        ),
      ),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  final bool dark;
  final VoidCallback onToggle;
  const ThemeToggleButton({
    required this.dark,
    required this.onToggle,
    super.key,
  });
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: dark ? 'Use light theme' : 'Use dark theme',
    onPressed: onToggle,
    color: Broadside.ink(dark),
    icon: Icon(
      dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
      size: 20,
    ),
  );
}
