import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/native_info_service.dart';

class NativeDrawer extends StatefulWidget {
  const NativeDrawer({super.key, required this.onRefreshDashboard, required this.onToggleTheme});

  final VoidCallback onRefreshDashboard;
  final VoidCallback onToggleTheme;

  @override
  State<NativeDrawer> createState() => _NativeDrawerState();
}

class _NativeDrawerState extends State<NativeDrawer> {
  String _deviceSummary = 'Loading...';
  bool _isConnected = true;
  final NativeInfoService _nativeService = NativeInfoService();

  @override
  void initState() {
    super.initState();
    _loadNativeData();
  }

  Future<void> _loadNativeData() async {
    final summary = await _nativeService.getDeviceSummary();
    final connected = await _nativeService.hasInternetConnection();
    if (mounted) {
      setState(() {
        _deviceSummary = summary;
        _isConnected = connected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.brown,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.coffee_rounded, size: 36, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'Brew & Co. Operations',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _deviceSummary,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(_isConnected ? Icons.wifi : Icons.wifi_off, color: _isConnected ? Colors.green : Colors.red),
            title: Text(_isConnected ? 'Network Connected' : 'Offline Mode'),
            subtitle: const Text('Device Status'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('Refresh Dashboard'),
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              widget.onRefreshDashboard();
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_rounded),
            title: const Text('Toggle Dark/Light Mode'),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onToggleTheme();
            },
          ),
        ],
      ),
    );
  }
}
