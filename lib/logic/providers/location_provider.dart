import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

enum LocationStatus { initial, loading, ready, denied, error }

class LocationProvider extends ChangeNotifier {
  LocationStatus _status = LocationStatus.initial;
  Position? _position;
  String _locationLabel = 'Detecting location...';
  bool _initialized = false;
  
  // Radius filter: null = no boundary, otherwise in km
  int? _selectedRadiusKm;

  LocationStatus get status => _status;
  Position? get position => _position;
  String get locationLabel => _locationLabel;
  bool get hasLocation => _position != null;
  int? get selectedRadiusKm => _selectedRadiusKm;
  
  String get radiusLabel {
    if (_selectedRadiusKm == null) return 'No Boundary';
    return '${_selectedRadiusKm}km';
  }

  LocationProvider() {
    // Don't request location on startup - do it lazily when needed
    // This prevents blocking the entire app during initialization
  }

  /// Initialize location only once (called when first needed)
  Future<void> initializeIfNeeded() async {
    if (_initialized) return;
    _initialized = true;
    await _requestLocation();
  }

  Future<void> _requestLocation() async {
    _status = LocationStatus.loading;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationLabel = 'Location off';
        _status = LocationStatus.denied;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationLabel = 'Permission denied';
          _status = LocationStatus.denied;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationLabel = 'Permission denied permanently';
        _status = LocationStatus.denied;
        notifyListeners();
        return;
      }

      _position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _locationLabel = 'Near you';
      _status = LocationStatus.ready;
    } catch (_) {
      _locationLabel = 'Location unavailable';
      _status = LocationStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => _requestLocation();

  /// Calculates distance in km between user and a store using Haversine formula.
  double? distanceTo(double? storeLat, double? storeLon) {
    if (_position == null || storeLat == null || storeLon == null) return null;

    const R = 6371.0; // Earth radius in km
    final dLat = _toRad(storeLat - _position!.latitude);
    final dLon = _toRad(storeLon - _position!.longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(_position!.latitude)) *
            cos(_toRad(storeLat)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  /// Formats distance nicely: "0.8 km" or "1.2 km"
  String formatDistance(double? km) {
    if (km == null) return '';
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  /// Set the radius filter
  void setRadiusFilter(int? radiusKm) {
    _selectedRadiusKm = radiusKm;
    notifyListeners();
  }

  /// Check if store is within selected radius
  bool isWithinRadius(double? storeLat, double? storeLon) {
    if (_selectedRadiusKm == null) return true; // No boundary
    final distance = distanceTo(storeLat, storeLon);
    if (distance == null) return false;
    return distance <= _selectedRadiusKm!;
  }
}
