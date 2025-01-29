import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../Ui/geminiUi.dart';
import '../services/ssh_service.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _kmlData = [
    {
      'name1': 'Diwali',
      'name2': 'Party',
      'image': 'assets/bgImg123.png',
      'kmlFile': 'kml1',
    },
    {
      'name1': '3D',
      'name2': 'World',
      'image': 'assets/bgImg69.png',
      'kmlFile': 'kml2',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleKMLUpload(BuildContext context, SSHService sshService, String kmlFileName) async {
    if (!sshService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please connect to SSH first')));
      return;
    }

    try {
      final String kmlContent = await rootBundle.loadString('assets/$kmlFileName.kml');
      final directory = await getTemporaryDirectory();
      final File tempFile = File('${directory.path}/$kmlFileName.kml');
      await tempFile.writeAsString(kmlContent);

      await sshService.uploadKMLFile(tempFile, kmlFileName);
      await sshService.runKML(kmlFileName);
      await tempFile.delete();
    } catch (e) {
      print('Error uploading KML');
    }
  }

  Future<void> _handleRelaunch(BuildContext context, SSHService sshService) async {
    if (!sshService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please connect to SSH first')));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final password = prefs.getString('password');
      if (username == null || password == null) {
        throw Exception('Credentials not found');
      }

      await sshService.relaunchLG(username, password);
    } catch (e) {
      print('Error relaunching');
    }
  }

  Future<void> _handleCleanKML(BuildContext context, SSHService sshService) async {
    if (!sshService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please connect to SSH first')));
      return;
    }

    try {
      await sshService.cleanKML();
    } catch (e) {
      print('Error cleaning KML');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<SSHService>(
        builder: (context, sshService, child) {
          return SafeArea(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            "${_kmlData[_currentPage]['name1']}\n",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${_kmlData[_currentPage]['name2']}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 35,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: _kmlData.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: ClipPath(
                              child: Image.asset(
                                _kmlData[index]['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            icon: Icons.refresh,
                            onPressed: () => _handleRelaunch(context, sshService),
                          ),
                          _buildControlButton(
                            icon: Icons.play_arrow,
                            onPressed: () => _handleKMLUpload(
                              context,
                              sshService,
                              _kmlData[_currentPage]['kmlFile'],
                            ),
                            isMain: true,
                          ),
                          _buildControlButton(
                            icon: Icons.cleaning_services,
                            onPressed: () => _handleCleanKML(context, sshService),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 27,
                  right: 16,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), // Added border radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatScreen()),
                        ),
                        child: const GeminiUi(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isMain = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isMain ? Colors.black : Colors.grey[500],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: isMain ? Colors.white : Colors.black,
        iconSize: isMain ? 90 : 40,
        padding: EdgeInsets.all(isMain ? 16 : 12),
      ),
    );
  }
}