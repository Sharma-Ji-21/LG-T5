import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final double textScaleFactor;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<double> onTextScaleFactorChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.textScaleFactor,
    required this.onThemeChanged,
    required this.onTextScaleFactorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            title: Text('Dark Mode'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: onThemeChanged,
              activeColor: Colors.blue,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.text_fields),
            title: Text('Text Size'),
            subtitle: Slider(
              value: textScaleFactor,
              min: 0.8,
              max: 1.6,
              divisions: 4,
              activeColor: Colors.blue,
              label: '${textScaleFactor.toStringAsFixed(1)}x',
              onChanged: onTextScaleFactorChanged,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('About'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Version: 1.0.0'),
                      SizedBox(height: 8),
                      Text('Made by Sharma-Ji'),
                      SizedBox(height: 8),
                      Text('© Om [Do Not Copy]'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
