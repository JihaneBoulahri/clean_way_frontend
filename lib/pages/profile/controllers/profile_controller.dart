import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../pages/auth/models/user_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/constants/api_constants.dart';


class ProfileController extends GetxController {
  final GetStorage _box = GetStorage();

  var user = Rxn<User>();
  var isLoading = false.obs;
  var error = RxnString();
  var isEditing = false.obs;
  var isFetchingPhones = false.obs;
  var phoneNumbers = <String>[].obs;

  // Form fields
  var nom = ''.obs;
  var prenom = ''.obs;
  var email = ''.obs;
  var telephone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  void loadUserProfile() {
    try {
      final userData = _box.read('user');
      if (userData != null) {
        user.value = User.fromJsonSafe(userData);
        _populateFormFields();
      } else {
       
        fetchUserProfile();
      }
    } catch (e) {
      error.value = 'Erreur lors du chargement du profil: ${e.toString()}';
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      error.value = null;

      final userData = _box.read('user');
      if (userData != null) {
        final userId = userData['id'];
        final response = await UserService.getById(userId);
        user.value = User.fromJson(response);
        _populateFormFields();
      }
    } catch (e) {
      error.value = 'Erreur lors du chargement du profil: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFormFields() {
    if (user.value != null) {
      nom.value = user.value!.nom;
      prenom.value = user.value!.prenom;
      email.value = user.value!.email;
      telephone.value = user.value!.telephone;
    }
  }

  Future<void> updateProfile() async {
    if (user.value == null) return;

    try {
      isLoading.value = true;
      error.value = null;

      final updatedData = {
        'nom': nom.value,
        'prenom': prenom.value,
        'email': email.value,
        'telephone': telephone.value,
      };

      await UserService.update(user.value!.id, updatedData);

      // Update local user data
      final updatedUser = User(
        id: user.value!.id,
        nom: nom.value,
        prenom: prenom.value,
        email: email.value,
        role: user.value!.role,
        telephone: telephone.value,
        emailVerifiedAt: user.value!.emailVerifiedAt,
      );

      user.value = updatedUser;
      _box.write('user', updatedUser.toJson());

      isEditing.value = false;
      Get.snackbar(
        'Succès',
        'Profil mis à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Erreur lors de la mise à jour: ${e.toString()}';
      Get.snackbar(
        'Erreur',
        error.value!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void startEditing() {
    isEditing.value = true;
    _populateFormFields();
  }

  void cancelEditing() {
    isEditing.value = false;
    _populateFormFields();
  }

  /// Fetch phone numbers from database for current user
  Future<void> fetchPhoneNumbersFromDatabase() async {
    if (user.value == null) return;

    try {
      isFetchingPhones.value = true;
      error.value = null;

      final token = _box.read('token')?.toString();
      final headers = <String, String>{"Content-Type": "application/json"};
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      // Fetch user details which includes phone numbers
      final response = await http.get(
        Uri.parse("${UserEndpoints.detail(user.value!.id)}/phones"),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        
        // Handle different response formats
        List<String> phones = [];
        if (decoded is Map && decoded.containsKey('phones')) {
          // If response has 'phones' key
          phones = List<String>.from(decoded['phones'] ?? []);
        } else if (decoded is List) {
          // If response is a list of phone objects
          phones = decoded
              .whereType<Map<String, dynamic>>()
              .map((p) => p['numero']?.toString() ?? p['phone']?.toString() ?? '')
              .where((p) => p.isNotEmpty)
              .toList();
        }

        phoneNumbers.value = phones;
        
        if (phones.isEmpty) {
          Get.snackbar(
            'Info',
            'Aucun numéro de téléphone trouvé',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        throw Exception('Erreur lors de la récupération: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'Erreur: ${e.toString()}';
      Get.snackbar(
        'Erreur',
        'Impossible de récupérer les numéros de téléphone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isFetchingPhones.value = false;
    }
  }

  /// Set phone number from the fetched list
  void setPhoneNumber(String phone) {
    telephone.value = phone;
    Get.back(); // Close dialog
  }
}