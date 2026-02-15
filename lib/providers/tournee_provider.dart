import 'package:flutter/foundation.dart';
import '../models/tournee_model.dart';
import 'api_service.dart';

class TourneeProvider with ChangeNotifier {
  List<Tournee> _tournees = [];
  bool _isLoading = false;
  String? _error;

  List<Tournee> get tournees => _tournees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTournees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tournees = await ApiService.fetchTournees();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTournee(Tournee tournee) async {
    try {
      final newTournee = await ApiService.createTournee(tournee);
      _tournees.add(newTournee);
      notifyListeners();
    } catch (e) {
      debugPrint('Add Tournee error: $e');
    }
  }

  Future<void> updateTournee(Tournee tournee) async {
    try {
      final updated = await ApiService.updateTournee(tournee);
      final index = _tournees.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        _tournees[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update Tournee error: $e');
    }
  }

  Future<void> deleteTournee(int id) async {
    try {
      await ApiService.deleteTournee(id);
      _tournees.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete Tournee error: $e');
    }
  }
}