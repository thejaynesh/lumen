import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/portfolio_data.dart';
import '../../providers/theme_provider.dart';
import '../../services/portfolio_service.dart';
import '../../theme/broadside_theme.dart';
import '../../widgets/broadside/primitives.dart';
import 'index_portfolio.dart';

class ManualPage extends StatefulWidget {
  final String? jobId;
  const ManualPage({super.key, this.jobId});
  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  late Future<PortfolioViewData> _dataFuture;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _dataFuture = context.read<PortfolioService>().getPortfolioViewData(
      widget.jobId,
    );
  }

  @override
  void didUpdateWidget(covariant ManualPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jobId != widget.jobId) _load();
  }

  Widget _status(bool dark, String title, String message) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: BroadsideText.editorial(
                size: 36,
                color: Broadside.ink(dark),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: BroadsideText.sans(
                size: 16,
                color: Broadside.inkSoft(dark),
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
    ),
  );
  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDarkMode;
    return ColoredBox(
      color: Broadside.paper(dark),
      child: SizedBox.expand(
        child: FutureBuilder<PortfolioViewData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: Broadside.accent(dark)),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _status(
                dark,
                'A moment, please.',
                'The portfolio could not load. Check your connection and try again.',
              );
            }
            final data = snapshot.data!;
            if (data.settings.name.trim().isEmpty &&
                data.projects.isEmpty &&
                data.experiences.isEmpty) {
              return _status(
                dark,
                'The portfolio is being updated.',
                'There is no published profile available yet. Please check back soon.',
              );
            }
            return IndexPortfolio(
              key: ValueKey(widget.jobId),
              data: data,
              dark: dark,
              onToggleTheme: () => context.read<ThemeProvider>().toggleTheme(),
            );
          },
        ),
      ),
    );
  }
}
