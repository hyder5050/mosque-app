import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MosqueProvider with ChangeNotifier {
  List<Mosque> _mosques = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  DateTime? _lastFetchTime;

  List<Mosque> get mosques => _mosques;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get hasData => _mosques.isNotEmpty;

  // Load mosques from Firestore
  Future<void> loadMosques({bool forceRefresh = false}) async {
    // If data exists and not forcing refresh, don't fetch again
    if (_mosques.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('mosques')
          .get();

      _mosques = snapshot.docs
          .map((doc) => Mosque.fromFirestore(doc.data()))
          .toList();

      _lastFetchTime = DateTime.now();
      _isLoading = false;
      _hasError = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to load mosques. Please try again.';
      notifyListeners();
    }
  }

  // Refresh mosques data
  Future<void> refreshMosques() async {
    await loadMosques(forceRefresh: true);
  }

  // Get mosque by ID
  Mosque? getMosqueById(String id) {
    try {
      return _mosques.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Mosque Model
class Mosque {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String address;

  Mosque({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
  });

  factory Mosque.fromFirestore(Map<String, dynamic> data) {
    return Mosque(
      id: data['id'] ?? 'Unknown',
      name: data['name'] ?? 'Unknown',
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      address: data['address'] ?? 'No address provided',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'lat': lat, 'lng': lng, 'address': address};
  }
}
