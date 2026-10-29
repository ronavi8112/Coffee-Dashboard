import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'config.dart';
import 'services/native_info_service.dart';
import 'widgets/native_drawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  late final WebViewController _controller;
  Timer? _refreshTimer;
  final NativeInfoService _nativeService = NativeInfoService();

  int _progress = 0;
  bool _hasError = false;
  bool _isOnline = true;
  DateTime? _lastUpdated;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initWebView();
    _checkConnectivity();
    _startAutoRefresh();
  }

  Future<void> _checkConnectivity() async {
    final online = await _nativeService.hasInternetConnection();
    if (mounted) setState(() => _isOnline = online);
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() => _hasError = false);
          },
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _progress = 100;
              if (!_hasError) _lastUpdated = DateTime.now();
            });
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              if (!mounted) return;
              setState(() => _hasError = true);
            }
          },
        ),
      );

    _controller.loadFlutterAsset(AppConfig.dashboardAssetUrl);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reload();
      _startAutoRefresh();
      _checkConnectivity();
    } else if (state == AppLifecycleState.paused) {
      _refreshTimer?.cancel();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(AppConfig.refreshInterval, (_) => _reload());
  }

  Future<void> _reload() async {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    await _checkConnectivity();
    if (_hasError) {
      await _controller.loadFlutterAsset(AppConfig.dashboardAssetUrl);
    } else {
      await _controller.reload();
    }
  }

  String get _lastUpdatedLabel {
    final t = _lastUpdated;
    if (t == null) return 'Syncing…';
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    final ss = t.second.toString().padLeft(2, '0');
    return 'Updated $hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NativeDrawer(
        onRefreshDashboard: _reload,
        onToggleTheme: widget.onToggleTheme,
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppConfig.appTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              _lastUpdatedLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (!_isOnline)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.cloud_off, color: Colors.amber, size: 20),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _reload,
          ),
        ],
        bottom: _progress < 100 && !_hasError
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress / 100,
                  backgroundColor: Colors.transparent,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_hasError)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                      const SizedBox(height: 12),
                      const Text('Unable to load dashboard'),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _reload, child: const Text('Retry')),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
