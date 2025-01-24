import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../Ui/geminiUi.dart';
import '../services/ssh_service.dart';
import 'chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleKMLUpload(
      BuildContext context, SSHService sshService, String kmlFileName) async {
    if (!sshService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please connect to SSH first')));
      return;
    }

    try {
      final String kmlContent =
          await rootBundle.loadString('assets/$kmlFileName.kml');
      final directory = await getTemporaryDirectory();
      final File tempFile = File('${directory.path}/$kmlFileName.kml');
      await tempFile.writeAsString(kmlContent);

      await sshService.uploadKMLFile(tempFile, kmlFileName);
      await sshService.runKML(kmlFileName);
      await tempFile.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('KML uploaded and executed successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to process KML: $e')));
      }
    }
  }

  Future<void> _handleRelaunch(
      BuildContext context, SSHService sshService) async {
    if (!sshService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please connect to SSH first')));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final password = prefs.getString('password');
      if (username == null || password == null)
        throw Exception('Username or password not found');

      await sshService.relaunchLG(username, password);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Relaunch command executed successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to relaunch: $e')));
      }
    }
  }

  Future<void> _handleCleanKML(
      BuildContext context, SSHService sshService) async {
    if (!sshService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please connect to SSH first')));
      return;
    }

    try {
      await sshService.cleanKML();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('KML cleaned successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to clean KML: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SSHService>(
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
                      physics: const PageScrollPhysics(),
                      children: [
                        Center(
                          child: DiwaliPartyButton(
                              onPressed: () => _handleKMLUpload(
                                  context, sshService, 'kml1')),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: sshService.isConnected
                                ? () => _handleKMLUpload(
                                    context, sshService, 'kml2')
                                : null,
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(350, 200)),
                            child: const Text("Run KML 2",
                                style: TextStyle(fontSize: 28)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: sshService.isConnected
                                  ? Colors.green[600]
                                  : Colors.red[600],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              sshService.isConnected
                                  ? 'Connected'
                                  : 'Disconnected',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, 0.5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CleanKMLButton(
                                  onPressed: () =>
                                      _handleCleanKML(context, sshService)),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: sshService.isConnected
                                    ? () => _handleRelaunch(context, sshService)
                                    : null,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Relaunch LG'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ChatScreen()));
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const SizedBox(width: 56, height: 56, child: GeminiUi()),
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
