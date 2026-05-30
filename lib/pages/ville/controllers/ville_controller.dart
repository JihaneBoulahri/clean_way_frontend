import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/services/ville_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/snackbar_helper.dart';
import '../models/ville_model.dart';

class VilleController extends GetxController {
  final VilleService _service = VilleService();

  var villes = <Ville>[].obs;
  var isLoading = false.obs;
  var error = RxnString();
  var searchQuery = ''.obs;

  List<Ville> get filteredVilles {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return villes;
    return villes.where((ville) {
      return ville.nomVille.toLowerCase().contains(q) ||
          ville.id.toString().contains(q) ||
          (ville.createdAt?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchVilles();
  }

  void _handleError(dynamic e) {
    final text = e.toString();
    if (text.contains('401') || text.contains('Unauthorized')) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    showNadiSnackbar(
      title: 'Erreur',
      message: text,
      type: NadiSnackbarType.error,
    );
  }

  Future<void> fetchVilles() async {
    try {
      isLoading(true);
      error.value = null;
      final data = await _service.getAll();
      villes.value = data.map((json) => Ville.fromJson(json)).toList();
    } catch (e) {
      error.value = e.toString();
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> addVille(Ville ville) async {
    try {
      final data = await _service.create(ville.toJson());
      if (data == null) {
        await fetchVilles();
      } else {
        villes.add(Ville.fromJson(data));
      }

      showNadiSnackbar(
        title: 'Succes',
        message: 'Ville ajoutee avec succes',
        type: NadiSnackbarType.success,
      );
      await NotificationService.instance.showNotification(
        'Ville ajoutee',
        'La ville a ete ajoutee avec succes.',
      );
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateVille(Ville ville) async {
    try {
      final data = await _service.update(ville.id, ville.toJson());
      final index = villes.indexWhere((item) => item.id == ville.id);
      if (data == null) {
        await fetchVilles();
      } else if (index != -1) {
        villes[index] = Ville.fromJson(data);
        villes.refresh();
      }

      showNadiSnackbar(
        title: 'Succes',
        message: 'Ville modifiee avec succes',
        type: NadiSnackbarType.success,
      );
      await NotificationService.instance.showNotification(
        'Ville modifiee',
        'La ville a ete modifiee avec succes.',
      );
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteVille(int id) async {
    try {
      await _service.delete(id);
      villes.removeWhere((ville) => ville.id == id);

      showNadiSnackbar(
        title: 'Succes',
        message: 'Ville supprimee avec succes',
        type: NadiSnackbarType.success,
      );
      await NotificationService.instance.showNotification(
        'Ville supprimee',
        'La ville a ete supprimee avec succes.',
      );
    } catch (e) {
      _handleError(e);
    }
  }
}
