import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../Ui/geminiUi.dart';
import '../services/ssh_service.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bgImg5.jpg', fit: BoxFit.cover),
          Consumer<SSHService>(
            builder: (context, sshService, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  double upperHalfHeight = constraints.maxHeight / 2;
                  return Column(
                    children: [
                      SizedBox(
                        height: upperHalfHeight,
                        child: PageView(
                          scrollDirection: Axis.horizontal,
                          physics: PageScrollPhysics(),
                          children: [
                            Center(child: DiwaliPartyButton(onPressed: () => _handleKMLUpload(context, sshService, 'kml1'))),
                            Center(child: World3DButton(onPressed: () => _handleKMLUpload(context, sshService, 'kml2'))),
                          ],
                        ),
                      ),
                      _buildConnectionStatus(sshService),
                      _buildActionButtons(context, sshService),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen())),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GeminiUi(),
      ),
    );
  }

  Widget _buildConnectionStatus(SSHService sshService) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 19, horizontal: 34),
        decoration: BoxDecoration(
          color: sshService.isConnected ? Colors.green[600] : Colors.red[600],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 6)],
        ),
        child: Text(
          sshService.isConnected ? 'Connected' : 'Disconnected',
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, SSHService sshService) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CleanKMLButton(onPressed: () => _handleCleanKML(context, sshService)),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: sshService.isConnected ? () => _handleRelaunch(context, sshService) : null,
              icon: Icon(Icons.refresh, color: Colors.blue),
              label: Text('Relaunch LG', style: TextStyle(color: Colors.blue)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                splashFactory: InkRipple.splashFactory,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DiwaliPartyButton extends StatefulWidget {
  final VoidCallback onPressed;

  const DiwaliPartyButton({required this.onPressed, super.key});

  @override
  State<DiwaliPartyButton> createState() => _DiwaliPartyButtonState();
}

class _DiwaliPartyButtonState extends State<DiwaliPartyButton> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 80),
                elevation: 15,
                shadowColor: Colors.deepOrange,
              ),
              onPressed: () {
                _confettiController.play();
                widget.onPressed();
              },
              child: const Text('🎊 Diwali Party 🎊',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue
              ],
              numberOfParticles: 20,
              gravity: 0.2,
            ),
          ],
        ),
      ],
    );
  }
}

class CleanKMLButton extends StatefulWidget {
  final VoidCallback onPressed;

  const CleanKMLButton({required this.onPressed, super.key});

  @override
  State<CleanKMLButton> createState() => _CleanKMLButtonState();
}

class _CleanKMLButtonState extends State<CleanKMLButton> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                elevation: 15,
                shadowColor: Colors.blueGrey,
              ),
              onPressed: () {
                _confettiController.play();
                widget.onPressed();
              },
              child: const Text('🧹✨ Clean KML ✨🧼',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                Colors.lightBlue,
                Colors.white,
                Colors.tealAccent,
                Colors.cyan
              ],
              numberOfParticles: 25,
              gravity: 0.2,
            ),
          ],
        ),
      ],
    );
  }
}
class World3DButton extends StatefulWidget {
  final VoidCallback onPressed;

  const World3DButton({required this.onPressed, super.key});

  @override
  State<World3DButton> createState() => _World3DButtonState();
}

class _World3DButtonState extends State<World3DButton> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding:
                const EdgeInsets.symmetric(vertical: 40, horizontal: 80),
                elevation: 15,
                shadowColor: Colors.purpleAccent,
              ),
              onPressed: () {
                _confettiController.play();
                widget.onPressed();
              },
              child: const Text('🌟 3D World 🌐',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.yellow,
                Colors.indigoAccent
              ],
              numberOfParticles: 20,
              gravity: 0.2,
            ),
          ],
        ),
      ],
    );
  }
}