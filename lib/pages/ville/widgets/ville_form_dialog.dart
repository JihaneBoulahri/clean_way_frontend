import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/snackbar_helper.dart';
import '../controllers/ville_controller.dart';
import '../models/ville_model.dart';

class VilleFormDialog extends StatefulWidget {
  final Ville? ville;

  const VilleFormDialog({super.key, this.ville});

  @override
  State<VilleFormDialog> createState() => _VilleFormDialogState();
}

class _VilleFormDialogState extends State<VilleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late final TextEditingController _nomController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.ville?.nomVille ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final nom = _nomController.text.trim();
    if (nom.isEmpty) {
      showNadiSnackbar(
        title: 'Erreur',
        message: 'Le nom de la ville est requis',
        type: NadiSnackbarType.error,
      );
      return;
    }

    setState(() => _saving = true);
    final controller = Get.find<VilleController>();

    try {
      final payload = Ville(
        id: widget.ville?.id ?? 0,
        nomVille: nom,
        createdAt: widget.ville?.createdAt,
        updatedAt: widget.ville?.updatedAt,
      );

      if (widget.ville == null) {
        await controller.addVille(payload);
      } else {
        await controller.updateVille(payload);
      }

      if (mounted) Navigator.of(context).pop(payload);
    } catch (e) {
      showNadiSnackbar(
        title: 'Erreur',
        message: e.toString(),
        type: NadiSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.ville != null;
    return AlertDialog(
      title: Text(isEdit ? 'Modifier la ville' : 'Ajouter une ville'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nomController,
          decoration: const InputDecoration(labelText: 'Nom de la ville'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Modifier' : 'Ajouter'),
        ),
      ],
    );
  }
}
