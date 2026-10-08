import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/portfolio_data.dart';
import '../../theme/broadside_theme.dart';
import '../../utils/external_links.dart';
import 'primitives.dart';

class ProjectArtwork extends StatelessWidget {
  const ProjectArtwork({super.key, required this.project, required this.dark});
  final Project project;
  final bool dark;

  static bool hasVisual(Project project) =>
      (project.imageUrl?.isNotEmpty ?? false) ||
      ['clickdrobe', 'algoview'].any(
        (name) =>
            project.title.toLowerCase().replaceAll(' ', '').contains(name),
      );

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveAssetUrl(project.imageUrl ?? '');
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          semanticLabel: '${project.title}, project screenshot',
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final name = project.title.toLowerCase().replaceAll(' ', '');
    if (name.contains('algoview')) return AlgorithmSortingDemo(dark: dark);
    if (name.contains('clickdrobe')) return _IngestionFlow(dark: dark);
    return const SizedBox.shrink();
  }
}

class _TechnicalPanel extends StatelessWidget {
  const _TechnicalPanel({
    required this.dark,
    required this.label,
    required this.child,
  });
  final bool dark;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Broadside.paper(dark),
      border: Border.all(color: Broadside.rule(dark)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Broadside.rule(dark))),
          ),
          child: Kicker(label, dark: dark, size: 10),
        ),
        Padding(padding: const EdgeInsets.all(18), child: child),
      ],
    ),
  );
}

class _IngestionFlow extends StatelessWidget {
  const _IngestionFlow({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    const stages = [
      ('Input', 'Photos & shared images', Icons.add_photo_alternate_outlined),
      (
        'Inference',
        'Gemini vision extracts garment attributes',
        Icons.auto_awesome_outlined,
      ),
      (
        'Persistence',
        'Normalized wardrobe data in PostgreSQL',
        Icons.storage_outlined,
      ),
      (
        'Application',
        'Flutter wardrobe & outfit planning',
        Icons.checkroom_outlined,
      ),
    ];
    return _TechnicalPanel(
      dark: dark,
      label: 'ClickDrobe / system overview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'From photo to wardrobe.',
            style: BroadsideText.sans(
              size: 19,
              weight: FontWeight.w600,
              color: Broadside.ink(dark),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Simplified ingestion flow',
            style: BroadsideText.sans(size: 12, color: Broadside.inkSoft(dark)),
          ),
          const SizedBox(height: 22),
          for (var i = 0; i < stages.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: i == stages.length - 1
                        ? Broadside.signal(dark)
                        : Broadside.paperDeep(dark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    stages[i].$3,
                    size: 18,
                    color: i == stages.length - 1
                        ? Broadside.signalInk(dark)
                        : Broadside.accent(dark),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stages[i].$1,
                        style: BroadsideText.sans(
                          size: 13,
                          weight: FontWeight.w600,
                          color: Broadside.ink(dark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stages[i].$2,
                        style: BroadsideText.sans(
                          size: 12,
                          height: 1.5,
                          color: Broadside.inkSoft(dark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i < stages.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 17, top: 5, bottom: 5),
                child: Container(
                  width: 1,
                  height: 20,
                  color: Broadside.rule(dark),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class AlgorithmSortingDemo extends StatefulWidget {
  const AlgorithmSortingDemo({super.key, required this.dark});
  final bool dark;
  @override
  State<AlgorithmSortingDemo> createState() => _AlgorithmSortingDemoState();
}

class _AlgorithmSortingDemoState extends State<AlgorithmSortingDemo> {
  bool _sorted = false;
  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final values = _sorted ? [1, 2, 3, 4] : [3, 1, 4, 2];
    return _TechnicalPanel(
      dark: dark,
      label: 'AlgoView / execution preview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'See the array change.',
            style: BroadsideText.sans(
              size: 19,
              weight: FontWeight.w600,
              color: Broadside.ink(dark),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Illustrative sorting demo',
            style: BroadsideText.sans(size: 12, color: Broadside.inkSoft(dark)),
          ),
          const SizedBox(height: 24),
          ExcludeSemantics(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final slot = constraints.maxWidth / 4;
                return SizedBox(
                  height: 168,
                  child: Stack(
                    children: [
                      for (var value = 1; value <= 4; value++)
                        AnimatedPositioned(
                          key: ValueKey('sort-card-$value'),
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 650),
                          curve: Curves.easeInOutCubic,
                          left: values.indexOf(value) * slot + 5,
                          width: slot - 10,
                          bottom: 0,
                          height: value * 30 + 28,
                          child: Column(
                            children: [
                              Text(
                                '$value',
                                textScaler: TextScaler.noScaling,
                                style: BroadsideText.mono(
                                  size: 13,
                                  color: Broadside.ink(dark),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: value == 4
                                        ? Broadside.signal(dark)
                                        : Broadside.accent(dark),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: Broadside.rule(dark)),
          const SizedBox(height: 18),
          Semantics(
            liveRegion: true,
            child: Text(
              '${_sorted ? 'Output' : 'Input'}: [${values.join(', ')}]',
              style: BroadsideText.mono(
                size: 12,
                trackingEm: 0,
                color: Broadside.ink(dark),
              ),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => setState(() => _sorted = !_sorted),
            icon: Icon(_sorted ? Icons.replay : Icons.play_arrow, size: 18),
            label: Text(_sorted ? 'Reset array' : 'Sort array'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Broadside.accent(dark),
              side: BorderSide(color: Broadside.rule(dark)),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(
  name: 'Technical project visuals',
  group: 'Portfolio',
  size: Size(520, 850),
)
Widget technicalProjectPreview() => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          const _IngestionFlow(dark: false),
          const SizedBox(height: 20),
          const AlgorithmSortingDemo(dark: false),
        ],
      ),
    ),
  ),
);
