import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/portfolio_data.dart';
import '../../providers/experience_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/portfolio_service.dart';
import '../../theme/broadside_theme.dart';
import '../../widgets/broadside/primitives.dart';

// ---------------------------------------------------------------------------
// Step enum
// ---------------------------------------------------------------------------

enum _Step { intro, quiz, results, personality }

// ---------------------------------------------------------------------------
// LuckyMode
// ---------------------------------------------------------------------------

class LuckyMode extends StatefulWidget {
  const LuckyMode({super.key});

  @override
  State<LuckyMode> createState() => _LuckyModeState();
}

class _LuckyModeState extends State<LuckyMode> {
  // Future guard so we only assign once
  late Future<PortfolioSettings> _settingsFuture;
  bool _futureAssigned = false;

  // Quiz state
  _Step _step = _Step.intro;
  int _qIdx = 0;
  int _score = 0;
  int? _selected;
  bool _revealed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_futureAssigned) {
      _settingsFuture = context.read<PortfolioService>().getSettings();
      _futureAssigned = true;
    }
  }

  void _pickAnswer(int i, List<QuizQuestion> quiz) {
    if (_revealed) return;
    setState(() {
      _selected = i;
      _revealed = true;
      if (i == quiz[_qIdx].answer) _score++;
    });
  }

  void _nextQ(List<QuizQuestion> quiz) {
    if (_qIdx < quiz.length - 1) {
      setState(() {
        _qIdx++;
        _selected = null;
        _revealed = false;
      });
    } else {
      setState(() => _step = _Step.results);
    }
  }

  void _exit() => context.read<ExperienceProvider>().reset();

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDarkMode;
    final accent = Broadside.accent(dark);

    return FutureBuilder<PortfolioSettings>(
      future: _settingsFuture,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container(
            color: Broadside.paper(dark),
            child: Center(
              child: CircularProgressIndicator(color: accent),
            ),
          );
        }
        final s = snap.data!;
        final quiz = s.quiz;
        final personality = s.personality;
        final email = s.email;
        final name = s.name.isNotEmpty ? s.name : 'Jaynesh Bhandari';

        return Container(
          color: Broadside.paper(dark),
          constraints: const BoxConstraints.expand(),
          child: Column(
            children: [
              _TopBar(name: name, dark: dark, onExit: _exit),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: _buildBody(
                      dark: dark,
                      quiz: quiz,
                      personality: personality,
                      email: email,
                      name: name,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody({
    required bool dark,
    required List<QuizQuestion> quiz,
    required List<PersonalityItem> personality,
    required String email,
    required String name,
  }) {
    switch (_step) {
      case _Step.intro:
        return _IntroStep(
          dark: dark,
          quizEmpty: quiz.isEmpty,
          onStartQuiz: () => setState(() => _step = _Step.quiz),
          onSkip: () => setState(() => _step = _Step.personality),
        );
      case _Step.quiz:
        return _QuizStep(
          dark: dark,
          quiz: quiz,
          qIdx: _qIdx,
          score: _score,
          selected: _selected,
          revealed: _revealed,
          onPickAnswer: _pickAnswer,
          onNextQ: _nextQ,
          onExit: _exit,
        );
      case _Step.results:
        return _ResultsStep(
          dark: dark,
          score: _score,
          total: quiz.length,
          email: email,
          onPersonality: () => setState(() => _step = _Step.personality),
        );
      case _Step.personality:
        return _PersonalityStep(
          dark: dark,
          personality: personality,
          email: email,
          onExit: _exit,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  final String name;
  final bool dark;
  final VoidCallback onExit;

  const _TopBar({
    required this.name,
    required this.dark,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Broadside.rule(dark)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // Left: name + kicker
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                name.toUpperCase(),
                style: BroadsideText.serif(
                  size: 22,
                  color: Broadside.ink(dark),
                ),
              ),
              const SizedBox(width: 14),
              Kicker(
                '· Lucky Mode',
                dark: dark,
                color: Broadside.accent(dark),
              ),
            ],
          ),
          // Right: back button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onExit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  border: Border.all(color: Broadside.rule(dark)),
                ),
                child: Text(
                  '← BACK TO MENU',
                  style: BroadsideText.mono(
                    size: 10,
                    color: Broadside.ink(dark),
                    trackingEm: 0.16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Intro step
// ---------------------------------------------------------------------------

class _IntroStep extends StatelessWidget {
  final bool dark;
  final bool quizEmpty;
  final VoidCallback onStartQuiz;
  final VoidCallback onSkip;

  const _IntroStep({
    required this.dark,
    required this.quizEmpty,
    required this.onStartQuiz,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Headline
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'So you chose\n',
                    style: BroadsideText.serif(
                      size: 80,
                      height: 0.9,
                      letterSpacing: -0.03,
                      color: Broadside.ink(dark),
                    ),
                  ),
                  TextSpan(
                    text: 'lucky.',
                    style: BroadsideText.serif(
                      size: 80,
                      height: 0.9,
                      letterSpacing: -0.03,
                      color: Broadside.accent(dark),
                      style: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Five questions. No Googling. Let\'s see how well you know me — or how well you can guess.',
              style: BroadsideText.sans(
                size: 17,
                color: Broadside.inkSoft(dark),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!quizEmpty) ...[
                  BtnPrimary(
                    label: 'Start the quiz ↘',
                    dark: dark,
                    onTap: onStartQuiz,
                  ),
                  const SizedBox(width: 12),
                ],
                BtnGhost(
                  label: 'Skip to the fun stuff',
                  dark: dark,
                  onTap: onSkip,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quiz step
// ---------------------------------------------------------------------------

class _QuizStep extends StatelessWidget {
  final bool dark;
  final List<QuizQuestion> quiz;
  final int qIdx;
  final int score;
  final int? selected;
  final bool revealed;
  final void Function(int, List<QuizQuestion>) onPickAnswer;
  final void Function(List<QuizQuestion>) onNextQ;
  final VoidCallback onExit;

  const _QuizStep({
    required this.dark,
    required this.quiz,
    required this.qIdx,
    required this.score,
    required this.selected,
    required this.revealed,
    required this.onPickAnswer,
    required this.onNextQ,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    // Guard: empty quiz
    if (quiz.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Kicker('No quiz configured', dark: dark),
            const SizedBox(height: 24),
            BtnGhost(label: '← Back to menu', dark: dark, onTap: onExit),
          ],
        ),
      );
    }

    final q = quiz[qIdx];
    final answer = q.answer;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Kicker('Question ${qIdx + 1} / ${quiz.length}', dark: dark),
              Kicker('Score: $score', dark: dark),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar
          Container(
            height: 3,
            color: Broadside.rule(dark),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: (qIdx + 1) / quiz.length,
                child: Container(color: Broadside.accent(dark)),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Question text
          Text(
            q.q,
            style: BroadsideText.serif(
              size: 36,
              height: 1.15,
              letterSpacing: -0.01,
              color: Broadside.ink(dark),
            ),
          ),
          const SizedBox(height: 28),

          // Answer grid (2 columns via Column of Rows)
          ..._buildAnswerGrid(q, answer),

          // Fun fact card (revealed)
          if (revealed) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              color: Broadside.paperDeep(dark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker(
                    selected == answer ? '✓ Correct!' : '✗ Not quite.',
                    dark: dark,
                    color: selected == answer
                        ? Broadside.accent(dark)
                        : Broadside.inkSoft(dark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q.funFact,
                    style: BroadsideText.sans(
                      size: 14,
                      color: Broadside.inkSoft(dark),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 14),
                  BtnPrimary(
                    label: qIdx < quiz.length - 1 ? 'Next question →' : 'See results →',
                    dark: dark,
                    onTap: () => onNextQ(quiz),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildAnswerGrid(QuizQuestion q, int answer) {
    final opts = q.options;
    // Build rows of 2
    final rows = <Widget>[];
    for (int r = 0; r < opts.length; r += 2) {
      final hasSecond = r + 1 < opts.length;
      final i0 = r;
      final i1 = r + 1;
      rows.add(
        Row(
          children: [
            Expanded(
              child: _AnswerButton(
                index: i0,
                text: opts[i0],
                dark: dark,
                answer: answer,
                selected: selected,
                revealed: revealed,
                onTap: () => onPickAnswer(i0, quiz),
              ),
            ),
            if (hasSecond) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _AnswerButton(
                  index: i1,
                  text: opts[i1],
                  dark: dark,
                  answer: answer,
                  selected: selected,
                  revealed: revealed,
                  onTap: () => onPickAnswer(i1, quiz),
                ),
              ),
            ] else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (r + 2 < opts.length) rows.add(const SizedBox(height: 12));
    }
    return rows;
  }
}

// ---------------------------------------------------------------------------
// Answer button
// ---------------------------------------------------------------------------

class _AnswerButton extends StatelessWidget {
  final int index;
  final String text;
  final bool dark;
  final int answer;
  final int? selected;
  final bool revealed;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.index,
    required this.text,
    required this.dark,
    required this.answer,
    required this.selected,
    required this.revealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = index == answer;
    final isSelected = index == selected;

    Color bg;
    Color border;
    Color textColor;

    if (revealed && isCorrect) {
      bg = Broadside.accent(dark);
      border = Broadside.accent(dark);
      textColor = Broadside.accentInk(dark);
    } else if (revealed && isSelected && !isCorrect) {
      bg = Broadside.paperDeep(dark);
      border = Broadside.inkSoft(dark);
      textColor = Broadside.inkSoft(dark);
    } else {
      bg = Colors.transparent;
      border = Broadside.rule(dark);
      textColor = Broadside.ink(dark);
    }

    return MouseRegion(
      cursor: revealed ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: revealed ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Text(
                String.fromCharCode(65 + index),
                style: BroadsideText.mono(
                  size: 10,
                  color: textColor.withValues(alpha: 0.6),
                  trackingEm: 0.16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: BroadsideText.sans(
                    size: 15,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Results step
// ---------------------------------------------------------------------------

class _ResultsStep extends StatelessWidget {
  final bool dark;
  final int score;
  final int total;
  final String email;
  final VoidCallback onPersonality;

  const _ResultsStep({
    required this.dark,
    required this.score,
    required this.total,
    required this.email,
    required this.onPersonality,
  });

  String get _scoreLabel {
    if (score == total) return "Perfect. You stalked my LinkedIn, didn't you?";
    if (score >= 3) return "Not bad. You clearly read more than the headline.";
    if (score >= 1) return "Room for improvement. Maybe try the Manual mode first.";
    return "Zero? We clearly haven't met. Let's fix that.";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Kicker('Quiz Complete', dark: dark),
            const SizedBox(height: 16),
            Text(
              '$score/$total',
              style: BroadsideText.serif(
                size: 120,
                height: 0.9,
                color: Broadside.accent(dark),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _scoreLabel,
              style: BroadsideText.serif(
                size: 28,
                height: 1.3,
                color: Broadside.ink(dark),
                style: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BtnPrimary(
                  label: 'See the personality page ↘',
                  dark: dark,
                  onTap: onPersonality,
                ),
                const SizedBox(width: 12),
                BtnGhost(
                  label: 'Just email me already',
                  dark: dark,
                  href: 'mailto:$email',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Personality step
// ---------------------------------------------------------------------------

class _PersonalityStep extends StatelessWidget {
  final bool dark;
  final List<PersonalityItem> personality;
  final String email;
  final VoidCallback onExit;

  const _PersonalityStep({
    required this.dark,
    required this.personality,
    required this.email,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Kicker('The Unfiltered Version', dark: dark),
          const SizedBox(height: 16),
          // Headline
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Things that don\'t fit\n',
                  style: BroadsideText.serif(
                    size: 52,
                    height: 1.05,
                    letterSpacing: -0.02,
                    color: Broadside.ink(dark),
                  ),
                ),
                TextSpan(
                  text: 'on a résumé.',
                  style: BroadsideText.serif(
                    size: 52,
                    height: 1.05,
                    letterSpacing: -0.02,
                    color: Broadside.accent(dark),
                    style: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // 2-col grid of personality items
          if (personality.isNotEmpty) ..._buildPersonalityGrid(),

          // Call Me Maybe block
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
            color: Broadside.accent(dark),
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  'Hey, I just met you, and this is crazy…',
                  style: BroadsideText.serif(
                    size: 36,
                    height: 1.1,
                    color: Broadside.accentInk(dark),
                    style: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Opacity(
                  opacity: 0.9,
                  child: Text(
                    'But here\'s my email, so hire me maybe?',
                    style: BroadsideText.sans(
                      size: 15,
                      color: Broadside.accentInk(dark),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 18),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => launchUrl(Uri.parse('mailto:$email')),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      color: Broadside.accentInk(dark),
                      child: Text(
                        '${email.toUpperCase()} ↗',
                        style: BroadsideText.mono(
                          size: 11,
                          color: Broadside.accent(dark),
                          trackingEm: 0.16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: BtnGhost(label: '← Back to menu', dark: dark, onTap: onExit),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPersonalityGrid() {
    final rows = <Widget>[];
    for (int r = 0; r < personality.length; r += 2) {
      final hasSecond = r + 1 < personality.length;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _PersonalityCard(item: personality[r], dark: dark)),
            const SizedBox(width: 20),
            hasSecond
                ? Expanded(
                    child: _PersonalityCard(
                      item: personality[r + 1],
                      dark: dark,
                    ),
                  )
                : const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (r + 2 < personality.length) rows.add(const SizedBox(height: 20));
    }
    return rows;
  }
}

class _PersonalityCard extends StatelessWidget {
  final PersonalityItem item;
  final bool dark;

  const _PersonalityCard({required this.item, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: Broadside.rule(dark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kicker(item.label, dark: dark),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: BroadsideText.serif(
              size: 18,
              height: 1.3,
              color: Broadside.ink(dark),
            ),
          ),
        ],
      ),
    );
  }
}
