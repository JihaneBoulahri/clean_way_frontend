import 'package:flutter/foundation.dart';
import '../models/camion_model.dart';
import 'api_service.dart';

class CamionProvider with ChangeNotifier {
  List<Camion> _camions = [];
  bool _isLoading = false;
  String? _error;

  List<Camion> get camions => _camions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCamions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _camions = await ApiService.fetchCamions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCamion(Camion camion) async {
    try {
      final newCamion = await ApiService.createCamion(camion);
      _camions.add(newCamion);
      notifyListeners();
    } catch (e) {
      debugPrint('Add Camion error: $e');
    }
  }

  Future<void> updateCamion(Camion camion) async {
    try {
      final updated = await ApiService.updateCamion(camion);
      final index = _camions.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _camions[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update Camion error: $e');
    }
  }

  Future<void> deleteCamion(int id) async {
    try {
      await ApiService.deleteCamion(id);
      _camions.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete Camion error: $e');
    }
  }
}