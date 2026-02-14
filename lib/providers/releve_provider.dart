import 'package:flutter/foundation.dart';
import '../models/releve_model.dart';
import 'api_service.dart';

class ReleveProvider with ChangeNotifier {
  List<Releve> _releves = [];
  bool _isLoading = false;
  String? _error;

  List<Releve> get releves => _releves;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReleves() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _releves = await ApiService.fetchReleves();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReleve(Releve releve) async {
    try {
      final newReleve = await ApiService.createReleve(releve);
      _releves.add(newReleve);
      notifyListeners();
    } catch (e) {
      debugPrint('Add Releve error: $e');
    }
  }

  Future<void> updateReleve(Releve releve) async {
    try {
      final updated = await ApiService.updateReleve(releve);
      final index = _releves.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        _releves[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update Releve error: $e');
    }
  }

  Future<void> deleteReleve(int id) async {
    try {
      await ApiService.deleteReleve(id);
      _releves.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete Releve error: $e');
    }
  }
}