import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/chauffeur_model.dart';
import '../../../models/camion_model.dart';
import '../../../models/user_model.dart';
import '../controllers/chauffeur_controller.dart';

class ChauffeurFormDialog extends StatefulWidget {
  final Chauffeur? chauffeur;

  const ChauffeurFormDialog({super.key, this.chauffeur});

  @override
  State<ChauffeurFormDialog> createState() => _ChauffeurFormDialogState();
}

class _ChauffeurFormDialogState extends State<ChauffeurFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  late final TextEditingController _phoneController;
  late final TextEditingController _cniController;
  late final TextEditingController _permisController;
  late final TextEditingController _camionIdController;
  late final TextEditingController _userIdController;

  @override
  void initState() {
    super.initState();
    _phoneController =
        TextEditingController(text: widget.chauffeur?.numTelephone ?? '');
    _cniController = TextEditingController(text: widget.chauffeur?.cni ?? '');
    _permisController =
        TextEditingController(text: widget.chauffeur?.permis ?? '');
    _camionIdController = TextEditingController(
      text: widget.chauffeur?.camion?.id.toString() ?? '',
    );
    _userIdController = TextEditingController(
      text: widget.chauffeur?.user?.id.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cniController.dispose();
    _permisController.dispose();
    _camionIdController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final camionId = _camionIdController.text.trim().isEmpty
        ? null
        : int.tryParse(_camionIdController.text.trim());
    final userId = _userIdController.text.trim().isEmpty
        ? null
        : int.tryParse(_userIdController.text.trim());
    final controller = Get.find<ChauffeurController>();
    // build objects only if an id was entered
    final camionObj = camionId != null
        ? Camion(id: camionId, immatriculation: '', typeCamion: '', capaciteCamion: 0, status: '')
        : null;
    final userObj = userId != null
        ? User(id: userId, nom: '', prenom: '', email: '', role: '')
        : null;
    setState(() => _saving = true);
    try {
      if (widget.chauffeur == null) {
        await controller.addChauffeur(
          Chauffeur(
            id: 0,
            user: userObj,
            numTelephone: _phoneController.text.trim(),
            cni: _cniController.text.trim(),
            permis: _permisController.text.trim(),
            camion: camionObj,
          ),
        );
      } else {
        await controller.updateChauffeur(
          widget.chauffeur!.id,
          Chauffeur(
            id: widget.chauffeur!.id,
            user: userObj ?? widget.chauffeur!.user,
            numTelephone: _phoneController.text.trim(),
            cni: _cniController.text.trim(),
            permis: _permisController.text.trim(),
            camion: camionObj ?? widget.chauffeur!.camion,
          ),
        );
      }
      Get.back();
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
                controller: _phoneController,
                decoration:
                    const InputDecoration(labelText: 'Numéro de téléphone'),
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
                controller: _userIdController,
                decoration:
                    const InputDecoration(labelText: 'ID utilisateur (optionnel)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (int.tryParse(v.trim()) == null) return 'Doit être un entier';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _camionIdController,
                decoration:
                    const InputDecoration(labelText: 'ID camion (optionnel)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (int.tryParse(v.trim()) == null) return 'Doit être un entier';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
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

