import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanHistoryItem {
  const ScanHistoryItem({
    required this.id,
    required this.crop,
    required this.label,
    required this.confidence,
    required this.createdAt,
    this.imagePath,
    this.treatment = '',
  });

  final String id;
  final String crop;
  final String label;
  final double confidence;
  final DateTime createdAt;
  final String? imagePath;
  final String treatment;

  Map<String, dynamic> toJson() => {
        'id': id,
        'crop': crop,
        'label': label,
        'confidence': confidence,
        'createdAt': createdAt.toIso8601String(),
        'imagePath': imagePath,
        'treatment': treatment,
      };

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'] as String? ?? '',
      crop: json['crop'] as String? ?? '',
      label: json['label'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      imagePath: json['imagePath'] as String?,
      treatment: json['treatment'] as String? ?? '',
    );
  }
}

class ScanHistoryStore {
  static const _prefsKey = 'scan_history_v1';
  static const _maxItems = 30;

  Future<List<ScanHistoryItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    return raw
        .map((entry) {
          try {
            return ScanHistoryItem.fromJson(
              jsonDecode(entry) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<ScanHistoryItem>()
        .toList();
  }

  Future<void> add({
    required String crop,
    required String label,
    required double confidence,
    required String treatment,
    String? sourceImagePath,
  }) async {
    String? savedImagePath;
    if (sourceImagePath != null && sourceImagePath.isNotEmpty) {
      savedImagePath = await _persistImage(sourceImagePath);
    }

    final item = ScanHistoryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      crop: crop,
      label: label,
      confidence: confidence,
      createdAt: DateTime.now(),
      imagePath: savedImagePath,
      treatment: treatment,
    );

    final items = await load();
    items.insert(0, item);
    while (items.length > _maxItems) {
      final removed = items.removeLast();
      await _deleteImage(removed.imagePath);
    }
    await _save(items);
  }

  Future<void> remove(String id) async {
    final items = await load();
    ScanHistoryItem? removed;
    items.removeWhere((item) {
      if (item.id == id) {
        removed = item;
        return true;
      }
      return false;
    });
    await _deleteImage(removed?.imagePath);
    await _save(items);
  }

  Future<void> clear() async {
    final items = await load();
    for (final item in items) {
      await _deleteImage(item.imagePath);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<void> _save(List<ScanHistoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      items.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<String?> _persistImage(String sourcePath) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) {
        return null;
      }
      final dir = await getApplicationDocumentsDirectory();
      final historyDir = Directory(p.join(dir.path, 'scan_history'));
      if (!await historyDir.exists()) {
        await historyDir.create(recursive: true);
      }
      final fileName =
          'scan_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
      final dest = p.join(historyDir.path, fileName);
      await source.copy(dest);
      return dest;
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteImage(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
