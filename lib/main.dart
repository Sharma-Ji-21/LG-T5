import 'package:flutter/material.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'services/multi_ssh_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MultiSSHService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motion Tab Bar Demo',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: MainScreen(),
    );
  }
}

class CustomAnimatedNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<NavigationBarItem> items;

  const CustomAnimatedNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  _CustomAnimatedNavigationBarState createState() => _CustomAnimatedNavigationBarState();
}

class _CustomAnimatedNavigationBarState extends State<CustomAnimatedNavigationBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _xAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _setupAnimations();
  }

  void _setupAnimations() {
    final double width = 1.0 / widget.items.length;
    final double startX = widget.selectedIndex * width;
    final double endX = widget.selectedIndex * width;

    _widthAnimation = Tween<double>(
      begin: width,
      end: width,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _xAnimation = Tween<double>(
      begin: startX,
      end: endX,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(CustomAnimatedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      final double width = 1.0 / widget.items.length;
      final double startX = oldWidget.selectedIndex * width;
      final double endX = widget.selectedIndex * width;

      _xAnimation = Tween<double>(
        begin: startX,
        end: endX,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: MediaQuery.of(context).size.width * _xAnimation.value,
                width: MediaQuery.of(context).size.width * _widthAnimation.value,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              widget.items.length,
                  (index) => _buildNavigationItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(int index) {
    final item = widget.items[index];
    final isSelected = widget.selectedIndex == index;

    return InkWell(
      onTap: () => widget.onTap(index),
      child: Container(
        width: MediaQuery.of(context).size.width / widget.items.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimateIcon(
              key: ValueKey('nav_icon_$index'),
              onTap: () {},
              iconType: isSelected ? IconType.continueAnimation : IconType.continueAnimation,
              height: 40,
              width: 40,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).unselectedWidgetColor,
              animateIcon: item.icon,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).unselectedWidgetColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationBarItem {
  final AnimateIcons icon;
  final String label;

  NavigationBarItem({
    required this.icon,
    required this.label,
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  double _textScaleFactor = 1.0;

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
        body: screens[_selectedIndex],
        bottomNavigationBar: CustomAnimatedNavigationBar(
          selectedIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            NavigationBarItem(
              icon: AnimateIcons.home,
              label: 'Home',
            ),
            NavigationBarItem(
              icon: AnimateIcons.bell,
              label: 'Profile',
            ),
            NavigationBarItem(
              icon: AnimateIcons.settings,
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
