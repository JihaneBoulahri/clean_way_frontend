import 'package:flutter/foundation.dart';
import '../models/zone_model.dart';
import 'api_service.dart';

class ZoneProvider with ChangeNotifier {
  List<Zone> _zones = [];
  bool _isLoading = false;
  String? _error;

  List<Zone> get zones => _zones;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadZones() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _zones = await ApiService.fetchZones();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addZone(Zone zone) async {
    try {
      final newZone = await ApiService.createZone(zone);
      _zones.add(newZone);
      notifyListeners();
    } catch (e) {
      debugPrint('Add Zone error: $e');
    }
  }

  Future<void> updateZone(Zone zone) async {
    try {
      final updated = await ApiService.updateZone(zone);
      final index = _zones.indexWhere((z) => z.id == updated.id);
      if (index != -1) {
        _zones[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update Zone error: $e');
    }
  }

  Future<void> deleteZone(int id) async {
    try {
      await ApiService.deleteZone(id);
      _zones.removeWhere((z) => z.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete Zone error: $e');
    }
  }
}