import 'package:flutter/foundation.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SSHConnection {
  final SSHClient client;
  final String identifier;
  final String host;
  final int port;
  final String username;

  SSHConnection({
    required this.client,
    required this.identifier,
    required this.host,
    required this.port,
    required this.username,
  });
}

class MultiSSHService extends ChangeNotifier {
  final Map<String, SSHConnection> _connections = {};
  String? _activeConnectionId;
  double? _uploadProgress;

  bool get isConnected => _activeConnectionId != null;
  double? get uploadProgress => _uploadProgress;
  List<String> get activeConnections => _connections.keys.toList();
  String? get activeConnectionId => _activeConnectionId;

  Future<String> connect({
    required String host,
    required String username,
    required String password,
    String? connectionId,
    int port = 22,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('host', host);
      await prefs.setString('username', username);
      await prefs.setInt('port', port);
      await prefs.setString('password', password);

      final socket = await SSHSocket.connect(host, port);
      final client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );

      // Generate a unique connection ID if not provided
      final id = connectionId ?? '${username}@${host}:${port}_${DateTime.now().millisecondsSinceEpoch}';

      _connections[id] = SSHConnection(
        client: client,
        identifier: id,
        host: host,
        port: port,
        username: username,
      );

      _activeConnectionId = id;
      notifyListeners();
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> switchConnection(String connectionId) async {
    if (_connections.containsKey(connectionId)) {
      _activeConnectionId = connectionId;
      notifyListeners();
    } else {
      throw Exception('Connection not found');
    }
  }

  Future<void> disconnect(String? connectionId) async {
    final id = connectionId ?? _activeConnectionId;
    if (id != null) {
      final connection = _connections[id];
      if (connection != null) {
        connection.client.close();
        _connections.remove(id);

        // If we removed the active connection, set the next available one as active
        if (id == _activeConnectionId) {
          _activeConnectionId = _connections.isNotEmpty ? _connections.keys.first : null;
        }

        notifyListeners();
      }
    }
  }

  Future<void> disconnectAll() async {
    for (var connection in _connections.values) {
      connection.client.close();
    }
    _connections.clear();
    _activeConnectionId = null;
    notifyListeners();
  }

  SSHClient? get _activeClient => _activeConnectionId != null
      ? _connections[_activeConnectionId]?.client
      : null;

  Future<void> executeCommand(String command, {String? connectionId}) async {
    final client = connectionId != null
        ? _connections[connectionId]?.client
        : _activeClient;

    if (client == null) throw Exception('Not connected');
    final session = await client.execute(command);
    await session.done;
  }

  Future<void> cleanKML({String? connectionId}) async {
    if (!isConnected) throw Exception('Not connected');
    try {
      await executeCommand('echo "" > /tmp/query.txt', connectionId: connectionId);
      await executeCommand("echo '' > /var/www/html/kmls.txt", connectionId: connectionId);
    } catch (error) {
      print("Error during cleanKML: $error");
      rethrow;
    }
  }

  Future<void> uploadKMLFile(File kmlFile, String kmlName, {String? connectionId}) async {
    if (!isConnected) throw Exception('Not connected');
    try {
      final client = connectionId != null
          ? _connections[connectionId]?.client
          : _activeClient;

      if (client == null) throw Exception('Not connected');

      final sftp = await client.sftp();
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

  String get _lookAt1 {
    return "<LookAt><longitude>${13.3374}</longitude><latitude>${52.5086}</latitude><range>${3000}</range><tilt>${0}</tilt><gx:fovy>60</gx:fovy><heading>${0}</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>";
  }

  Future<void> flytoZoo({String? connectionId}) async {
    try {
      return await executeCommand('echo "flytoview=$_lookAt1" > /tmp/query.txt',
          connectionId: connectionId);
    } catch (e) {
      print("Failed to move @Zoo");
    }
  }

  Future<void> runKML(String kmlName, {String? connectionId}) async {
    if (!isConnected) throw Exception('Not connected');
    if (kmlName == "kml2") {
      flytoZoo(connectionId: connectionId);
    }
    try {
      await executeCommand(
        "echo '\nhttp://lg1:81/$kmlName.kml' > /var/www/html/kmls.txt",
        connectionId: connectionId,
      );
    } catch (error) {
      print("Error during runKml: $error");
      rethrow;
    }
  }

  Future<void> relaunchLG(String username, String password,
      {int numberOfRigs = 3, String? connectionId}) async {
    if (!isConnected) throw Exception('Not connected');
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
          '"/home/$username/bin/lg-relaunch" > /home/$username/log.txt',
          connectionId: connectionId,
        );
        await executeCommand(relaunchCmd, connectionId: connectionId);
      }
    } catch (error) {
      print("Error during relaunchLG: $error");
      rethrow;
    }
  }

  // Get connection details for display/management
  Map<String, dynamic> getConnectionInfo(String connectionId) {
    final connection = _connections[connectionId];
    if (connection == null) throw Exception('Connection not found');

    return {
      'host': connection.host,
      'port': connection.port,
      'username': connection.username,
      'isActive': connectionId == _activeConnectionId,
    };
  }
}