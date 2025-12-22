import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String toCoordinateString() => '$latitude,$longitude';

  @override
  String toString() =>
      'Location(lat: $latitude, lon: $longitude, accuracy: ${accuracy?.toStringAsFixed(2)}m)';

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
      };
}

class LocationService {
  static final LocationService _instance = LocationService._internal();

  LocationData? _lastLocation;
  bool _isListening = false;
  bool _isInitialized = false;

  factory LocationService() => _instance;

  LocationService._internal();

  // Initialize Service
  Future<void> initialize() async {
    if (_isInitialized) return;
    await Geolocator.checkPermission();
    _isInitialized = true;
  }

  // Get Current Location
  Future<LocationData?> getCurrentLocation() async {
    try {
      if (!await _checkAndRequestPermissions()) return null;

      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lastLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );

      return _lastLocation;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // Check and Request Permissions
  Future<bool> _checkAndRequestPermissions() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  LocationData? getLastKnownLocation() => _lastLocation;

  // Start Location Updates
  Future<bool> startLocationUpdates({
    Duration updateInterval = const Duration(seconds: 5),
    double distanceFilter = 10,
  }) async {
    if (_isListening) return true;

    try {
      if (!await _checkAndRequestPermissions()) return false;

      // Note: Real implementations often use streams.
      // For simplicity in this structure, we just mark as listening
      // and ensure we have One-Time access.
      // If stream is needed: Geolocator.getPositionStream().listen(...)
      _isListening = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> stopLocationUpdates() async {
    _isListening = false;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> getPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Calculate Distance (Haversine)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1000; // Return in KM
  }

  static String formatCoordinates(double latitude, double longitude) {
    return '$latitude, $longitude';
  }

  Future<String> getLocationDetails() async {
    try {
      final location = await getCurrentLocation();
      if (location == null) return 'No Location';
      return location.toString();
    } catch (e) {
      return 'Error getting location';
    }
  }

  Future<bool> hasLocationPermission() async {
    final status = await getPermissionStatus();
    return status == LocationPermission.whileInUse ||
        status == LocationPermission.always;
  }

  bool isListening() => _isListening;

  Future<String?> getEmergencySafeLocation() async {
    try {
      final location = await getCurrentLocation();
      if (location != null) {
        return location.toCoordinateString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  Future<void> dispose() async {
    await stopLocationUpdates();
    _lastLocation = null;
    _isInitialized = false;
  }
}

// مثيل عام للاستخدام السريع
final locationService = LocationService();
