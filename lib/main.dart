import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'services/ssh_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SSHService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motion Tab Bar Demo',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue;
            }
            return null;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue.withOpacity(0.5);
            }
            return null;
          }),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue;
            }
            return null;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue.withOpacity(0.5);
            }
            return null;
          }),
        ),
      ),
      themeMode: ThemeMode.dark,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  int _selectedIndex = 0;
  bool _isDarkMode = true;
  bool _isNotificationsEnabled = true;
  String _selectedLanguage = 'English';
  double _textScaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: _selectedIndex,
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(),
      ProfileScreen(),
      SettingsScreen(
        isDarkMode: _isDarkMode,
        textScaleFactor: _textScaleFactor,
        onThemeChanged: (value) {
          setState(() {
            _isDarkMode = value;
          });
        },
        onTextScaleFactorChanged: (value) {
          setState(() {
            _textScaleFactor = value;
          });
        },
      ),
    ];

    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: _textScaleFactor),
        child: Scaffold(
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(), // Disable swipe
            controller: _tabController,
            children: screens,
          ),
          bottomNavigationBar: MotionTabBar(
            initialSelectedTab: "Home",
            labels: const ["Home", "Profile", "Settings"],
            icons: const [
              Icons.home,
              Icons.person,
              Icons.settings
            ],
            tabSize: 50,
            tabBarHeight: 55,
            textStyle: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            tabIconColor: _isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
            tabIconSize: 28.0,
            tabIconSelectedSize: 26.0,
            tabSelectedColor: Theme.of(context).primaryColor,
            tabIconSelectedColor: Colors.white,
            tabBarColor: _isDarkMode ? Colors.grey[900]! : Colors.white,
            onTabItemSelected: (int value) {
              setState(() {
                _selectedIndex = value;
                _tabController?.animateTo(value);
              });
            },
          ),
        ),
      ),
    );
  }
}