import 'package:flutter/foundation.dart';
import '../models/capteur_model.dart';
import 'api_service.dart';

class CapteurProvider with ChangeNotifier {
  List<Capteur> _capteurs = [];
  bool _isLoading = false;
  String? _error;

  List<Capteur> get capteurs => _capteurs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCapteurs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _capteurs = await ApiService.fetchCapteurs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCapteur(Capteur capteur) async {
    try {
      final newCapteur = await ApiService.createCapteur(capteur);
      _capteurs.add(newCapteur);
      notifyListeners();
    } catch (e) {
      debugPrint('Add Capteur error: $e');
    }
  }

  Future<void> updateCapteur(Capteur capteur) async {
    try {
      final updated = await ApiService.updateCapteur(capteur);
      final index = _capteurs.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _capteurs[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update Capteur error: $e');
    }
  }

  Future<void> deleteCapteur(int id) async {
    try {
      await ApiService.deleteCapteur(id);
      _capteurs.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete Capteur error: $e');
    }
  }
}