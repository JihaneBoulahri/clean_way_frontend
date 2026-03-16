import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../services/email_service.dart';

class HelpController extends GetxController {
  final EmailService _emailService = EmailService();
  final messageController = TextEditingController();
  final isSending = false.obs;
  final _box = GetStorage();

  Future<void> sendSupportMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) {
      Get.snackbar('Error', 'Message is required');
      return;
    }

    final userMap = _readUserMap();
    final name = _buildFullName(userMap);
    final email = (userMap['email'] ?? '').toString().trim();

    if (name.isEmpty || email.isEmpty) {
      Get.snackbar('Error', 'User info is missing');
      return;
    }

    try {
      isSending.value = true;
      await _emailService.sendEmail(
        name: name,
        email: email,
        message: message,
      );
      messageController.clear();
      Get.snackbar('Success', 'Message sent successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSending.value = false;
    }
  }

  Map<String, dynamic> _readUserMap() {
    final raw = _box.read('user');
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  String _buildFullName(Map<String, dynamic> userMap) {
    final prenom = (userMap['prenom'] ?? '').toString().trim();
    final nom = (userMap['nom'] ?? '').toString().trim();
    if (prenom.isNotEmpty || nom.isNotEmpty) {
      return [prenom, nom].where((part) => part.isNotEmpty).join(' ');
    }
    return (userMap['fullName'] ?? userMap['name'] ?? '').toString().trim();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
