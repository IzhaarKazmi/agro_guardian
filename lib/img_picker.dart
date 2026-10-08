import 'dart:io';

import 'package:agro_guardian/asset_helpers.dart';
import 'package:agro_guardian/history_page.dart';
import 'package:agro_guardian/l10n/app_strings.dart';
import 'package:agro_guardian/l10n/locale_controller.dart';
import 'package:agro_guardian/l10n/locale_scope.dart';
import 'package:agro_guardian/login_page.dart';
import 'package:agro_guardian/services/scan_history_store.dart';
import 'package:agro_guardian/theme/app_theme.dart';
import 'package:agro_guardian/widgets/language_toggle.dart';
import 'package:agro_guardian/widgets/weather_insights_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({super.key});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _GateOutcome {
  const _GateOutcome({
    required this.rawLabel,
    required this.confidence,
    this.cropCategory,
    this.isOther = false,
  });

  final String rawLabel;
  final double confidence;
  final String? cropCategory;
  final bool isOther;
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  static const double GATE_MIN_CONF = 0.65;
  static const double GATE_STRONG_CONF = 0.85;

  static const String _gateModel = 'assets/gate_model.tflite';
  static const String _gateLabels = 'assets/gate.txt';
  static const String _appleModel = 'assets/apple_model.tflite';
  static const String _appleLabels = 'assets/apple.txt';
  static const String _grapesModel = 'assets/grapes_model.tflite';
  static const String _grapesLabels = 'assets/grapes.txt';
  static const String _cornModel = 'assets/corn_model.tflite';
  static const String _cornLabels = 'assets/corn.txt';

  final ImagePicker _picker = ImagePicker();
  final ScanHistoryStore _historyStore = ScanHistoryStore();
  final List<File> _pickedImages = [];

  String _selectedCategory = '';
  List<dynamic>? _output;
  bool _showResults = false;
  bool _isProcessing = false;
  String _treatment = '';
  String? _lastLabel;
  LocaleController? _localeController;

  void _onLocaleChanged() {
    if (!mounted || _lastLabel == null || _localeController == null) {
      return;
    }
    setState(() {
      _treatment =
          AppStrings(_localeController!.locale).treatmentFor(_lastLabel!);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = LocaleScope.of(context);
    if (!identical(_localeController, controller)) {
      _localeController?.removeListener(_onLocaleChanged);
      _localeController = controller;
      _localeController!.addListener(_onLocaleChanged);
    }
    if (_treatment.isEmpty) {
      _treatment = AppStrings.of(context).noTreatment;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await _picker.pickImage(source: source);

    if (pickedImage == null || !mounted) {
      return;
    }

    setState(() {
      _pickedImages
        ..clear()
        ..add(File(pickedImage.path));
      _output = null;
      _showResults = false;
      _lastLabel = null;
      _treatment = AppStrings.of(context).noTreatment;
    });
  }

  void _clearImage() {
    setState(() {
      _pickedImages.clear();
      _output = null;
      _showResults = false;
      _lastLabel = null;
      _treatment = AppStrings.of(context).noTreatment;
    });
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _loadModel(String model, String labels) async {
    try {
      final result = await Tflite.loadModel(model: model, labels: labels);
      debugPrint('TFLite loadModel result: $result ($model / $labels)');
      return result == 'success';
    } catch (e, st) {
      debugPrint('Error loading model: $e\n$st');
      if (mounted) {
        _showMessage(AppStrings.of(context).modelLoadFailed);
      }
      return false;
    }
  }

  String _modelPathForCategory(String category) {
    switch (category) {
      case 'Apple':
        return _appleModel;
      case 'Grapes':
        return _grapesModel;
      case 'Corn':
        return _cornModel;
      default:
        return '';
    }
  }

  String _labelsPathForCategory(String category) {
    switch (category) {
      case 'Apple':
        return _appleLabels;
      case 'Grapes':
        return _grapesLabels;
      case 'Corn':
        return _cornLabels;
      default:
        return '';
    }
  }

  String _localizedCrop(AppStrings strings, String category) {
    switch (category) {
      case 'Apple':
        return strings.apple;
      case 'Grapes':
        return strings.grapes;
      case 'Corn':
        return strings.corn;
      default:
        return category;
    }
  }

  String? _categoryFromGateLabel(String label) {
    final bare =
        label.replaceFirst(RegExp(r'^\d+\s+'), '').trim().toLowerCase();
    switch (bare) {
      case 'apple':
        return 'Apple';
      case 'grape':
        return 'Grapes';
      case 'corn':
        return 'Corn';
      case 'other':
        return null;
      default:
        return null;
    }
  }

  bool _isGateOtherLabel(String label) {
    final bare =
        label.replaceFirst(RegExp(r'^\d+\s+'), '').trim().toLowerCase();
    return bare == 'other';
  }

  Future<List<dynamic>?> _runModelOnPickedImage({
    int numResults = 5,
    double threshold = 0.05,
  }) {
    return Tflite.runModelOnImage(
      path: _pickedImages.last.path,
      numResults: numResults,
      threshold: threshold,
      imageMean: 0.0,
      imageStd: 1.0,
    );
  }

  Future<_GateOutcome?> _runGate(AppStrings strings) async {
    final modelLoaded = await _loadModel(_gateModel, _gateLabels);
    if (!modelLoaded || !mounted) {
      return null;
    }

    final output = await _runModelOnPickedImage(
      numResults: 4,
      threshold: 0.0,
    );

    if (!mounted) {
      return null;
    }

    if (output == null || output.isEmpty) {
      _showMessage(strings.noPrediction);
      return null;
    }

    final rawLabel = output.first['label'] as String? ?? '';
    final confidence =
        (output.first['confidence'] as num?)?.toDouble() ?? 0.0;
    final isOther = _isGateOtherLabel(rawLabel);
    final cropCategory = isOther ? null : _categoryFromGateLabel(rawLabel);

    debugPrint(
      'Gate: label=$rawLabel confidence=$confidence '
      'crop=$cropCategory strong=${confidence >= GATE_STRONG_CONF}',
    );

    return _GateOutcome(
      rawLabel: rawLabel,
      confidence: confidence,
      cropCategory: cropCategory,
      isOther: isOther,
    );
  }

  Future<void> _showGateRejectDialog(AppStrings strings) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.gateRejectTitle),
          content: Text(strings.gateRejectMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.ok),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showGateMismatchDialog(
    AppStrings strings, {
    required String detectedCategory,
    required String selectedCategory,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.gateMismatchTitle),
          content: Text(
            strings.gateCropMismatch(detectedCategory, selectedCategory),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.gateSwitchTo(detectedCategory)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _runDiseaseInference(AppStrings strings) async {
    final modelLoaded = await _loadModel(
      _modelPathForCategory(_selectedCategory),
      _labelsPathForCategory(_selectedCategory),
    );

    if (!modelLoaded || !mounted) {
      return;
    }

    final output = await _runModelOnPickedImage();

    if (!mounted) {
      return;
    }

    if (output == null || output.isEmpty) {
      _showMessage(strings.noPrediction);
      return;
    }

    final label = output.first['label'] as String? ?? 'Unknown';
    final confidence =
        ((output.first['confidence'] as num?)?.toDouble() ?? 0) * 100;
    final treatment = strings.treatmentFor(label);

    setState(() {
      _output = output;
      _showResults = true;
      _lastLabel = label;
      _treatment = treatment;
    });

    await _historyStore.add(
      crop: _selectedCategory,
      label: label,
      confidence: confidence,
      treatment: treatment,
      sourceImagePath: _pickedImages.last.path,
    );

    await _showResultsDialog();
  }

  String _guidanceTip(AppStrings strings) {
    if (_pickedImages.isEmpty) {
      return strings.tipPickImage;
    }
    if (_selectedCategory.isEmpty) {
      return strings.tipSelectCrop;
    }
    if (!_showResults) {
      return strings.tipReady;
    }
    return '';
  }

  Future<void> _runInference() async {
    final strings = AppStrings.of(context);

    if (_pickedImages.isEmpty) {
      _showMessage(strings.selectImageFirst);
      return;
    }

    if (_selectedCategory.isEmpty) {
      _showMessage(strings.selectCropFirst);
      return;
    }

    setState(() {
      _isProcessing = true;
      _output = null;
      _showResults = false;
      _treatment = strings.noTreatment;
    });

    try {
      final gate = await _runGate(strings);
      if (gate == null || !mounted) {
        return;
      }

      if (gate.isOther ||
          gate.cropCategory == null ||
          gate.confidence < GATE_MIN_CONF) {
        await _showGateRejectDialog(strings);
        return;
      }

      if (gate.cropCategory != _selectedCategory) {
        final shouldSwitch = await _showGateMismatchDialog(
          strings,
          detectedCategory: gate.cropCategory!,
          selectedCategory: _selectedCategory,
        );

        if (!mounted) {
          return;
        }

        if (shouldSwitch != true) {
          return;
        }

        setState(() {
          _selectedCategory = gate.cropCategory!;
        });
      }

      await _runDiseaseInference(strings);
    } catch (e) {
      debugPrint('Error during inference: $e');
      _showMessage(strings.detectionFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _output = null;
      _showResults = false;
      _lastLabel = null;
      _treatment = AppStrings.of(context).noTreatment;
    });
  }

  Future<void> _showResultsDialog() async {
    if (_output == null || _output!.isEmpty || !mounted) {
      return;
    }

    final strings = AppStrings.of(context);
    final label = _output!.first['label'] as String? ?? 'Unknown';
    final confidence = (_output!.first['confidence'] as num? ?? 0) * 100;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.results),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${strings.disease}: $label',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${strings.confidence}: ${confidence.toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.ok),
            ),
          ],
        );
      },
    );
  }

  void _showTreatmentDialog() {
    if (!_showResults) {
      return;
    }

    final strings = AppStrings.of(context);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.treatmentInfo),
          content: Text(_treatment),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.logoutConfirmTitle),
          content: Text(strings.logoutConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.logout),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await FirebaseAuth.instance.signOut();
    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _localeController?.removeListener(_onLocaleChanged);
    Tflite.close();
    super.dispose();
  }

  Widget _cropCard({
    required String category,
    required String label,
    required String imageAsset,
    required IconData placeholderIcon,
  }) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            assetImageOrPlaceholder(
              imageAsset,
              width: 46,
              height: 46,
              placeholderIcon: placeholderIcon,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final tip = _guidanceTip(strings);
    final canShowTreatment = _showResults && _output != null;

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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.detectDisease,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            strings.detectSubtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    LanguageToggle(controller: LocaleScope.of(context)),
                    IconButton(
                      tooltip: strings.history,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.history_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    IconButton(
                      tooltip: strings.logout,
                      onPressed: _logout,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: [
                      const WeatherInsightsCard(),
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 230,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _pickedImages.isNotEmpty
                                ? Image.file(
                                    _pickedImages.last,
                                    fit: BoxFit.cover,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 48,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        strings.noImageSelected,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          if (_pickedImages.isNotEmpty)
                            PositionedDirectional(
                              top: 10,
                              end: 10,
                              child: Material(
                                color: AppColors.surfaceElevated
                                    .withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: _isProcessing ? null : _clearImage,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: AppColors.textPrimary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          strings.clearImage,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
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
                      if (tip.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            tip,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          strings.chooseCrop,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _cropCard(
                              category: 'Apple',
                              label: strings.apple,
                              imageAsset: 'assets/apple.png',
                              placeholderIcon: Icons.eco,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _cropCard(
                              category: 'Grapes',
                              label: strings.grapes,
                              imageAsset: 'assets/grape.png',
                              placeholderIcon: Icons.grass,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _cropCard(
                              category: 'Corn',
                              label: strings.corn,
                              imageAsset: 'assets/corn.png',
                              placeholderIcon: Icons.grain,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedCategory.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          '${strings.selectedCrop}: ${_localizedCrop(strings, _selectedCategory)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isProcessing
                                  ? null
                                  : () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: Text(strings.selectImage),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isProcessing
                                  ? null
                                  : () => _pickImage(ImageSource.camera),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.surfaceElevated,
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.border),
                              ),
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: Text(strings.openCamera),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isProcessing ? null : _runInference,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.surfaceElevated,
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Text(strings.getResults),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              canShowTreatment ? _showTreatmentDialog : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: canShowTreatment
                                ? AppColors.warning
                                : AppColors.surfaceElevated,
                            foregroundColor: canShowTreatment
                                ? const Color(0xFF1A1200)
                                : AppColors.textSecondary,
                            disabledBackgroundColor: AppColors.surfaceElevated,
                            disabledForegroundColor: AppColors.textSecondary,
                          ),
                          child: Text(
                            canShowTreatment
                                ? strings.getTreatment
                                : strings.runDetectionFirst,
                          ),
                        ),
                      ),
                      if (canShowTreatment && _output!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.results,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${strings.disease}: ${_output!.first['label']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${strings.confidence}: ${((_output!.first['confidence'] as num) * 100).toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
