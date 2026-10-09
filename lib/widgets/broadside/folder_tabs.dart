import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/broadside_theme.dart';
import 'motion.dart';

class FolderEntry {
  const FolderEntry({
    required this.id,
    required this.label,
    required this.child,
  });
  final String id;
  final String label;
  final Widget child;
}

/// One folder, with a visible tab for every entry and one active sheet.
class FolderTabs extends StatefulWidget {
  const FolderTabs({
    super.key,
    required this.entries,
    required this.dark,
    required this.tabPrefix,
  });
  final List<FolderEntry> entries;
  final bool dark;
  final String tabPrefix;

  @override
  State<FolderTabs> createState() => _FolderTabsState();
}

class _FolderTabsState extends State<FolderTabs> with TickerProviderStateMixin {
  late TabController _controller;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    final index = widget.entries.indexWhere((entry) => entry.id == _selectedId);
    _controller = TabController(
      length: widget.entries.length,
      initialIndex: index < 0 ? 0 : index,
      animationDuration: Duration.zero,
      vsync: this,
    )..addListener(_select);
    _selectedId = widget.entries.isEmpty
        ? null
        : widget.entries[_controller.index].id;
  }

  void _select() {
    if (widget.entries.isEmpty ||
        _selectedId == widget.entries[_controller.index].id) {
      return;
    }
    setState(() => _selectedId = widget.entries[_controller.index].id);
  }

  @override
  void didUpdateWidget(covariant FolderTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(
      oldWidget.entries.map((e) => e.id).toList(),
      widget.entries.map((e) => e.id).toList(),
    )) {
      _controller.dispose();
      _createController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) return const SizedBox.shrink();
    final dark = widget.dark;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 240);
    final tabHeight = MediaQuery.textScalerOf(context).scale(15) * 1.5 + 26;
    final sheet = KeyedSubtree(
      key: ValueKey(_selectedId),
      child: widget.entries[_controller.index].child,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        var totalTabWidth = 0.0;
        for (final entry in widget.entries) {
          final painter = TextPainter(
            text: TextSpan(
              text: entry.label,
              style: BroadsideText.sans(size: 15, weight: FontWeight.w600),
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 1,
          )..layout();
          totalTabWidth += painter.width + 48;
          painter.dispose();
        }
        final overflow = totalTabWidth > constraints.maxWidth;
        final tabWidth = constraints.maxWidth - (overflow ? 96 : 0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TabBar(
                    controller: _controller,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerHeight: 0,
                    indicator: const BoxDecoration(),
                    labelPadding: const EdgeInsets.only(right: 6),
                    overlayColor: WidgetStatePropertyAll(
                      Broadside.accent(dark).withValues(alpha: .12),
                    ),
                    splashBorderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    tabs: [
                      for (final entry in widget.entries)
                        Tab(
                          key: ValueKey('${widget.tabPrefix}-tab-${entry.id}'),
                          height: tabHeight,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: tabWidth - 8),
                            child: IntrinsicWidth(
                              child: AnimatedContainer(
                                duration: duration,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: entry.id == _selectedId
                                      ? Broadside.accent(dark)
                                      : Broadside.paperDeep(dark),
                                  border: Border.all(
                                    color: Broadside.accent(dark).withValues(
                                      alpha: entry.id == _selectedId ? 1 : .45,
                                    ),
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  entry.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: BroadsideText.sans(
                                    size: 15,
                                    weight: FontWeight.w600,
                                    color: entry.id == _selectedId
                                        ? Broadside.accentInk(dark)
                                        : Broadside.ink(dark),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (overflow) ...[
                  IconButton(
                    tooltip: 'Previous ${widget.tabPrefix}',
                    onPressed: _controller.index > 0
                        ? () => _controller.animateTo(_controller.index - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    tooltip: 'Next ${widget.tabPrefix}',
                    onPressed: _controller.index < widget.entries.length - 1
                        ? () => _controller.animateTo(_controller.index + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Broadside.paperAlt(dark),
                border: Border.all(color: Broadside.accent(dark)),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: duration == Duration.zero
                  ? sheet
                  : AnimatedSize(
                      duration: duration,
                      alignment: Alignment.topCenter,
                      curve: Curves.easeOutCubic,
                      child: MotionEntrance(
                        key: ValueKey(_selectedId),
                        distance: 22,
                        child: sheet,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
