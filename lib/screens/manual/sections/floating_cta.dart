// Broadside FloatingCTA — §7.4
// Animated "EMAIL ME ↗" button that appears when hero CTAs scroll out of view.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/broadside_theme.dart';

class FloatingCTA extends StatelessWidget {
  final bool dark;
  final String email;
  final bool visible;

  const FloatingCTA({
    required this.dark,
    required this.email,
    required this.visible,
    super.key,
  });

  Future<void> _launch() async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _launch,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Broadside.accent(dark),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'EMAIL ME ↗',
                  style: BroadsideText.mono(
                    size: 11,
                    color: Broadside.accentInk(dark),
                    trackingEm: 0.16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
