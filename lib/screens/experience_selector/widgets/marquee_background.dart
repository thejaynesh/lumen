import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Horizontal scrolling marquee background with infinite scrolling animation.
/// Displays portfolio-related keywords in multiple rows with varying speeds.
class MarqueeBackground extends StatefulWidget {
  const MarqueeBackground({super.key});

  @override
  State<MarqueeBackground> createState() => _MarqueeBackgroundState();
}

class _MarqueeBackgroundState extends State<MarqueeBackground> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define marquee rows with different speeds and styled content
    final rows = [
      _MarqueeRow(
        words: [
          MarqueeWord('DEVELOPER', fontWeight: FontWeight.w900), // Bold
          MarqueeWord('DESIGNER', fontStyle: FontStyle.italic), // Italic
          MarqueeWord('CREATOR', isOutlined: true), // Thin/Outlined
          MarqueeWord('INNOVATOR', fontWeight: FontWeight.w900),
          MarqueeWord('BUILDER', fontStyle: FontStyle.italic),
          MarqueeWord('THINKER', isOutlined: true),
        ],
        fontSize: 80, // Reduced from 120
        speed: 50,
        highlightIndices: [0, 3],
        blueIndices: [2],
      ),
      _MarqueeRow(
        words: [
          MarqueeWord('PORTFOLIO', fontWeight: FontWeight.w300), // Thin
          MarqueeWord('PROJECTS', fontWeight: FontWeight.bold),
          MarqueeWord('EXPERIENCE', isOutlined: true),
          MarqueeWord('SKILLS', fontWeight: FontWeight.w300),
          MarqueeWord('WORK', fontWeight: FontWeight.bold),
          MarqueeWord('SHOWCASE', isOutlined: true),
        ],
        fontSize: 30, // Reduced from 40
        speed: 35,
        highlightIndices: [1, 4],
        blueIndices: [0],
      ),
      _MarqueeRow(
        words: [
          MarqueeWord(
            'CODE',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
          ),
          MarqueeWord('DESIGN', isOutlined: true),
          MarqueeWord('BUILD', fontWeight: FontWeight.bold),
          MarqueeWord(
            'SHIP',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
          ),
          MarqueeWord('ITERATE', isOutlined: true),
          MarqueeWord('IMPROVE', fontWeight: FontWeight.bold),
          MarqueeWord('LEARN', isOutlined: true),
        ],
        fontSize: 60, // Reduced from 90
        speed: 45,
        highlightIndices: [2, 5],
        blueIndices: [1],
      ),
      _MarqueeRow(
        words: [
          MarqueeWord('CREATIVE', fontWeight: FontWeight.w100), // Very thin
          MarqueeWord('TECHNICAL', fontWeight: FontWeight.bold),
          MarqueeWord('PASSIONATE', isOutlined: true),
          MarqueeWord('DRIVEN', fontWeight: FontWeight.w100),
          MarqueeWord('FOCUSED', fontWeight: FontWeight.bold),
          MarqueeWord('DEDICATED', isOutlined: true),
        ],
        fontSize: 45, // Reduced from 60
        speed: 30,
        highlightIndices: [0, 3],
        blueIndices: [4],
      ),
    ];

    // Calculate how many rows we need to fill the screen
    double totalHeight = 0;
    final displayRows = <_MarqueeRow>[];
    int rowIndex = 0;

    while (totalHeight < screenHeight) {
      final row = rows[rowIndex % rows.length];
      displayRows.add(row);
      totalHeight += row.fontSize * 1.2 + 20; // row height + gap
      rowIndex++;
    }

    return Stack(
      children: [
        // Marquee rows
        ...displayRows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;

          // Calculate cumulative position based on all previous rows
          double topPosition = 0;
          for (int i = 0; i < index; i++) {
            topPosition +=
                displayRows[i].fontSize * 1.2 + 20; // row height + gap
          }

          return Positioned(
            top: topPosition,
            left: 0,
            child: _MarqueeRowWidget(row: row, screenWidth: screenWidth),
          );
        }),

        // Gradient overlays for fade effect
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0A0F),
                  const Color(0xFF0A0A0F).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  const Color(0xFF0A0A0F),
                  const Color(0xFF0A0A0F).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MarqueeWord {
  final String text;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final bool isOutlined;

  MarqueeWord(
    this.text, {
    this.fontWeight,
    this.fontStyle,
    this.isOutlined = false,
  });
}

/// Data model for a single marquee row
class _MarqueeRow {
  final List<MarqueeWord> words;
  final double fontSize;
  final double speed;
  final List<int> highlightIndices;
  final List<int> blueIndices;

  _MarqueeRow({
    required this.words,
    required this.fontSize,
    required this.speed,
    this.highlightIndices = const [],
    this.blueIndices = const [],
  });
}

/// Widget that renders a single scrolling marquee row
class _MarqueeRowWidget extends StatefulWidget {
  final _MarqueeRow row;
  final double screenWidth;

  const _MarqueeRowWidget({required this.row, required this.screenWidth});

  @override
  State<_MarqueeRowWidget> createState() => _MarqueeRowWidgetState();
}

class _MarqueeRowWidgetState extends State<_MarqueeRowWidget> {
  late ScrollController _scrollController;
  Ticker? _ticker;
  Duration? _lastTime;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Start scrolling after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _ticker = Ticker(_onTick)..start();
      }
    });
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !_scrollController.hasClients) return;

    if (_lastTime != null) {
      final delta = (elapsed - _lastTime!).inMilliseconds / 1000.0;
      final currentOffset = _scrollController.offset;
      final newOffset = currentOffset + widget.row.speed * delta;

      _scrollController.jumpTo(newOffset);
    }

    _lastTime = elapsed;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.screenWidth,
      height:
          widget.row.fontSize * 1.2, // Extra height to prevent text cropping
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          // Use modulo to cycle through the words indefinitely
          final safeIndex = index % widget.row.words.length;

          final wordData = widget.row.words[safeIndex];
          final highlight = widget.row.highlightIndices.contains(safeIndex);
          final isBlue = widget.row.blueIndices.contains(safeIndex);

          Color textColor;
          if (isBlue) {
            textColor = const Color(
              0xFF60A5FA,
            ).withValues(alpha: 0.5); // Dimmer blue accent
          } else if (highlight) {
            textColor = Colors.white.withValues(
              alpha: 0.3,
            ); // Dimmer highlighted text
          } else {
            textColor = Colors.white.withValues(
              alpha: 0.05,
            ); // Very faint default text
          }

          // Handle outlined text or normal text
          Widget textWidget;
          if (wordData.isOutlined) {
            textWidget = Text(
              wordData.text,
              style: GoogleFonts.montserrat(
                // Changed to Montserrat
                fontSize: widget.row.fontSize,
                fontWeight:
                    wordData.fontWeight ??
                    FontWeight.w900, // Outline needs weight
                fontStyle: wordData.fontStyle,
                color: Colors.transparent, // Hollow center
                letterSpacing: 3,
                decoration: TextDecoration.none,
                shadows: [
                  Shadow(offset: const Offset(-1.5, -1.5), color: textColor),
                  Shadow(offset: const Offset(1.5, -1.5), color: textColor),
                  Shadow(offset: const Offset(1.5, 1.5), color: textColor),
                  Shadow(offset: const Offset(-1.5, 1.5), color: textColor),
                ],
              ),
            );
          } else {
            textWidget = Text(
              wordData.text,
              style: GoogleFonts.montserrat(
                // Changed to Montserrat
                fontSize: widget.row.fontSize,
                fontWeight:
                    wordData.fontWeight ??
                    (highlight || isBlue ? FontWeight.w800 : FontWeight.w600),
                fontStyle: wordData.fontStyle,
                color: textColor,
                letterSpacing: 3,
              ),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
              ), // Increased padding for better word separation
              child: textWidget,
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 1000.ms, curve: Curves.easeOutQuad);
  }
}
