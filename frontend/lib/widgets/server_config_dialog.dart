import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../config/app_theme.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ApiConfig.baseUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      await ApiConfig.setCustomBaseUrl(text);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server endpoint updated to: $text'),
            backgroundColor: AppTheme.sageAccent,
          ),
        );
      }
    }
  }

  void _reset() async {
    await ApiConfig.resetToDefault();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset to default endpoint: ${ApiConfig.baseUrl}'),
          backgroundColor: AppTheme.primaryOchre,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.cloud_outlined, color: AppTheme.primaryTerracotta),
          SizedBox(width: 8),
          Text('Server Host Config', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connect this mobile app to a deployed Cloud URL or LAN host (not localhost):',
            style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'API Base URL',
              hintText: 'https://your-cloud-api.com/api/v1',
              prefixIcon: Icon(Icons.link, size: 20),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Examples:\n• Cloud: https://api.artisanconnect.org/api/v1\n• Wi-Fi LAN: http://192.168.55.103:8000/api/v1',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.35),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _reset,
          child: const Text('Reset', style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save & Connect'),
        ),
      ],
    );
  }
}
