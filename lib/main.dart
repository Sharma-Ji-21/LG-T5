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
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
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
    final screens = [
      HomeScreen(),
      ProfileScreen(),
      SettingsScreen(
        textScaleFactor: _textScaleFactor,
        onTextScaleFactorChanged: (value) {
          setState(() {
            _textScaleFactor = value;
          });
        },
      ),
    ];

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: _textScaleFactor),
      child: Scaffold(
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: screens,
        ),
        bottomNavigationBar: MotionTabBar(
          initialSelectedTab: "Home",
          labels: ["Home", "Profile", "Settings"],
          icons: [Icons.home, Icons.person, Icons.settings],
          tabSize: 50,
          tabBarHeight: 55,
          textStyle: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          tabIconColor: Colors.grey[400]!,
          tabIconSize: 28.0,
          tabIconSelectedSize: 26.0,
          tabSelectedColor: Theme.of(context).primaryColor,
          tabIconSelectedColor: Colors.white,
          tabBarColor: Colors.grey[900]!,
          onTabItemSelected: (int value) {
            setState(() {
              _selectedIndex = value;
              _tabController?.animateTo(value);
            });
          },
        ),
      ),
    );
  }
}