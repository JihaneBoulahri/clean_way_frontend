import 'package:flutter/foundation.dart';
import '../models/chauffeur_model.dart';
import 'api_service.dart';

class ChauffeurProvider with ChangeNotifier {
  List<Chauffeur> _chauffeurs = [];
  bool _isLoading = false;
  String? _error;

  List<Chauffeur> get chauffeurs => _chauffeurs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadChauffeurs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chauffeurs = await ApiService.fetchChauffeurs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addChauffeur(Chauffeur chauffeur) async {
    try {
      final newChauffeur = await ApiService.createChauffeur(chauffeur);
      _chauffeurs.add(newChauffeur);
      notifyListeners();
    } catch (e) {
      debugPrint('Add Chauffeur error: $e');
    }
  }

  Future<void> updateChauffeur(Chauffeur chauffeur) async {
    try {
      final updated = await ApiService.updateChauffeur(chauffeur);
      final index = _chauffeurs.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _chauffeurs[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update Chauffeur error: $e');
    }
  }

  Future<void> deleteChauffeur(int id) async {
    try {
      await ApiService.deleteChauffeur(id);
      _chauffeurs.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete Chauffeur error: $e');
    }
  }
}