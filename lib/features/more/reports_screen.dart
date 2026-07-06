import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_banner.dart';
import '../../models/insight.dart';
import '../../services/app_services.dart';
import '../../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<ReportOption> _options = [];
  List<GeneratedReport> _reports = [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final services = AppServices.instance;
    final options = await services.reports.getReportOptions();
    final reports = await services.reports.listReports();
    setState(() {
      _options = options;
      _reports = reports;
      _loading = false;
    });
  }

  Future<void> _generate(String reportType) async {
    setState(() => _busy = true);
    final result = await AppServices.instance.reports.generateReport(reportType);
    if (mounted) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      if (result.success) await _load();
    }
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    final result = await AppServices.instance.reports.exportAndShare();
    if (mounted) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const PlaceholderBanner(
                    message:
                        'Reports summarize data you logged. They are for personal reflection — not medical advice.',
                  ),
                  const SizedBox(height: 16),
                  Text('Generate', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._options.where((o) => o.id != 'export').map(
                        (opt) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.description_outlined),
                            title: Text(opt.title),
                            subtitle: Text(opt.description),
                            trailing: _busy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.play_arrow),
                            onTap: _busy ? null : () => _generate(opt.id),
                          ),
                        ),
                      ),
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: const Text('Export data bundle'),
                    subtitle: const Text('JSON export via share sheet'),
                    onTap: _busy ? null : _export,
                  ),
                  const SizedBox(height: 16),
                  Text('Saved reports', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_reports.isEmpty)
                    const Text('No reports generated yet.')
                  else
                    ..._reports.map(
                      (r) => ListTile(
                        title: Text(r.title),
                        subtitle: Text('${r.reportType} · ${r.generatedAt}'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
