import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';
import 'dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const NativeDashboardApp());
}

class NativeDashboardApp extends StatefulWidget {
  const NativeDashboardApp({super.key});

  @override
  State<NativeDashboardApp> createState() => _NativeDashboardAppState();
}

class _NativeDashboardAppState extends State<NativeDashboardApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.brown,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.brown,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: DashboardPage(onToggleTheme: _toggleTheme),
    );
  }
}
