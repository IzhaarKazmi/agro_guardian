import 'dart:io';

import 'package:agro_guardian/l10n/app_strings.dart';
import 'package:agro_guardian/services/scan_history_store.dart';
import 'package:agro_guardian/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScanHistoryStore _store = ScanHistoryStore();
  late Future<List<ScanHistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _store.load();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _store.load();
    });
    await _future;
  }

  Future<void> _clearAll() async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.historyClearConfirmTitle),
          content: Text(strings.historyClearConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.historyClear),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _store.clear();
    await _reload();
  }

  Future<void> _deleteItem(ScanHistoryItem item) async {
    await _store.remove(item.id);
    await _reload();
  }

  void _showDetails(ScanHistoryItem item) {
    final strings = AppStrings.of(context);
    final date = DateFormat.yMMMd().add_jm().format(item.createdAt.toLocal());

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.historyDetails,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                if (item.imagePath != null &&
                    File(item.imagePath!).existsSync())
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(item.imagePath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 14),
                _detailRow(strings.selectedCrop, item.crop),
                _detailRow(strings.disease, item.label),
                _detailRow(
                  strings.confidence,
                  '${item.confidence.toStringAsFixed(1)}%',
                ),
                _detailRow('', date),
                if (item.treatment.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    strings.treatmentInfo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.treatment,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            if (label.isNotEmpty)
              TextSpan(
                text: '$label: ',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _confidenceColor(double confidence) {
    if (confidence >= 75) {
      return AppColors.primary;
    }
    if (confidence >= 50) {
      return AppColors.warning;
    }
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF102018),
              AppColors.background,
              Color(0xFF070F0B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.historyTitle,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            strings.historySavedLocally,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _clearAll,
                      child: Text(strings.historyClear),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<ScanHistoryItem>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(
                                  Icons.history_rounded,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                strings.historyEmpty,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                strings.historyEmptyHint,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surfaceElevated,
                      onRefresh: _reload,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final date = DateFormat.MMMd()
                              .add_jm()
                              .format(item.createdAt.toLocal());
                          final confidenceColor =
                              _confidenceColor(item.confidence);
                          final hasImage = item.imagePath != null &&
                              File(item.imagePath!).existsSync();

                          return Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: AlignmentDirectional.centerEnd,
                              padding: const EdgeInsetsDirectional.only(end: 20),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                strings.historyDelete,
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            onDismissed: (_) => _deleteItem(item),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => _showDetails(item),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(18),
                                    border:
                                        Border.all(color: AppColors.border),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: SizedBox(
                                            width: 64,
                                            height: 64,
                                            child: hasImage
                                                ? Image.file(
                                                    File(item.imagePath!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : ColoredBox(
                                                    color: AppColors.surface,
                                                    child: Icon(
                                                      Icons.eco_rounded,
                                                      color: AppColors.primary
                                                          .withValues(
                                                        alpha: 0.8,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.label,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.crop,
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                date,
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: confidenceColor.withValues(
                                              alpha: 0.14,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            border: Border.all(
                                              color: confidenceColor.withValues(
                                                alpha: 0.4,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            '${item.confidence.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              color: confidenceColor,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
