import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shootingscore/models/participant.dart';
import 'package:shootingscore/providers/participants_provider.dart';

class ParticipantFormScreen extends StatefulWidget {
  final Participant? participant;

  const ParticipantFormScreen({
    super.key,
    this.participant,
  });

  @override
  State<ParticipantFormScreen> createState() => _ParticipantFormScreenState();
}

class _ParticipantFormScreenState extends State<ParticipantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _gradeController = TextEditingController();

  bool get _isEditing => widget.participant != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nomController.text = widget.participant!.nom;
      _prenomController.text = widget.participant!.prenom;
      _gradeController.text = widget.participant!.grade;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier Stagiaire' : 'Ajouter Stagiaire'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informations du Stagiaire',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer le nom';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer le prénom';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gradeController,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.military_tech),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer le grade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveParticipant,
                  child: Text(
                    _isEditing ? 'Mettre à jour' : 'Enregistrer',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _confirmDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Supprimer',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveParticipant() {
    if (_formKey.currentState!.validate()) {
      final participantsProvider =
          Provider.of<ParticipantsProvider>(context, listen: false);

      if (_isEditing) {
        // Update existing participant
        final updatedParticipant = Participant(
          id: widget.participant!.id,
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          grade: _gradeController.text.trim(),
          scores: widget.participant!.scores,
        );
        participantsProvider.updateParticipant(updatedParticipant);
      } else {
        // Create a new participant
        final newParticipant = Participant(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          grade: _gradeController.text.trim(),
        );
        participantsProvider.addParticipant(newParticipant);
      }
      Navigator.of(context).pop();
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer Stagiaire'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer ${widget.participant!.prenom} ${widget.participant!.nom}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ParticipantsProvider>(context, listen: false)
                  .removeParticipant(widget.participant!.id);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
