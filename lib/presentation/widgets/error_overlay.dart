import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Full-screen error overlay with retry and settings navigation.
class ErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onSettings;

  const ErrorOverlay({
    super.key,
    required this.message,
    required this.onRetry,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated WiFi-off icon with a pulsing ring.
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.error.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppTheme.error.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 48,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Unable to Connect',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Make sure your device is connected to\nthe same WiFi as the HMI.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ),
              if (onSettings != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: 220,
                  child: OutlinedButton.icon(
                    onPressed: onSettings,
                    icon: const Icon(Icons.settings_rounded),
                    label: const Text('Settings'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
