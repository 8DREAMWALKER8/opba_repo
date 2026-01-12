import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opba_app/models/app_notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _api;
  final GlobalKey<NavigatorState> _navigatorKey;
  bool _isDialogOpen = false;

  Timer? _timer;
  bool _polling = false;

  NotificationProvider({
    required ApiService api,
    required GlobalKey<NavigatorState> navigatorKey,
  })  : _api = api,
        _navigatorKey = navigatorKey;

  List<AppNotification> _items = [];
  bool _loading = false;
  String? _error;

  List<AppNotification> get items => _items;
  bool get isLoading => _loading;
  String? get error => _error;

  void startPolling({Duration interval = const Duration(seconds: 15)}) {
    if (_polling) return;
    _polling = true;

    _tick();

    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  void stopPolling() {
    _polling = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  Future<void> _tick() async {
    try {
      // app görünür değilse popup gösterme
      if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        return;
      }

      // sadece okunmamışları çek
      await fetchMyNotifications(limit: 50, isRead: false);

      if (_items.isEmpty) return;

      final newest = _items.first;
      // popup göster
      await _showPopupFor(newest);

      // popup gösterdikten sonra okundu işaretle
      await markAsRead(newest.id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchMyNotifications({int limit = 50, bool? isRead}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final resp = await _api.getNotifications(limit: limit, isRead: isRead);

      List list;
      if (resp is Map && resp['ok'] == true) {
        list =
            (resp['items'] as List?) ?? (resp['notifications'] as List?) ?? [];
      } else if (resp is List) {
        list = resp;
      } else {
        list = [];
      }

      _items = list
          .whereType<Map>()
          .map((x) => AppNotification.fromJson(Map<String, dynamic>.from(x)))
          .toList();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      final idx = _items.indexWhere((n) => n.id == id);
      if (idx == -1) return false;
      if (_items[idx].isRead) return true;

      _items[idx] = _items[idx].copyWith(isRead: true);
      notifyListeners();

      final resp = await _api.markNotificationRead(id);
      if (resp is Map && resp['ok'] != true) {
        _items[idx] = _items[idx].copyWith(isRead: false);
        notifyListeners();
        return false;
      }
      return true;
    } catch (_) {
      final idx = _items.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _items[idx] = _items[idx].copyWith(isRead: false);
        notifyListeners();
      }
      return false;
    }
  }

  Future<void> _showPopupFor(AppNotification n) async {
    final nav = _navigatorKey.currentState;
    final ctx = nav?.overlay?.context;

    if (ctx == null) {
      return;
    }

    if (_isDialogOpen) return;
    _isDialogOpen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await showDialog(
          context: ctx,
          useRootNavigator: true,
          barrierDismissible: true,
          builder: (_) => AlertDialog(
            title: Text(n.title),
            content: Text(n.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      } finally {
        _isDialogOpen = false;
      }
    });
  }
}
