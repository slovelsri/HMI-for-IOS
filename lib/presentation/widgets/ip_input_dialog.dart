import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/ip_validator.dart';

/// Modal bottom sheet dialog for adding or editing an HMI profile.
class IpInputDialog extends StatefulWidget {
  final String? existingName;
  final String? existingIp;
  final int? existingPort;
  final Future<bool> Function(String ip, int port)? onTestConnection;

  const IpInputDialog({
    super.key,
    this.existingName,
    this.existingIp,
    this.existingPort,
    this.onTestConnection,
  });

  /// Shows the dialog and returns (name, ip, port) if saved, or null if cancelled.
  static Future<({String name, String ip, int port})?> show(
    BuildContext context, {
    String? existingName,
    String? existingIp,
    int? existingPort,
    Future<bool> Function(String ip, int port)? onTestConnection,
  }) {
    return showModalBottomSheet<({String name, String ip, int port})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IpInputDialog(
        existingName: existingName,
        existingIp: existingIp,
        existingPort: existingPort,
        onTestConnection: onTestConnection,
      ),
    );
  }

  @override
  State<IpInputDialog> createState() => _IpInputDialogState();
}

class _IpInputDialogState extends State<IpInputDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  final _formKey = GlobalKey<FormState>();

  bool _testing = false;
  bool? _testResult;

  bool get _isEditing => widget.existingName != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingName ?? '');
    _ipController = TextEditingController(text: widget.existingIp ?? '');
    _portController = TextEditingController(
      text: (widget.existingPort ?? AppConstants.defaultPort).toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.onTestConnection == null) return;

    setState(() {
      _testing = true;
      _testResult = null;
    });

    final port = int.tryParse(_portController.text.trim()) ??
        AppConstants.defaultPort;
    final result = await widget.onTestConnection!(
      _ipController.text.trim(),
      port,
    );

    if (mounted) {
      setState(() {
        _testing = false;
        _testResult = result;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ??
        AppConstants.defaultPort;

    Navigator.of(context).pop((name: name, ip: ip, port: port));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle.
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isEditing ? 'Edit HMI Profile' : 'Add HMI Profile',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              // Name field.
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Profile Name',
                  hintText: 'e.g. Workshop HMI, Main Panel',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              // IP field.
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'IP Address',
                  hintText: 'e.g. 192.168.1.50',
                  prefixIcon: Icon(Icons.lan_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: IpValidator.validateIp,
              ),
              const SizedBox(height: 16),
              // Port field.
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  hintText: '80',
                  prefixIcon: Icon(Icons.numbers_rounded),
                ),
                keyboardType: TextInputType.number,
                validator: IpValidator.validatePort,
              ),
              const SizedBox(height: 20),
              // Test connection result.
              if (_testResult != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(
                        _testResult!
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        color: _testResult! ? AppTheme.accent : AppTheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _testResult!
                            ? 'Connection successful!'
                            : 'Could not reach device',
                        style: TextStyle(
                          color:
                              _testResult! ? AppTheme.accent : AppTheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              // Actions.
              Row(
                children: [
                  // Test button.
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _testing ? null : _testConnection,
                      icon: _testing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cable_rounded),
                      label: Text(_testing ? 'Testing...' : 'Test'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save button.
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(_isEditing ? 'Update' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
