import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

class OfflineOperation {
  final String id;
  final String operationType;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  bool isProcessed;
  String? error;

  OfflineOperation({
    required this.id,
    required this.operationType,
    required this.data,
    DateTime? createdAt,
    this.isProcessed = false,
    this.error,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'operationType': operationType,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'isProcessed': isProcessed,
        'error': error,
      };

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'] as String,
      operationType: json['operationType'] as String,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isProcessed: json['isProcessed'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }
}

typedef ConnectivityCallback = Future<void> Function(ConnectivityStatus status);
typedef OfflineOperationCallback = Future<void> Function(OfflineOperation op);

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();

  ConnectivityStatus _status = ConnectivityStatus.unknown;
  final List<OfflineOperation> _pendingOperations = [];
  final List<ConnectivityCallback> _connectivityCallbacks = [];
  final List<OfflineOperationCallback> _operationCallbacks = [];
  bool _isInitialized = false;

  StreamSubscription<ConnectivityResult>? _subscription;
  final Connectivity _connectivity = Connectivity();

  factory OfflineService() => _instance;

  OfflineService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initial check
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    // Listen to changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateStatus(result);
      _notifyConnectivityChange();

      if (_status == ConnectivityStatus.connected) {
        _processPendingOperations();
      }
    });

    _isInitialized = true;
  }

  void _updateStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _status = ConnectivityStatus.disconnected;
    } else {
      _status = ConnectivityStatus.connected;
    }
  }

  ConnectivityStatus getStatus() => _status;

  bool isOnline() => _status == ConnectivityStatus.connected;

  bool isOffline() => _status == ConnectivityStatus.disconnected;

  Future<void> _notifyConnectivityChange() async {
    for (final callback in _connectivityCallbacks) {
      try {
        await callback(_status);
      } catch (e) {
        debugPrint('Error in connectivity callback: $e');
      }
    }
  }

  void registerConnectivityCallback(ConnectivityCallback callback) {
    _connectivityCallbacks.add(callback);
  }

  void removeConnectivityCallback(ConnectivityCallback callback) {
    _connectivityCallbacks.remove(callback);
  }

  // ===== Pending Operations Management =====

  Future<void> addPendingOperation(
    String operationType,
    Map<String, dynamic> data,
  ) async {
    final operation = OfflineOperation(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      operationType: operationType,
      data: data,
    );

    _pendingOperations.add(operation);
    await _notifyOperationAdded(operation);
  }

  List<OfflineOperation> getPendingOperations() {
    return List.from(_pendingOperations);
  }

  int getPendingOperationCount() => _pendingOperations.length;

  Future<void> _processPendingOperations() async {
    final operations = List.from(_pendingOperations);

    for (final operation in operations) {
      try {
        await _notifyOperationProcessing(operation);
        operation.isProcessed = true;
        _pendingOperations.remove(operation);
      } catch (e) {
        operation.error = e.toString();
      }
    }
  }

  void registerOperationCallback(OfflineOperationCallback callback) {
    _operationCallbacks.add(callback);
  }

  void removeOperationCallback(OfflineOperationCallback callback) {
    _operationCallbacks.remove(callback);
  }

  Future<void> _notifyOperationAdded(OfflineOperation operation) async {
    for (final callback in _operationCallbacks) {
      try {
        await callback(operation);
      } catch (e) {
        debugPrint('Error in operation added callback: $e');
      }
    }
  }

  Future<void> _notifyOperationProcessing(OfflineOperation operation) async {
    for (final callback in _operationCallbacks) {
      try {
        await callback(operation);
      } catch (e) {
        debugPrint('Error in operation processing callback: $e');
      }
    }
  }

  bool removePendingOperation(String operationId) {
    final index = _pendingOperations.indexWhere((op) => op.id == operationId);
    if (index != -1) {
      _pendingOperations.removeAt(index);
      return true;
    }
    return false;
  }

  void clearPendingOperations() {
    _pendingOperations.clear();
  }

  Future<void> retryOperation(String operationId) async {
    final operation =
        _pendingOperations.firstWhere((op) => op.id == operationId);
    operation.isProcessed = false;
    operation.error = null;
    await _notifyOperationProcessing(operation);
  }

  Map<String, dynamic> getConnectionStats() {
    final processed = _pendingOperations.where((op) => op.isProcessed).length;
    final failed = _pendingOperations.where((op) => op.error != null).length;

    return {
      'status': _status.toString(),
      'is_online': isOnline(),
      'pending_operations': _pendingOperations.length,
      'processed_operations': processed,
      'failed_operations': failed,
      'total_callbacks': _connectivityCallbacks.length,
    };
  }

  void dispose() {
    _subscription?.cancel();
    _connectivityCallbacks.clear();
    _operationCallbacks.clear();
    _pendingOperations.clear();
    _isInitialized = false;
  }
}

final offlineService = OfflineService();
