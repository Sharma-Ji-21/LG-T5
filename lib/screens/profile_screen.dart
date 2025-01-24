import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ssh_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '22');

  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('host') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _portController.text = (prefs.getInt('port') ?? 22).toString();
      _passwordController.text = prefs.getString('password') ?? '';
    });
    _updateProgress();
  }

  void _updateProgress() {
    int completedFields = 0;
    if (_ipController.text.isNotEmpty) completedFields++;
    if (_portController.text.isNotEmpty) completedFields++;
    if (_usernameController.text.isNotEmpty) completedFields++;
    if (_passwordController.text.isNotEmpty) completedFields++;
    setState(() {
      _progressValue = completedFields / 4;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   '${(_progressValue * 100).toStringAsFixed(0)}%',
        //   style: const TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('IP Address'),
            const Text('Port'),
            const Text('Username'),
            const Text('Password'),
          ],
        ),
        const SizedBox(height: 8.0),
        LinearProgressIndicator(
          value: _progressValue,
          color: Colors.blue,
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(height: 12.0),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     const Text('IP Address'),
        //     Icon(
        //       _ipController.text.isNotEmpty ? Icons.check : Icons.circle,
        //       color: _ipController.text.isNotEmpty ? Colors.blue : Colors.grey,
        //       size: 16,
        //     ),
        //   ],
        // ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              _ipController.text.isNotEmpty ? Icons.check : Icons.dangerous,
              color: _ipController.text.isNotEmpty ? Colors.green : Colors.red,
              size: 16,
            ),
            Icon(
              _portController.text.isNotEmpty ? Icons.check : Icons.dangerous,
              color: _portController.text.isNotEmpty ? Colors.green : Colors.red,
              size: 16,
            ),
            Icon(
              _usernameController.text.isNotEmpty ? Icons.check : Icons.dangerous,
              color: _usernameController.text.isNotEmpty ? Colors.green : Colors.red,
              size: 16,
            ),
            Icon(
              _passwordController.text.isNotEmpty ? Icons.check : Icons.dangerous,
              color: _passwordController.text.isNotEmpty ? Colors.green : Colors.red,
              size: 16,
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     const Text('Username'),
        //     Icon(
        //       _usernameController.text.isNotEmpty ? Icons.check : Icons.circle,
        //       color: _usernameController.text.isNotEmpty ? Colors.blue : Colors.grey,
        //       size: 16,
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 8.0),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     const Text('Password'),
        //     Icon(
        //       _passwordController.text.isNotEmpty ? Icons.check : Icons.circle,
        //       color: _passwordController.text.isNotEmpty ? Colors.blue : Colors.grey,
        //       size: 16,
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 12.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressIndicator(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'IP Address',
                  hintText: 'Enter IP address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter IP address';
                  }
                  return null;
                },
                onChanged: (value) => _updateProgress(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  hintText: 'Enter port number',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter port number';
                  }
                  return null;
                },
                onChanged: (value) => _updateProgress(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
                onChanged: (value) => _updateProgress(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                onChanged: (value) => _updateProgress(),
              ),
              const SizedBox(height: 20),
              Consumer<SSHService>(
                builder: (context, sshService, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await sshService.connect(
                            host: _ipController.text,
                            username: _usernameController.text,
                            password: _passwordController.text,
                            port: int.parse(_portController.text),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Connected successfully')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                  Text('Connection failed: ${e.toString()}')),
                            );
                          }
                        }
                      }
                    },
                    child:
                    Text(sshService.isConnected ? 'Reconnect' : 'Connect'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}