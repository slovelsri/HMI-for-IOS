import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmi_viewer/domain/repositories/connectivity_repository.dart';

import '../../core/theme.dart';
import '../providers/connectivity_providers.dart';
import '../providers/hmi_profile_providers.dart';

/// Splash/connection screen — shown on app launch.
/// Checks for an active profile, WiFi, and HMI reachability.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  _SplashState _state = _SplashState.checking;
  String _statusMessage = 'Initializing...';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    // Delay slightly to let Riverpod providers initialize.
    Future.delayed(const Duration(milliseconds: 500), _runChecks);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _runChecks() async {
    if (!mounted) return;

    // Step 1: Check for active profile.
    setState(() {
      _state = _SplashState.checking;
      _statusMessage = 'Loading profile...';
    });

    final profile = ref.read(activeProfileProvider);
    if (profile == null) {
      // No profile configured — send to settings.
      setState(() {
        _state = _SplashState.noProfile;
        _statusMessage = 'No HMI profile configured';
      });
      return;
    }

    // Step 2: Check WiFi connectivity.
    setState(() => _statusMessage = 'Checking WiFi...');
    final connectivity =
        await ref.read(connectivityRepositoryProvider).getCurrentConnectivity();
    if (connectivity == ConnectivityStatus.disconnected) {
      setState(() {
        _state = _SplashState.error;
        _statusMessage = 'No WiFi connection detected';
      });
      return;
    }

    // Step 3: Check HMI reachability.
    setState(() => _statusMessage = 'Connecting to ${profile.name}...');
    final reachable = await ref
        .read(connectivityRepositoryProvider)
        .checkReachability(profile.ipAddress, profile.port);

    if (!mounted) return;

    if (reachable) {
      setState(() {
        _state = _SplashState.connected;
        _statusMessage = 'Connected!';
      });
      // Brief pause to show success, then navigate.
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/viewer');
      }
    } else {
      setState(() {
        _state = _SplashState.error;
        _statusMessage =
            'Could not reach ${profile.name} at ${profile.displayAddress}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.background,
              AppTheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App icon with pulse animation.
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.accent.withValues(
                                  alpha: 0.15 + (_pulseController.value * 0.1)),
                              Colors.transparent,
                            ],
                            radius: 1.0 + (_pulseController.value * 0.3),
                          ),
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.card,
                        border: Border.all(
                          color: _state == _SplashState.error
                              ? AppTheme.error
                              : _state == _SplashState.connected
                                  ? AppTheme.accent
                                  : AppTheme.divider,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _state == _SplashState.error
                            ? Icons.wifi_off_rounded
                            : _state == _SplashState.connected
                                ? Icons.check_rounded
                                : Icons.developer_board_rounded,
                        size: 36,
                        color: _state == _SplashState.error
                            ? AppTheme.error
                            : AppTheme.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App title.
                  Text(
                    'HMI Viewer',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'V-Box Control Panel',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),
                  // Status message.
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _state == _SplashState.error
                              ? AppTheme.error
                              : null,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // Loading indicator or action buttons.
                  if (_state == _SplashState.checking) ...[
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppTheme.accent,
                      ),
                    ),
                  ] else if (_state == _SplashState.error) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        onPressed: _runChecks,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 220,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/settings'),
                        icon: const Icon(Icons.settings_rounded),
                        label: const Text('Settings'),
                      ),
                    ),
                  ] else if (_state == _SplashState.noProfile) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).pushNamed('/settings');
                          // Re-check after returning from settings.
                          if (mounted) _runChecks();
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add HMI Profile'),
                      ),
                    ),
                  ] else if (_state == _SplashState.connected) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.accent,
                      size: 32,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _SplashState {
  checking,
  connected,
  error,
  noProfile,
}
