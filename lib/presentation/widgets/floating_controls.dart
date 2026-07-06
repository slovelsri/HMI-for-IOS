import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';

/// Auto-hiding floating controls for the viewer screen.
/// Appears on tap, fades out after a few seconds.
class FloatingControls extends StatefulWidget {
  final VoidCallback onSettings;
  final VoidCallback onReload;

  const FloatingControls({
    super.key,
    required this.onSettings,
    required this.onReload,
  });

  @override
  State<FloatingControls> createState() => _FloatingControlsState();
}

class _FloatingControlsState extends State<FloatingControls>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  Timer? _hideTimer;

  void _show() {
    setState(() => _visible = true);
    _hideTimer?.cancel();
    _hideTimer = Timer(AppConstants.floatingControlsAutoHide, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  void _toggle() {
    if (_visible) {
      _hideTimer?.cancel();
      setState(() => _visible = false);
    } else {
      _show();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Action buttons (slide in/out).
          AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0.5, 0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: IgnorePointer(
                ignoring: !_visible,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MiniButton(
                      icon: Icons.settings_rounded,
                      tooltip: 'Settings',
                      onPressed: widget.onSettings,
                    ),
                    const SizedBox(height: 8),
                    _MiniButton(
                      icon: Icons.refresh_rounded,
                      tooltip: 'Reload',
                      onPressed: widget.onReload,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Toggle button (always visible, subtle).
          GestureDetector(
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: AppConstants.floatingButtonSize,
              height: AppConstants.floatingButtonSize,
              decoration: BoxDecoration(
                color: _visible
                    ? AppTheme.accent.withValues(alpha: 0.9)
                    : AppTheme.card.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _visible ? Icons.close_rounded : Icons.menu_rounded,
                size: 20,
                color: _visible ? AppTheme.background : AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _MiniButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppTheme.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: AppConstants.floatingButtonSize,
            height: AppConstants.floatingButtonSize,
            child: Icon(icon, size: 20, color: AppTheme.accent),
          ),
        ),
      ),
    );
  }
}
