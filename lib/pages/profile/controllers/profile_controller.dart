import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../pages/auth/models/user_model.dart';
import '../../../core/services/user_service.dart';


class ProfileController extends GetxController {
  final GetStorage _box = GetStorage();

  var user = Rxn<User>();
  var isLoading = false.obs;
  var error = RxnString();
  var isEditing = false.obs;

  // Form fields
  var nom = ''.obs;
  var prenom = ''.obs;
  var email = ''.obs;

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
      };

      await UserService.update(user.value!.id, updatedData);

      // Update local user data
      final updatedUser = User(
        id: user.value!.id,
        nom: nom.value,
        prenom: prenom.value,
        email: email.value,
        role: user.value!.role,
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
}