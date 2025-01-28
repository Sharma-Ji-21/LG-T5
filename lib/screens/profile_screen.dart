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
  final double _textScaleFactor = 1.2;

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
      height: 72.0,
      child: Stack(
        children: [
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            child: Container(
              height: 2.0,
              width: double.infinity,
              color: Colors.grey[300],
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
              color: Colors.black,
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
                                  ? Colors.black
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
                                    ? Colors.black
                                    : i < _currentStep
                                    ? Colors.black
                                    : Colors.grey[300],
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
                      textScaleFactor: _textScaleFactor,
                      style: TextStyle(
                        color: i < _currentStep ||
                            (sshService.isConnected &&
                                i == _steps.length - 1)
                            ? Colors.black
                            : Colors.grey[600],
                        fontWeight: FontWeight.w500,
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
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16 * _textScaleFactor,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16 * _textScaleFactor,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16 * _textScaleFactor,
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.black,
            size: 24 * _textScaleFactor,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16 * _textScaleFactor,
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onChanged: (_) => _updateCurrentStep(),
      ),
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
                    const SnackBar(
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
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 15 * _textScaleFactor,
              ),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  sshService.isConnected
                      ? Icons.refresh
                      : Icons.connect_without_contact,
                  color: Colors.white,
                  size: 24 * _textScaleFactor,
                ),
                SizedBox(width: 10 * _textScaleFactor),
                Text(
                  sshService.isConnected ? 'Reconnect' : 'Connect',
                  style: TextStyle(
                    fontSize: 16 * _textScaleFactor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20 * _textScaleFactor,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressIndicator(),
                SizedBox(height: 20 * _textScaleFactor),
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
                SizedBox(height: 16 * _textScaleFactor),
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
                SizedBox(height: 16 * _textScaleFactor),
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
                SizedBox(height: 16 * _textScaleFactor),
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
                SizedBox(height: 24 * _textScaleFactor),
                _buildConnectButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}