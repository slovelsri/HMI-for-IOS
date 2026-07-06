import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../domain/entities/hmi_profile.dart';
import '../providers/connectivity_providers.dart';
import '../providers/hmi_profile_providers.dart';
import '../providers/settings_providers.dart';
import '../widgets/ip_input_dialog.dart';
import '../widgets/profile_card.dart';

/// Settings screen: profile management + app configuration.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final Map<String, bool?> _reachabilityCache = {};

  Future<bool> _testConnection(String ip, int port) async {
    final repo = ref.read(connectivityRepositoryProvider);
    return repo.checkReachability(ip, port);
  }

  Future<void> _testProfileConnection(HmiProfile profile) async {
    setState(() => _reachabilityCache[profile.id] = null);
    final result = await _testConnection(profile.ipAddress, profile.port);
    if (mounted) {
      setState(() => _reachabilityCache[profile.id] = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? '✓ ${profile.name} is reachable'
                : '✗ Cannot reach ${profile.name}',
          ),
          backgroundColor: result ? AppTheme.accent : AppTheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addProfile() async {
    final result = await IpInputDialog.show(
      context,
      onTestConnection: _testConnection,
    );
    if (result != null) {
      ref.read(hmiProfilesProvider.notifier).addProfile(
            name: result.name,
            ipAddress: result.ip,
            port: result.port,
          );
    }
  }

  Future<void> _editProfile(HmiProfile profile) async {
    final result = await IpInputDialog.show(
      context,
      existingName: profile.name,
      existingIp: profile.ipAddress,
      existingPort: profile.port,
      onTestConnection: _testConnection,
    );
    if (result != null) {
      ref.read(hmiProfilesProvider.notifier).updateProfile(
            profile.copyWith(
              name: result.name,
              ipAddress: result.ip,
              port: result.port,
            ),
          );
    }
  }

  Future<void> _deleteProfile(HmiProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Remove "${profile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(hmiProfilesProvider.notifier).deleteProfile(profile.id);
      _reachabilityCache.remove(profile.id);
    }
  }

  void _setActive(HmiProfile profile) {
    ref.read(activeProfileIdProvider.notifier).setActive(profile.id);
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(hmiProfilesProvider);
    final activeId = ref.watch(activeProfileIdProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── HMI Profiles Section ────────────────────────────────────────
          _SectionHeader(
            title: 'HMI Profiles',
            action: IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: AppTheme.accent),
              onPressed: _addProfile,
              tooltip: 'Add Profile',
            ),
          ),
          if (profiles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.developer_board_off_rounded,
                    size: 56,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No HMI profiles yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first HMI device',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _addProfile,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Profile'),
                  ),
                ],
              ),
            )
          else
            ...profiles.map((profile) {
              return ProfileCard(
                profile: profile,
                isActive: profile.id == activeId,
                isReachable: _reachabilityCache[profile.id],
                onTap: () => _setActive(profile),
                onEdit: () => _editProfile(profile),
                onDelete: () => _deleteProfile(profile),
                onTestConnection: () => _testProfileConnection(profile),
              );
            }),

          const Divider(height: 40, indent: 16, endIndent: 16),

          // ── App Settings Section ────────────────────────────────────────
          const _SectionHeader(title: 'Display'),
          _SettingsTile(
            icon: Icons.fullscreen_rounded,
            title: 'Kiosk Mode',
            subtitle: 'Hide system status & navigation bars',
            trailing: Switch(
              value: settings.kioskMode,
              onChanged: (v) =>
                  ref.read(appSettingsProvider.notifier).setKioskMode(v),
            ),
          ),
          _SettingsTile(
            icon: Icons.zoom_in_rounded,
            title: 'Pinch to Zoom',
            subtitle: 'Allow zoom gestures on the HMI view',
            trailing: Switch(
              value: settings.pinchToZoom,
              onChanged: (v) =>
                  ref.read(appSettingsProvider.notifier).setPinchToZoom(v),
            ),
          ),
          _SettingsTile(
            icon: Icons.screen_rotation_rounded,
            title: 'Orientation',
            subtitle: _orientationLabel(settings.orientationLock),
            trailing: DropdownButton<String>(
              value: settings.orientationLock,
              underline: const SizedBox.shrink(),
              dropdownColor: AppTheme.card,
              items: const [
                DropdownMenuItem(value: 'auto', child: Text('Auto')),
                DropdownMenuItem(value: 'portrait', child: Text('Portrait')),
                DropdownMenuItem(value: 'landscape', child: Text('Landscape')),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setOrientationLock(v);
                }
              },
            ),
          ),

          const Divider(height: 24, indent: 16, endIndent: 16),

          const _SectionHeader(title: 'Connection'),
          _SettingsTile(
            icon: Icons.autorenew_rounded,
            title: 'Auto-Reconnect',
            subtitle: 'Automatically retry when connection drops',
            trailing: Switch(
              value: settings.autoReconnect,
              onChanged: (v) =>
                  ref.read(appSettingsProvider.notifier).setAutoReconnect(v),
            ),
          ),
          _SettingsTile(
            icon: Icons.swipe_down_rounded,
            title: 'Pull to Refresh',
            subtitle: 'Swipe down to reload the HMI page',
            trailing: Switch(
              value: settings.pullToRefresh,
              onChanged: (v) =>
                  ref.read(appSettingsProvider.notifier).setPullToRefresh(v),
            ),
          ),

          const Divider(height: 24, indent: 16, endIndent: 16),

          // ── About Section ───────────────────────────────────────────────
          const _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'HMI Viewer',
            subtitle: 'Version 1.0.0 • V-Box Kiosk Viewer',
          ),
        ],
      ),
    );
  }

  String _orientationLabel(String value) {
    switch (value) {
      case 'portrait':
        return 'Locked to portrait';
      case 'landscape':
        return 'Locked to landscape';
      default:
        return 'Follow device orientation';
    }
  }
}

// ── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.accent,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ── Settings Tile ───────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppTheme.accent),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: trailing,
    );
  }
}
