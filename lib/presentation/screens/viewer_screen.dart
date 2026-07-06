import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme.dart';
import '../providers/connectivity_providers.dart';
import '../providers/hmi_profile_providers.dart';
import '../providers/settings_providers.dart';
import '../widgets/connection_status_banner.dart';
import '../widgets/error_overlay.dart';
import '../widgets/floating_controls.dart';

/// Full-screen WebView viewer for the HMI control panel.
class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({super.key});

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen>
    with WidgetsBindingObserver {
  InAppWebViewController? _webController;
  bool _isLoading = true;
  String? _loadError;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applySettings();
    WakelockPlus.enable();

    // Start connection monitoring.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(activeProfileProvider);
      if (profile != null) {
        ref
            .read(viewerConnectionProvider.notifier)
            .startMonitoring(profile.ipAddress, profile.port);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    // Restore system UI.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _applySettings() {
    final settings = ref.read(appSettingsProvider);

    // Kiosk mode.
    if (settings.kioskMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    // Orientation lock.
    switch (settings.orientationLock) {
      case 'portrait':
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        break;
      case 'landscape':
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        break;
      default:
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
  }

  void _reload() {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    _webController?.reload();
  }

  void _goToSettings() async {
    await Navigator.of(context).pushNamed('/settings');
    // Re-apply settings on return.
    if (mounted) {
      _applySettings();
      // Reload if profile changed.
      final profile = ref.read(activeProfileProvider);
      if (profile != null) {
        _webController?.loadUrl(
          urlRequest: URLRequest(url: WebUri(profile.fullUrl)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider);
    final connectionState = ref.watch(viewerConnectionProvider);
    final settings = ref.watch(appSettingsProvider);

    // Listen for reconnection → auto-reload WebView.
    ref.listen<ViewerConnectionState>(viewerConnectionProvider,
        (previous, next) {
      if (previous == ViewerConnectionState.reconnecting &&
          next == ViewerConnectionState.connected) {
        _reload();
      }
    });

    if (profile == null) {
      return Scaffold(
        body: ErrorOverlay(
          message: 'No active HMI profile selected.',
          onRetry: () => Navigator.of(context).pushReplacementNamed('/'),
          onSettings: _goToSettings,
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── WebView ──────────────────────────────────────────────────────
          if (_loadError == null)
            InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri(profile.fullUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                // Zoom controls.
                supportZoom: settings.pinchToZoom,
                builtInZoomControls: settings.pinchToZoom,
                displayZoomControls: false,
                // Disable text selection / context menu for kiosk feel.
                disableContextMenu: true,
                // Allow cleartext HTTP.
                allowsInlineMediaPlayback: true,
                // Disable default error pages — we handle errors ourselves.
                disableDefaultErrorPage: true,
                // Cache.
                cacheEnabled: true,
                clearCache: false,
                // Scrollbar.
                verticalScrollBarEnabled: false,
                horizontalScrollBarEnabled: false,
                // Overscroll.
                overScrollMode: OverScrollMode.NEVER,
              ),
              // Disable pull-to-refresh unless enabled in settings.
              pullToRefreshController: settings.pullToRefresh
                  ? PullToRefreshController(
                      settings: PullToRefreshSettings(
                        color: AppTheme.accent,
                      ),
                      onRefresh: () async {
                        _webController?.reload();
                      },
                    )
                  : null,
              onWebViewCreated: (controller) {
                _webController = controller;
              },
              onLoadStart: (controller, url) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                    _loadError = null;
                  });
                }
              },
              onLoadStop: (controller, url) {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              },
              onProgressChanged: (controller, progress) {
                if (mounted) {
                  setState(() => _progress = progress / 100);
                }
              },
              onReceivedError: (controller, request, error) {
                // Only handle main frame errors.
                if (request.isForMainFrame == true) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _loadError =
                          '${error.description} (${error.type})';
                    });
                  }
                }
              },
              onReceivedHttpError: (controller, request, response) {
                if (request.isForMainFrame == true &&
                    response.statusCode != null &&
                    response.statusCode! >= 500) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _loadError =
                          'Server error (HTTP ${response.statusCode})';
                    });
                  }
                }
              },
            ),

          // ── Error Overlay ────────────────────────────────────────────────
          if (_loadError != null)
            ErrorOverlay(
              message: _loadError!,
              onRetry: _reload,
              onSettings: _goToSettings,
            ),

          // ── Loading Progress Bar ─────────────────────────────────────────
          if (_isLoading && _loadError == null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: Colors.transparent,
                  color: AppTheme.accent,
                  minHeight: 3,
                ),
              ),
            ),

          // ── Connection Status Banner ──────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ConnectionStatusBanner(
              connectionState: connectionState,
              onRetry: () {
                ref.read(viewerConnectionProvider.notifier).manualRetry(
                      profile.ipAddress,
                      profile.port,
                    );
              },
            ),
          ),

          // ── Floating Controls ─────────────────────────────────────────────
          FloatingControls(
            onSettings: _goToSettings,
            onReload: _reload,
          ),
        ],
      ),
    );
  }
}
