import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ssh_service.dart';

class SettingsScreen extends StatelessWidget {
  final double textScaleFactor;
  final ValueChanged<double> onTextScaleFactorChanged;

  const SettingsScreen({
    super.key,
    required this.textScaleFactor,
    required this.onTextScaleFactorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20 * textScaleFactor,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Display Settings', Icons.display_settings),
              const SizedBox(height: 16),
              _buildSettingsCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.text_fields, color: Colors.black),
                        const SizedBox(width: 12),
                        Text(
                          'Text Size',
                          style: TextStyle(
                            fontSize: 16 * textScaleFactor,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: textScaleFactor,
                      min: 0.8,
                      max: 1.4,
                      divisions: 3,
                      activeColor: Colors.black,
                      inactiveColor: Colors.grey[300],
                      label: '${textScaleFactor.toStringAsFixed(1)}x',
                      onChanged: onTextScaleFactorChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Connection Status', Icons.wifi),
              const SizedBox(height: 16),
              Consumer<SSHService>(
                builder: (context, sshService, child) {
                  return _buildSettingsCard(
                    context,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: sshService.isConnected ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            sshService.isConnected ? Icons.check_circle : Icons.error,
                            color: sshService.isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SSH Connection',
                              style: TextStyle(
                                fontSize: 16 * textScaleFactor,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              sshService.isConnected ? 'Connected' : 'Disconnected',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14 * textScaleFactor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('About', Icons.info),
              const SizedBox(height: 16),
              _buildSettingsCard(
                context,
                onTap: () => _showAboutDialog(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.info_outline, color: Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'App Information',
                          style: TextStyle(
                            fontSize: 16 * textScaleFactor,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18 * textScaleFactor,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
      BuildContext context, {
        required Widget child,
        VoidCallback? onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAboutRow(Icons.info_outline, 'Version: 1.0.0'),
            const SizedBox(height: 12),
            _buildAboutRow(Icons.person_outline, 'Made by Sharma-Ji'),
            const SizedBox(height: 12),
            _buildAboutRow(Icons.copyright, '© Om [Do Not Copy]'),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}