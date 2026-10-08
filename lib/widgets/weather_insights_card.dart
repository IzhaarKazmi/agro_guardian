import 'package:agro_guardian/l10n/app_strings.dart';
import 'package:agro_guardian/services/weather_models.dart';
import 'package:agro_guardian/services/weather_service.dart';
import 'package:agro_guardian/theme/app_theme.dart';
import 'package:flutter/material.dart';

class WeatherInsightsCard extends StatefulWidget {
  const WeatherInsightsCard({super.key});

  @override
  State<WeatherInsightsCard> createState() => _WeatherInsightsCardState();
}

class _WeatherInsightsCardState extends State<WeatherInsightsCard> {
  final WeatherService _weatherService = WeatherService();

  bool _loading = false;
  String? _error;
  WeatherSnapshot? _weather;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeather();
    });
  }

  Future<void> _loadWeather() async {
    if (_loading) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final weather = await _weatherService.fetchCurrentWeather();
      if (!mounted) {
        return;
      }
      setState(() {
        _weather = weather;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      final strings = AppStrings.of(context);
      final message = e.toString();
      String errorText = strings.weatherFailed;
      if (message.contains('location_disabled')) {
        errorText = strings.weatherLocationDisabled;
      } else if (message.contains('location_denied')) {
        errorText = strings.weatherLocationDenied;
      }

      setState(() {
        _loading = false;
        _error = errorText;
        _weather = null;
      });
    }
  }

  String _riskLabel(AppStrings strings, DiseaseRiskLevel level) {
    switch (level) {
      case DiseaseRiskLevel.low:
        return strings.weatherRiskLow;
      case DiseaseRiskLevel.moderate:
        return strings.weatherRiskModerate;
      case DiseaseRiskLevel.high:
        return strings.weatherRiskHigh;
    }
  }

  Color _riskColor(DiseaseRiskLevel level) {
    switch (level) {
      case DiseaseRiskLevel.low:
        return AppColors.primary;
      case DiseaseRiskLevel.moderate:
        return AppColors.warning;
      case DiseaseRiskLevel.high:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final weather = _weather;
    final advice =
        weather == null ? null : strings.weatherAdviceFor(weather);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.weatherTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                tooltip: strings.weatherRefresh,
                onPressed: _loading ? null : _loadWeather,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (_loading) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  strings.weatherLoading,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ] else if (_error != null) ...[
            Text(
              _error!,
              style: const TextStyle(color: AppColors.danger, height: 1.35),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _loadWeather,
              child: Text(strings.weatherLoadCta),
            ),
          ] else if (weather != null && advice != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  label:
                      '${strings.weatherTemp}: ${weather.temperatureC.toStringAsFixed(1)}°C',
                ),
                _MetricChip(
                  label:
                      '${strings.weatherHumidity}: ${weather.humidity.toStringAsFixed(0)}%',
                ),
                _MetricChip(
                  label:
                      '${strings.weatherRain}: ${weather.precipitationMm.toStringAsFixed(1)} mm',
                ),
                _MetricChip(
                  label:
                      '${strings.weatherRisk}: ${_riskLabel(strings, advice.riskLevel)}',
                  color: _riskColor(advice.riskLevel),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              advice.summary,
              style: const TextStyle(
                color: AppColors.textPrimary,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strings.weatherCommonDiseases,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ...advice.commonDiseases.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.primary)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              strings.weatherRecommendations,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ...advice.recommendations.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.warning)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.weatherPoweredBy,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
