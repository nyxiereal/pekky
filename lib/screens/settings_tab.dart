import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/peka_auth_service.dart';
import '../services/theme_service.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key, required this.themeService});

  final ThemeService themeService;

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _authService = PekaAuthService();
  bool _checkingUpdate = false;
  // ignore: unused_field
  String? _latestVersion;
  String? _updateMessage;

  static const String _currentVersion = '1.0.0';

  Future<void> _checkForUpdates() async {
    setState(() {
      _checkingUpdate = true;
      _updateMessage = null;
    });

    try {
      final url = Uri.parse(
        'https://api.github.com/repos/nyxiereal/pekky/releases/latest',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tagName = data['tag_name'] as String;
        setState(() {
          _latestVersion = tagName;
          if (tagName != _currentVersion) {
            _updateMessage = 'Update available: $tagName';
          } else {
            _updateMessage = 'You\'re on the latest version';
          }
        });
      } else {
        setState(() {
          _updateMessage = 'Failed to check for updates';
        });
      }
    } catch (e) {
      setState(() {
        _updateMessage = 'Error checking updates: ${e.toString()}';
      });
    } finally {
      setState(() {
        _checkingUpdate = false;
      });
    }
  }

  Future<void> _openGitHubRepo() async {
    final url = Uri.parse(
      'https://github.com/nyxiereal/pekky/releases/latest/download/app-prod-release.apk',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              subtitle: const Text('Always use light theme'),
              value: ThemeMode.light,
              groupValue: widget.themeService.themeMode,
              onChanged: (value) {
                if (value != null) {
                  widget.themeService.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              subtitle: const Text('Always use dark theme'),
              value: ThemeMode.dark,
              groupValue: widget.themeService.themeMode,
              onChanged: (value) {
                if (value != null) {
                  widget.themeService.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              subtitle: const Text('Follow system settings'),
              value: ThemeMode.system,
              groupValue: widget.themeService.themeMode,
              onChanged: (value) {
                if (value != null) {
                  widget.themeService.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Appearance Section
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  widget.themeService.getThemeModeIcon(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Theme'),
                subtitle: Text(widget.themeService.getThemeModeLabel()),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showThemeDialog,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Updates Section
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.system_update,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Check for Updates'),
                subtitle: _updateMessage != null
                    ? Text(_updateMessage!)
                    : Text('Current version: v$_currentVersion'),
                trailing: _checkingUpdate
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _checkingUpdate ? null : _checkForUpdates,
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.code,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('View on GitHub'),
                subtitle: Text('nyxiereal/pekky'),
                trailing: const Icon(Icons.open_in_new),
                onTap: _openGitHubRepo,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Account Section
        Card(
          child: ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Sign Out',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _handleLogout,
          ),
        ),
        const SizedBox(height: 32),

        // App Info
        Center(
          child: Column(
            children: [
              Text(
                'pekky',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version $_currentVersion',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
