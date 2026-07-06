import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../providers/connectivity_providers.dart';

/// Non-intrusive banner showing connection status during HMI viewing.
class ConnectionStatusBanner extends StatelessWidget {
  final ViewerConnectionState connectionState;
  final VoidCallback? onRetry;

  const ConnectionStatusBanner({
    super.key,
    required this.connectionState,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (connectionState == ViewerConnectionState.connected) {
      return const SizedBox.shrink();
    }

    final isReconnecting =
        connectionState == ViewerConnectionState.reconnecting;

    return AnimatedSlide(
      offset: connectionState == ViewerConnectionState.connected
          ? const Offset(0, -1)
          : Offset.zero,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Material(
        elevation: 4,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isReconnecting
                  ? [
                      AppTheme.warning.withValues(alpha: 0.9),
                      AppTheme.warning.withValues(alpha: 0.7),
                    ]
                  : [
                      AppTheme.error.withValues(alpha: 0.9),
                      AppTheme.error.withValues(alpha: 0.7),
                    ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                if (isReconnecting)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(Icons.wifi_off, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isReconnecting
                        ? 'Reconnecting to HMI...'
                        : 'Connection lost',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onRetry != null && !isReconnecting)
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
