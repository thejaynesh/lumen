import 'package:flutter/material.dart';
import '../../theme/broadside_theme.dart';
import 'motion.dart';

/// A project-folder shortcut whose activation opens the real project viewer.
class ProjectFolder extends StatefulWidget {
  const ProjectFolder({
    super.key,
    required this.dark,
    required this.titles,
    required this.onOpenProjects,
    this.initials = 'JB',
    this.scrollController,
  });
  final bool dark;
  final ScrollController? scrollController;
  final List<String> titles;
  final String initials;
  final VoidCallback onOpenProjects;

  @override
  State<ProjectFolder> createState() => _ProjectFolderState();
}

class _ProjectFolderState extends State<ProjectFolder> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      label: 'Open projects',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: TextButton(
          key: const ValueKey('project-folder'),
          onPressed: widget.onOpenProjects,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            overlayColor: Broadside.accent(dark).withValues(alpha: .08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: ExcludeSemantics(
            child: MediaQuery.withNoTextScaling(
              child: AspectRatio(
                aspectRatio: 410 / 420,
                child: FittedBox(
                  child: SizedBox(
                    width: 410,
                    height: 420,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: 16,
                          top: 30,
                          child: HeroParallax(
                            controller: widget.scrollController,
                            depth: -.16,
                            child: Transform.rotate(
                              angle: -.14,
                              child: Container(
                                width: 190,
                                padding: const EdgeInsets.all(22),
                                color: Broadside.signal(dark),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ENGINEERING NOTES',
                                      style: BroadsideText.mono(
                                        size: 10,
                                        color: Broadside.signalInk(dark),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      'Data models.\nAPI contracts.\nUI state.',
                                      style: BroadsideText.editorial(
                                        size: 24,
                                        style: FontStyle.italic,
                                        color: Broadside.signalInk(dark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 38,
                          top: 100,
                          child: HeroParallax(
                            controller: widget.scrollController,
                            depth: -.045,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(end: _hovered && !reduced ? 0 : .07),
                              duration: reduced
                                  ? Duration.zero
                                  : const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              builder: (context, angle, child) =>
                                  Transform.rotate(angle: angle, child: child),
                              child: SizedBox(
                                width: 285,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Broadside.accent(dark),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(9),
                                            ),
                                      ),
                                      child: Text(
                                        '${widget.titles.length.toString().padLeft(2, '0')} PROJECTS',
                                        style: BroadsideText.mono(
                                          size: 11,
                                          color: Broadside.accentInk(dark),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 285,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Broadside.accent(dark),
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(9),
                                          bottomLeft: Radius.circular(9),
                                          bottomRight: Radius.circular(9),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: .12,
                                            ),
                                            blurRadius: 16,
                                            offset: const Offset(5, 9),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${widget.initials} / SELECTED WORK',
                                            style: BroadsideText.mono(
                                              size: 10,
                                              color: Broadside.accentInk(dark),
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          Text(
                                            'Applications.\nAPIs.\nAlgorithms.',
                                            style: BroadsideText.editorial(
                                              size: 31,
                                              color: Broadside.accentInk(dark),
                                            ),
                                          ),
                                          const SizedBox(height: 22),
                                          Divider(
                                            height: 1,
                                            color: Broadside.accentInk(
                                              dark,
                                            ).withValues(alpha: .4),
                                          ),
                                          const SizedBox(height: 17),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Open projects',
                                                style: BroadsideText.sans(
                                                  size: 15,
                                                  weight: FontWeight.w600,
                                                  color: Broadside.accentInk(
                                                    dark,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_downward,
                                                size: 20,
                                                color: Broadside.accentInk(
                                                  dark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
