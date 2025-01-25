import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final double textScaleFactor;
  final ValueChanged<double> onTextScaleFactorChanged;

  const SettingsScreen({
    Key? key,
    required this.textScaleFactor,
    required this.onTextScaleFactorChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bgImg3.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.text_fields, color: Colors.white),
              title: Text('Text Size', style: TextStyle(color: Colors.white)),
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
            Divider(color: Colors.white54),
            ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text('About', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
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
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}