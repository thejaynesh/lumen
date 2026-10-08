import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/portfolio_data.dart';
import '../../providers/experience_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/portfolio_service.dart';
import '../../theme/broadside_theme.dart';
import '../../widgets/broadside/primitives.dart';

enum _Step { intro, quiz, results, personality }

class LuckyMode extends StatefulWidget {
  const LuckyMode({super.key});
  @override
  State<LuckyMode> createState() => _LuckyModeState();
}

class _LuckyModeState extends State<LuckyMode> {
  late Future<PortfolioSettings> _settingsFuture;
  _Step _step = _Step.intro;
  int _question = 0;
  int _score = 0;
  int? _selected;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _settingsFuture = context.read<PortfolioService>().getSettings();
  }

  void _exit() => context.read<ExperienceProvider>().reset();

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDarkMode;
    return ColoredBox(
      color: Broadside.paper(dark),
      child: SizedBox.expand(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _exit,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Experiences'),
                        style: TextButton.styleFrom(
                          foregroundColor: Broadside.ink(dark),
                        ),
                      ),
                    ),
                  ),
                  ThemeToggleButton(
                    dark: dark,
                    onToggle: () => context.read<ThemeProvider>().toggleTheme(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<PortfolioSettings>(
                future: _settingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Broadside.accent(dark),
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'This page could not load.',
                              style: BroadsideText.display(
                                height: 1.0,
                                letterSpacing: 0,
                                size: 32,
                                color: Broadside.ink(dark),
                              ),
                            ),
                            const SizedBox(height: 24),
                            BtnPrimary(
                              label: 'Try again',
                              dark: dark,
                              onTap: () => setState(_load),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final settings = snapshot.data!;
                  final quiz = settings.quiz
                      .where(
                        (q) =>
                            q.q.trim().isNotEmpty &&
                            q.options.length >= 2 &&
                            q.answer >= 0 &&
                            q.answer < q.options.length,
                      )
                      .toList();
                  return SingleChildScrollView(
                    key: ValueKey('${_step.name}-$_question'),
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: _body(settings, quiz, dark),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(PortfolioSettings settings, List<QuizQuestion> quiz, bool dark) {
    switch (_step) {
      case _Step.intro:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Kicker('Beyond the résumé', dark: dark),
            const SizedBox(height: 20),
            Text(
              'A little more about me.',
              style: BroadsideText.display(
                letterSpacing: 0,
                size: 48,
                color: Broadside.ink(dark),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              quiz.isEmpty && settings.personality.isEmpty
                  ? 'More personal notes are on the way. You can explore my work in the portfolio.'
                  : 'Try a short quiz, or browse the interests behind the work.',
              style: BroadsideText.sans(
                size: 17,
                color: Broadside.inkSoft(dark),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (quiz.isNotEmpty)
                  BtnPrimary(
                    label: 'Start ${quiz.length}-question quiz',
                    dark: dark,
                    onTap: () => setState(() {
                      _question = 0;
                      _score = 0;
                      _selected = null;
                      _step = _Step.quiz;
                    }),
                  ),
                if (settings.personality.isNotEmpty)
                  BtnGhost(
                    label: 'Skip to personal notes',
                    dark: dark,
                    onTap: () => setState(() => _step = _Step.personality),
                  ),
                if (quiz.isEmpty && settings.personality.isEmpty)
                  BtnGhost(
                    label: 'Back to experiences',
                    dark: dark,
                    onTap: _exit,
                  ),
              ],
            ),
          ],
        );
      case _Step.quiz:
        if (quiz.isEmpty) {
          return BtnGhost(
            label: 'Back to experiences',
            dark: dark,
            onTap: _exit,
          );
        }
        final question = quiz[_question.clamp(0, quiz.length - 1)];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Kicker('Question ${_question + 1} of ${quiz.length}', dark: dark),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (_question + 1) / quiz.length,
              color: Broadside.accent(dark),
              backgroundColor: Broadside.rule(dark),
              minHeight: 3,
            ),
            const SizedBox(height: 26),
            Text(
              question.q,
              style: BroadsideText.display(
                letterSpacing: 0,
                size: 36,
                color: Broadside.ink(dark),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 26),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth < 560
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: question.options.indexed.map((entry) {
                    final correct =
                        _selected != null && entry.$1 == question.answer;
                    final chosen = _selected == entry.$1;
                    return SizedBox(
                      width: width,
                      child: OutlinedButton(
                        onPressed: _selected != null
                            ? null
                            : () => setState(() {
                                _selected = entry.$1;
                                if (entry.$1 == question.answer) {
                                  _score++;
                                }
                              }),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          foregroundColor: Broadside.ink(dark),
                          disabledForegroundColor: Broadside.ink(dark),
                          backgroundColor: correct || chosen
                              ? Broadside.paperDeep(dark)
                              : null,
                          side: BorderSide(
                            color: correct
                                ? Broadside.accent(dark)
                                : Broadside.rule(dark),
                          ),
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              correct
                                  ? '✓'
                                  : chosen
                                  ? '•'
                                  : String.fromCharCode(65 + entry.$1),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.$2,
                                style: BroadsideText.sans(
                                  size: 16,
                                  color: Broadside.ink(dark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            if (_selected != null) ...[
              const SizedBox(height: 24),
              Semantics(
                liveRegion: true,
                child: Text(
                  _selected == question.answer
                      ? 'That’s right.'
                      : 'The answer is ${question.options[question.answer]}.',
                  style: BroadsideText.sans(
                    size: 16,
                    weight: FontWeight.w600,
                    color: Broadside.ink(dark),
                  ),
                ),
              ),
              if (question.funFact.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  question.funFact,
                  style: BroadsideText.sans(
                    size: 16,
                    color: Broadside.inkSoft(dark),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              BtnPrimary(
                label: _question + 1 < quiz.length
                    ? 'Next question →'
                    : 'See results →',
                dark: dark,
                onTap: () => setState(() {
                  if (_question + 1 < quiz.length) {
                    _question++;
                    _selected = null;
                  } else {
                    _step = _Step.results;
                  }
                }),
              ),
            ],
          ],
        );
      case _Step.results:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Kicker('Quiz complete', dark: dark),
            const SizedBox(height: 20),
            Text(
              '$_score / ${quiz.length}',
              style: BroadsideText.display(
                height: 1.0,
                letterSpacing: 0,
                size: 88,
                color: Broadside.accent(dark),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Thanks for getting to know me.',
              style: BroadsideText.display(
                height: 1.0,
                letterSpacing: 0,
                size: 36,
                color: Broadside.ink(dark),
              ),
            ),
            const SizedBox(height: 26),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (settings.personality.isNotEmpty)
                  BtnPrimary(
                    label: 'Read personal notes',
                    dark: dark,
                    onTap: () => setState(() => _step = _Step.personality),
                  ),
                if (settings.email.isNotEmpty)
                  BtnGhost(
                    label: 'Get in touch',
                    dark: dark,
                    href: 'mailto:${settings.email}',
                  ),
                BtnGhost(
                  label: 'Back to experiences',
                  dark: dark,
                  onTap: _exit,
                ),
              ],
            ),
          ],
        );
      case _Step.personality:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Kicker('Personal notes', dark: dark),
            const SizedBox(height: 20),
            Text(
              'Behind the work.',
              style: BroadsideText.display(
                height: 1.0,
                letterSpacing: 0,
                size: 48,
                color: Broadside.ink(dark),
              ),
            ),
            const SizedBox(height: 28),
            ...settings.personality.map(
              (item) => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Broadside.rule(dark))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Kicker(item.label, dark: dark),
                    const SizedBox(height: 10),
                    Text(
                      item.value,
                      style: BroadsideText.sans(
                        size: 18,
                        color: Broadside.ink(dark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (settings.email.isNotEmpty)
                  BtnPrimary(
                    label: 'Get in touch',
                    dark: dark,
                    href: 'mailto:${settings.email}',
                  ),
                BtnGhost(
                  label: 'Back to experiences',
                  dark: dark,
                  onTap: _exit,
                ),
              ],
            ),
          ],
        );
    }
  }
}
