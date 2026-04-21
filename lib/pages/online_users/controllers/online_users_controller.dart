import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/services/user_service.dart';
import '../../../pages/auth/models/user_model.dart';

class OnlineUsersController extends GetxController {
  var users = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var error = RxnString();
  var searchQuery = ''.obs;

  List<Map<String, dynamic>> get filteredUsers {
    final q = searchQuery.value.trim().toLowerCase();
    return users.where((user) {
      final fullName = user['fullName'].toString().toLowerCase();
      final email = user['email'].toString().toLowerCase();
      final role = user['role'].toString().toLowerCase();
      final isOnline = user['isOnline'] as bool;

      final matchesSearch = q.isEmpty ||
          fullName.contains(q) ||
          email.contains(q) ||
          role.contains(q);

      
      final matchesStatus = isOnline;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchOnlineUsers();
  }

  Future<void> fetchOnlineUsers() async {
    try {
      isLoading.value = true;
      error.value = null;

      final response = await UserService.getUsers();
      final usersList = _extractListResponse(response);

      final onlineUsers = usersList.map((userData) {
        final mapData = Map<String, dynamic>.from(userData);
        final user = User.fromJson(mapData);
        return {
          'id': user.id,
          'fullName': user.fullName,
          'email': user.email,
          'role': user.role,
          'initials': user.initials,
          'isOnline': _simulateOnlineStatus(user.id),
          'isReady': _simulateReadyStatus(user.id),
          'lastSeen': _simulateLastSeen(user.id),
        };
      }).toList();

      users.value = onlineUsers;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  List<dynamic> _extractListResponse(dynamic response) {
    if (response is List) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      if (response['data'] is List) {
        return response['data'] as List<dynamic>;
      }
      if (response['users'] is List) {
        return response['users'] as List<dynamic>;
      }
      if (response['items'] is List) {
        return response['items'] as List<dynamic>;
      }
      return [response];
    }

    return [];
  }

  
  bool _simulateOnlineStatus(int userId) {
    
    return userId % 3 == 0 || userId % 5 == 0;
  }

  
  bool _simulateReadyStatus(int userId) {
   
    return userId % 4 == 0 || userId % 7 == 0;
  }


  DateTime _simulateLastSeen(int userId) {
    final now = DateTime.now();
    
    final randomMinutes = (userId * 17) % (24 * 60);
    return now.subtract(Duration(minutes: randomMinutes));
  }

  String getStatusText(Map<String, dynamic> user) {
    final isOnline = user['isOnline'] as bool;
    final isReady = user['isReady'] as bool;

    if (isOnline && isReady) {
      return 'En ligne & Prêt';
    } else if (isOnline) {
      return 'En ligne';
    } else if (isReady) {
      return 'Prêt à travailler';
    } else {
      return 'Hors ligne';
    }
  }

  Color getStatusColor(Map<String, dynamic> user) {
    final isOnline = user['isOnline'] as bool;
    final isReady = user['isReady'] as bool;

    if (isOnline && isReady) {
      return Color(0xFF00A896); // Green
    } else if (isOnline) {
      return Color(0xFF3D7EFF); // Blue
    } else if (isReady) {
      return Color(0xFFFFA500); // Orange
    } else {
      return Color(0xFF6B7280); // Gray
    }
  }
}