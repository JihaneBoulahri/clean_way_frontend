import 'package:flutter/foundation.dart';
import '../models/benne_model.dart';
import 'api_service.dart';

class BenneProvider with ChangeNotifier {
  List<Benne> _bennes = [];
  bool _isLoading = false;
  String? _error;

  List<Benne> get bennes => _bennes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBennes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bennes = await ApiService.fetchBennes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBenne(Benne benne) async {
    try {
      final newBenne = await ApiService.createBenne(benne);
      _bennes.add(newBenne);
      notifyListeners();
    } catch (e) {
      // Handle error (e.g., show snackbar)
      debugPrint('Add Benne error: $e');
    }
  }

  Future<void> updateBenne(Benne benne) async {
    try {
      final updated = await ApiService.updateBenne(benne);
      final index = _bennes.indexWhere((b) => b.id == updated.id);
      if (index != -1) {
        _bennes[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update Benne error: $e');
    }
  }

  Future<void> deleteBenne(int id) async {
    try {
      await ApiService.deleteBenne(id);
      _bennes.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete Benne error: $e');
    }
  }
}