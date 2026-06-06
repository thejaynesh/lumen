// Broadside shared primitives — Flutter port of components.jsx
// Sharp corners everywhere (no BorderRadius). All mono/label text is UPPERCASE.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/broadside_theme.dart';

// ---------------------------------------------------------------------------
// 1. Kicker
// ---------------------------------------------------------------------------

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
    this.trackingEm = 0.18,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: BroadsideText.mono(
        size: size,
        color: color ?? Broadside.inkSoft(dark),
        trackingEm: trackingEm,
        weight: FontWeight.w500,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. SectionHead
// ---------------------------------------------------------------------------

class SectionHead extends StatelessWidget {
  final String number;
  final String title;
  final String sub;
  final bool dark;
  final String? id;

  const SectionHead({
    required this.number,
    required this.title,
    required this.sub,
    required this.dark,
    this.id,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final mobile = w < 760;
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: EdgeInsets.only(top: mobile ? 36 : 52, bottom: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Broadside.ink(dark), width: 1.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Kicker(number, dark: dark),
                const SizedBox(width: 22),
                Flexible(
                  child: Text(
                    title,
                    style: BroadsideText.serif(
                      size: mobile ? 40 : 72,
                      color: Broadside.ink(dark),
                      height: 1.0,
                      letterSpacing: -0.02,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Kicker(sub, dark: dark),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. BroadTag
// ---------------------------------------------------------------------------

class BroadTag extends StatelessWidget {
  final String text;
  final bool dark;
  final bool mini;

  const BroadTag(
    this.text, {
    required this.dark,
    this.mini = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: mini
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Broadside.rule(dark)),
      ),
      child: Text(
        text.toUpperCase(),
        style: BroadsideText.mono(
          size: mini ? 9.5 : 10.5,
          color: Broadside.inkSoft(dark),
          trackingEm: 0.14,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. BtnPrimary
// ---------------------------------------------------------------------------

class BtnPrimary extends StatefulWidget {
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
  State<BtnPrimary> createState() => _BtnPrimaryState();
}

class _BtnPrimaryState extends State<BtnPrimary> {
  bool _hover = false;

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.href != null) {
      launchUrl(Uri.parse(widget.href!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Broadside.ink(widget.dark);
    final fgColor = Broadside.paper(widget.dark);

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: bgColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label.toUpperCase(),
            style: BroadsideText.mono(
              size: 11,
              color: fgColor,
              trackingEm: 0.16,
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 10),
            widget.trailing!,
          ],
        ],
      ),
    );

    if (_hover) {
      content = Opacity(opacity: 0.85, child: content);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _handleTap,
        child: content,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. BtnGhost
// ---------------------------------------------------------------------------

class BtnGhost extends StatefulWidget {
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
  State<BtnGhost> createState() => _BtnGhostState();
}

class _BtnGhostState extends State<BtnGhost> {
  bool _hover = false;

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.href != null) {
      launchUrl(Uri.parse(widget.href!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fgColor = Broadside.ink(widget.dark);
    final borderColor =
        _hover ? Broadside.ink(widget.dark) : Broadside.rule(widget.dark);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: BroadsideText.mono(
                  size: 11,
                  color: fgColor,
                  trackingEm: 0.16,
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: 10),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. ImagePlaceholder
// ---------------------------------------------------------------------------

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
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Broadside.rule(dark)),
        ),
        child: AspectRatio(
          aspectRatio: aspect,
          child: Image.network(imageUrl!, fit: BoxFit.cover),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Broadside.rule(dark)),
      ),
      child: AspectRatio(
        aspectRatio: aspect,
        child: CustomPaint(
          painter: _HatchPainter(dark),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Kicker(label, dark: dark),
                    Kicker('drop image →', dark: dark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  final bool dark;

  const _HatchPainter(this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background with paper color.
    final bgPaint = Paint()..color = Broadside.paper(dark);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Draw 135-degree repeating stripes: 8px paperDeep, 8px paper (16px period).
    // At 135deg the stripe direction is top-right to bottom-left.
    // We iterate along the diagonal offset and paint paperDeep bands.
    final stripePaint = Paint()..color = Broadside.paperDeep(dark);

    // The diagonal length across the widget (bounding diagonal).
    final diagonal = math.sqrt(size.width * size.width + size.height * size.height);
    const period = 16.0;
    const bandWidth = 8.0;

    canvas.save();
    // Clip to widget bounds.
    canvas.clipRect(Offset.zero & size);

    // Rotate canvas 45 degrees around center so stripes go at 135deg.
    // 135deg from horizontal = 45deg from vertical, which visually matches
    // repeating-linear-gradient(135deg, ...).
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);
    canvas.rotate(math.pi / 4); // 45 deg
    canvas.translate(-cx, -cy);

    // After rotation, draw horizontal bands that map to 135deg stripes.
    // The diagonal of the original rect is now the "width" of our band area.
    // We need to cover [-diagonal/2, diagonal/2] around center in both axes.
    final halfDiag = diagonal / 2 + period;
    final startY = cy - halfDiag;
    final endY = cy + halfDiag;

    double y = startY;
    // Align to period boundary.
    y = (y / period).floor() * period;

    while (y < endY) {
      final bandStart = y;
      final bandEnd = y + bandWidth;
      canvas.drawRect(
        Rect.fromLTRB(cx - halfDiag, bandStart, cx + halfDiag, bandEnd),
        stripePaint,
      );
      y += period;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_HatchPainter old) => old.dark != dark;
}

// ---------------------------------------------------------------------------
// 7. ThemeToggleButton
// ---------------------------------------------------------------------------

class ThemeToggleButton extends StatelessWidget {
  final bool dark;
  final VoidCallback onToggle;

  const ThemeToggleButton({
    required this.dark,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(color: Broadside.rule(dark)),
          ),
          child: Text(
            dark ? 'DAY' : 'NIGHT',
            style: BroadsideText.mono(
              size: 10,
              color: Broadside.ink(dark),
              trackingEm: 0.16,
            ),
          ),
        ),
      ),
    );
  }
}
