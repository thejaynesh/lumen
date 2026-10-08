import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../models/portfolio_data.dart';
import '../screens/manual/index_portfolio.dart';
import '../theme/app_theme.dart';

@Preview(
  name: 'Index club · desktop light',
  group: 'Public portfolio',
  size: Size(1200, 900),
)
Widget editorialDesktopPreview() => _editorialPreview(false);

@Preview(
  name: 'Index club · mobile dark',
  group: 'Public portfolio',
  size: Size(360, 800),
)
Widget editorialMobilePreview() => _editorialPreview(true);

Widget _editorialPreview(bool dark) {
  final data = PortfolioViewData(
    settings: PortfolioSettings(
      name: 'Portfolio preview',
      role: 'Software engineer',
      tagline: 'A clear introduction to the work.',
      about:
          'Preview data for checking typography, spacing, and responsive behavior.',
      email: '',
      location: 'Preview location',
    ),
    projects: [
      Project(
        id: 'preview',
        title: 'Project preview',
        category: 'Software',
        description: 'A place for the real project description.',
        techStack: ['Dart', 'Flutter'],
        problem: 'Use the editor to describe the problem.',
        contribution: 'Explain the work you owned.',
        outcome: 'Include a verified result when available.',
      ),
    ],
    experiences: [],
  );
  return MaterialApp(
    theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: IndexPortfolio(data: data, dark: dark, onToggleTheme: () {}),
    ),
  );
}
