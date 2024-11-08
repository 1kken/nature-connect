import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetStatusNotifier {
  static final InternetStatusNotifier _instance = InternetStatusNotifier._internal();
  factory InternetStatusNotifier() => _instance;

  final _connectionChecker = InternetConnection();
  final _statusController = StreamController<InternetStatus>.broadcast();
  StreamSubscription<InternetStatus>? _subscription;
  bool _isInitialized = false;

  // Public stream to listen to connection changes
  Stream<InternetStatus> get onStatusChange => _statusController.stream;

  InternetStatusNotifier._internal();

  void initialize() {
    if (_isInitialized) return;
    _subscription = _connectionChecker.onStatusChange.listen((status) {
      _statusController.add(status);
    });
    _isInitialized = true;
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}
