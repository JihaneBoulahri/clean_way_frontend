import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chauffeur_model.dart';
import '../controllers/chauffeur_controller.dart';
import '../../../widgets/snackbar_helper.dart';

class ChauffeurFormDialog extends StatefulWidget {
  final Chauffeur? chauffeur;

  const ChauffeurFormDialog({super.key, this.chauffeur});

  @override
  State<ChauffeurFormDialog> createState() => _ChauffeurFormDialogState();
}

class _ChauffeurFormDialogState extends State<ChauffeurFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _hidePassword = true;
  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cniController;
  late final TextEditingController _permisController;
  late final TextEditingController _camionIdController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(
      text: widget.chauffeur?.user?.nom ?? '',
    );
    _prenomController = TextEditingController(
      text: widget.chauffeur?.user?.prenom ?? '',
    );
    _emailController = TextEditingController(
      text: widget.chauffeur?.user?.email ?? '',
    );
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(
      text: widget.chauffeur?.numTelephone ?? '',
    );
    _cniController = TextEditingController(text: widget.chauffeur?.cni ?? '');
    _permisController = TextEditingController(
      text: widget.chauffeur?.permis ?? '',
    );
    _camionIdController = TextEditingController(
      text:
          widget.chauffeur?.camionId?.toString() ??
          widget.chauffeur?.camion?.id.toString() ??
          '',
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cniController.dispose();
    _permisController.dispose();
    _camionIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final isEdit = widget.chauffeur != null;
    final password = _passwordController.text.trim();
    final camionId = _camionIdController.text.trim().isEmpty
        ? null
        : int.tryParse(_camionIdController.text.trim());

    if (_camionIdController.text.trim().isNotEmpty && camionId == null) {
      showNadiSnackbar(
        title: "Erreur",
        message: "L'ID camion doit être un nombre entier",
        type: NadiSnackbarType.error,
      );
      return;
    }

    if (!isEdit && password.isEmpty) {
      showNadiSnackbar(
        title: "Erreur",
        message: "Le mot de passe est obligatoire pour créer un chauffeur",
        type: NadiSnackbarType.error,
      );
      return;
    }

    final resolvedCamionId = camionId ?? widget.chauffeur?.camionId;
    if (resolvedCamionId == null) {
      showNadiSnackbar(
        title: "Erreur",
        message: "L'ID camion est obligatoire",
        type: NadiSnackbarType.error,
      );
      return;
    }

    final payload = <String, dynamic>{
      'nom': _nomController.text.trim(),
      'prenom': _prenomController.text.trim(),
      'email': _emailController.text.trim(),
      'role': 'chauffeur',
      'num_telephone': _phoneController.text.trim(),
      'cni': _cniController.text.trim(),
      'permis': _permisController.text.trim(),
      'id_camion': resolvedCamionId,
    };
    if (password.isNotEmpty) {
      payload['password'] = password;
    }

    final controller = Get.find<ChauffeurController>();
    setState(() => _saving = true);
    try {
      if (!isEdit) {
        await controller.addChauffeur(payload);
      } else {
        await controller.updateChauffeur(widget.chauffeur!.id, payload);
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.chauffeur != null;
    return AlertDialog(
      title: Text(isEdit ? 'Modifier le chauffeur' : 'Ajouter un chauffeur'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Courriel'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Requis';
                  if (!value.contains('@')) return 'Email invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _hidePassword,
                decoration: InputDecoration(
                  labelText: isEdit
                      ? 'Mot de passe (laisser vide pour ne pas changer)'
                      : 'Mot de passe',
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                      _hidePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (!isEdit && value.isEmpty) return 'Requis';
                  if (value.isNotEmpty && value.length < 6) {
                    return 'Min 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cniController,
                decoration: const InputDecoration(labelText: 'CNI'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _permisController,
                decoration: const InputDecoration(labelText: 'Permis'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _camionIdController,
                decoration: const InputDecoration(labelText: 'ID camion'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty && !isEdit) return 'Requis';
                  if (value.isNotEmpty && int.tryParse(value) == null) {
                    return 'Doit être un entier';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.close),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(isEdit ? Icons.check : Icons.add),
        ),
      ],
    );
  }
}
