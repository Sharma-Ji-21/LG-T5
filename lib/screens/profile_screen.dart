import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ssh_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  int _currentStep = 0;
  final List<String> _steps = ['IP Address', 'Port', 'Username', 'Password'];

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('host') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _portController.text = (prefs.getInt('port') ?? 22).toString();
      _passwordController.text = prefs.getString('password') ?? '';
      _updateCurrentStep();
    });
  }

  void _updateCurrentStep() {
    final sshService = Provider.of<SSHService>(context, listen: false);
    int completedFields = 0;
    if (_ipController.text.isNotEmpty) completedFields++;
    if (_portController.text.isNotEmpty) completedFields++;
    if (_usernameController.text.isNotEmpty) completedFields++;
    if (_passwordController.text.isNotEmpty) completedFields++;

    setState(() {
      _currentStep = sshService.isConnected ? _steps.length : completedFields;
    });
  }

  Widget _buildProgressIndicator() {
    var lineWidth = MediaQuery.of(context).size.width - 32.0;
    var space = lineWidth / _steps.length;
    final sshService = Provider.of<SSHService>(context);

    return SizedBox(
      height: 60.0,
      child: Stack(
        children: [
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            child: Container(
              height: 2.0,
              width: double.infinity,
              color: Colors.grey,
            ),
          ),
          Positioned(
            top: 15,
            left: 0,
            child: Container(
              height: 2.0,
              width: sshService.isConnected
                  ? lineWidth
                  : space * (_currentStep - 1) + space / 2,
              color: Colors.blue,
            ),
          ),
          Row(
            children: _steps
                .asMap()
                .map((i, point) => MapEntry(
              i,
              SizedBox(
                width: space,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 30.0,
                          width: 30.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1.5,
                              color: i == _currentStep - 1
                                  ? Colors.blue
                                  : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              height: 20.0,
                              width: 20.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: sshService.isConnected &&
                                    i == _steps.length - 1
                                    ? Colors.blue
                                    : i < _currentStep
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        if (i < _currentStep - 1 ||
                            (sshService.isConnected &&
                                i == _steps.length - 1))
                          const SizedBox(
                            height: 30.0,
                            width: 30.0,
                            child: Center(
                              child: Icon(
                                Icons.check,
                                size: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      point,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: i < _currentStep ||
                            (sshService.isConnected &&
                                i == _steps.length - 1)
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ))
                .values
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.blue[700]),
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[300]!, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.blue[700]),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: (_) => _updateCurrentStep(),
    );
  }

  Widget _buildConnectButton() {
    return Consumer<SSHService>(
      builder: (context, sshService, child) {
        return Center(
          child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await sshService.connect(
                    host: _ipController.text,
                    username: _usernameController.text,
                    password: _passwordController.text,
                    port: int.parse(_portController.text),
                  );

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('host', _ipController.text);
                  await prefs.setString('username', _usernameController.text);
                  await prefs.setString('password', _passwordController.text);
                  await prefs.setInt('port', int.parse(_portController.text));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connected successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {
                    _currentStep = _steps.length;
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connection failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue[700],
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(sshService.isConnected ? Icons.refresh : Icons.connect_without_contact),
                SizedBox(width: 10),
                Text(sshService.isConnected ? 'Reconnect' : 'Connect'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/bgImg.jpg',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressIndicator(),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _ipController,
                      labelText: 'IP Address',
                      hintText: 'Enter IP address',
                      prefixIcon: Icons.computer,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter IP address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    _buildTextField(
                      controller: _portController,
                      labelText: 'Port',
                      hintText: 'Enter port number',
                      prefixIcon: Icons.settings_ethernet,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter port number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    _buildTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                      hintText: 'Enter username',
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    _buildTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter password',
                      prefixIcon: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _buildConnectButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}