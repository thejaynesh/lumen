import 'package:flutter/material.dart';
import '../../../widgets/broadside/primitives.dart';

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
  @override
  Widget build(BuildContext context) {
    if (email.isEmpty) return const SizedBox.shrink();
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeFocus(
        excluding: !visible,
        child: ExcludeSemantics(
          excluding: !visible,
          child: AnimatedSlide(
            offset: visible ? Offset.zero : const Offset(0, .25),
            duration: duration,
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: duration,
              child: Material(
                elevation: visible ? 8 : 0,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(40),
                child: BtnPrimary(
                  key: const ValueKey('floating-email'),
                  label: 'Email me ↗',
                  dark: dark,
                  href: 'mailto:$email',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
