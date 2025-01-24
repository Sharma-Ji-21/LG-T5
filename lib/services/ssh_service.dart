import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SSHService extends ChangeNotifier {
  SSHClient? _client;
  bool _isConnected = false;
  double? _uploadProgress;

  bool get isConnected => _isConnected;
  double? get uploadProgress => _uploadProgress;

  Future<void> connect({
    required String host,
    required String username,
    required String password,
    int port = 22,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('host', host);
      await prefs.setString('username', username);
      await prefs.setInt('port', port);
      await prefs.setString('password', password);

      final socket = await SSHSocket.connect(host, port);
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );

      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _client?.close();
    _client = null;
    _isConnected = false;
    notifyListeners();
  }

  Future<void> executeCommand(String command) async {
    if (_client == null) throw Exception('Not connected');
    final session = await _client!.execute(command);
    await session.done;
  }

  Future<void> cleanKML() async {
    if (!_isConnected) throw Exception('Not connected');
    try {
      await executeCommand('echo "" > /tmp/query.txt');
      await executeCommand("echo '' > /var/www/html/kmls.txt");
    } catch (error) {
      print("Error during cleanKML: $error");
      rethrow;
    }
  }

  Future<void> uploadKMLFile(File kmlFile, String kmlName) async {
    if (!_isConnected) throw Exception('Not connected');
    try {
      final sftp = await _client?.sftp();
      if (sftp == null) throw Exception("Failed to initialize SFTP client.");

      final remoteFile = await sftp.open(
        '/var/www/html/$kmlName.kml',
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.truncate |
            SftpFileOpenMode.write,
      );

      final fileSize = await kmlFile.length();
      await remoteFile.write(
        kmlFile.openRead().cast(),
        onProgress: (progress) {
          _uploadProgress = progress / fileSize;
          notifyListeners();
        },
      );

      _uploadProgress = null;
      notifyListeners();
    } catch (error) {
      _uploadProgress = null;
      notifyListeners();
      print("Error during kmlFileUpload: $error");
      rethrow;
    }
  }

  Future<void> runKML(String kmlName) async {
    if (!_isConnected) throw Exception('Not connected');
    try {
      await executeCommand(
        "echo '\nhttp://lg1:81/$kmlName.kml' > /var/www/html/kmls.txt",
      );
    } catch (error) {
      print("Error during runKml: $error");
      rethrow;
    }
  }

  Future<void> flyTo(String latitude, String longitude) async {
    if (!_isConnected) throw Exception('Not connected');
    try {
      await executeCommand(
          "echo 'search=$latitude,$longitude' > /tmp/query.txt");
    } catch (error) {
      print("Error in flyTo: $error");
      rethrow;
    }
  }

  Future<void> relaunchLG(String username, String password,
      {int numberOfRigs = 3}) async {
    if (!_isConnected) throw Exception('Not connected');
    try {
      for (var i = 1; i <= numberOfRigs; i++) {
        String relaunchCmd = """RELAUNCH_CMD="\\
          if [ -f /etc/init/lxdm.conf ]; then
            export SERVICE=lxdm
          elif [ -f /etc/init/lightdm.conf ]; then
            export SERVICE=lightdm
          else
            exit 1
          fi
          if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
            echo $password | sudo -S service \\\${SERVICE} start
          else
            echo $password | sudo -S service \\\${SERVICE} restart
          fi
          " && sshpass -p $password ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";

        await executeCommand(
            '"/home/$username/bin/lg-relaunch" > /home/$username/log.txt');
        await executeCommand(relaunchCmd);
      }
    } catch (error) {
      print("Error during relaunchLG: $error");
      rethrow;
    }
  }
}
