import 'package:flutter/material.dart';
import '../../theme/broadside_theme.dart';

class FolioMark extends StatelessWidget {
  final bool dark;
  final double size;
  final String initials;

  const FolioMark({
    required this.dark,
    this.size = 44,
    this.initials = 'jb',
    super.key,
  });

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Transform.rotate(
      angle: -0.10,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Broadside.ink(dark), width: 0.8),
        ),
        padding: EdgeInsets.all(size * .12),
        child: FittedBox(
          child: Text(
            '${initials.toLowerCase().replaceAll('.', '')}.',
            textScaler: TextScaler.noScaling,
            style: BroadsideText.editorial(
              size: size * .50,
              color: Broadside.ink(dark),
            ),
          ),
        ),
      ),
    ),
  );
}
