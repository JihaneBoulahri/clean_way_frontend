import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await ApiService.fetchUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUser(User user) async {
    try {
      final newUser = await ApiService.createUser(user);
      _users.add(newUser);
      notifyListeners();
    } catch (e) {
      debugPrint('Add User error: $e');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final updated = await ApiService.updateUser(user);
      final index = _users.indexWhere((u) => u.id == updated.id);
      if (index != -1) {
        _users[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update User error: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await ApiService.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete User error: $e');
    }
  }
}