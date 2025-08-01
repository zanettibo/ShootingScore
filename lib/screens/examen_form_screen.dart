import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shootingscore/models/examen.dart';
import 'package:shootingscore/providers/examens_provider.dart';
import 'package:uuid/uuid.dart';

class ExamenFormScreen extends StatefulWidget {
  final Examen? examen;

  const ExamenFormScreen({super.key, this.examen});

  @override
  State<ExamenFormScreen> createState() => _ExamenFormScreenState();
}

class _ExamenFormScreenState extends State<ExamenFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _nombreTirsController = TextEditingController();
  final _pointsMinController = TextEditingController();

  bool _isEditing = false;
  late String _examenId;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.examen != null;

    if (_isEditing) {
      _examenId = widget.examen!.id;
      _nomController.text = widget.examen!.nom;
      _nombreTirsController.text = widget.examen!.nombreDeTirs.toString();
      _pointsMinController.text = widget.examen!.pointsMinPourValidation
          .toString();
    } else {
      _examenId = const Uuid().v4();
      _nombreTirsController.text = '5'; // Par défaut
      _pointsMinController.text = '45'; // Par défaut
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _nombreTirsController.dispose();
    _pointsMinController.dispose();
    super.dispose();
  }

  void _saveExamen() {
    if (_formKey.currentState!.validate()) {
      final examensProvider = Provider.of<ExamensProvider>(
        context,
        listen: false,
      );

      final examen = Examen(
        id: _examenId,
        nom: _nomController.text,
        nombreDeTirs: int.parse(_nombreTirsController.text),
        pointsMinPourValidation: int.parse(_pointsMinController.text),
      );

      if (_isEditing) {
        examensProvider.updateExamen(examen);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Examen mis à jour!')));
      } else {
        examensProvider.addExamen(examen);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Examen créé!')));
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier un examen' : 'Créer un examen'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        bottom:
            true, // Important pour éviter la superposition avec les boutons Android
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'examen',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _nombreTirsController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de tirs',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nombre de tirs';
                    }
                    final nombreTirs = int.tryParse(value);
                    if (nombreTirs == null || nombreTirs <= 0) {
                      return 'Le nombre de tirs doit être supérieur à 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _pointsMinController,
                  decoration: const InputDecoration(
                    labelText: 'Points minimum pour validation',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nombre de points minimum';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveExamen,
                      child: Text(
                        _isEditing ? 'Mettre à jour' : 'Créer l\'examen',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
