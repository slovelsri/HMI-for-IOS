import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../domain/entities/hmi_profile.dart';

/// Card widget displaying an HMI profile with actions.
class ProfileCard extends StatelessWidget {
  final HmiProfile profile;
  final bool isActive;
  final bool? isReachable; // null = not tested yet
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTestConnection;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.isActive,
    this.isReachable,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onTestConnection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? AppTheme.accent : AppTheme.divider,
          width: isActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status dot.
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.accent.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name.
                  Expanded(
                    child: Text(
                      profile.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // IP Address.
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: Row(
                  children: [
                    const Icon(Icons.lan_rounded, size: 16,
                        color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      profile.displayAddress,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Actions row.
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ActionChip(
                    icon: Icons.cable_rounded,
                    label: 'Test',
                    onPressed: onTestConnection,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    onPressed: onEdit,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    onPressed: onDelete,
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _statusColor {
    if (isReachable == null) return AppTheme.textSecondary;
    return isReachable! ? AppTheme.accent : AppTheme.error;
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppTheme.error : AppTheme.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
