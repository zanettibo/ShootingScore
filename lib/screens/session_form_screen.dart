import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shootingscore/models/examen.dart';
import 'package:shootingscore/models/session.dart';
import 'package:shootingscore/providers/examens_provider.dart';
import 'package:shootingscore/providers/participants_provider.dart';
import 'package:shootingscore/providers/sessions_provider.dart';
import 'package:uuid/uuid.dart';

class SessionFormScreen extends StatefulWidget {
  final Session? session;

  const SessionFormScreen({super.key, this.session});

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  String? _selectedExamenId;
  final Set<String> _selectedParticipantIds = {};

  bool _isEditing = false;
  late String _sessionId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.session != null;

    if (_isEditing) {
      _sessionId = widget.session!.id;
      _nomController.text = widget.session!.nom;
      _selectedExamenId = widget.session!.examen.id;
      _selectedParticipantIds.addAll(widget.session!.participantIds);
      _date = widget.session!.date;
    } else {
      _sessionId = const Uuid().v4();
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  void _saveSession() {
    if (_formKey.currentState!.validate() && _selectedExamenId != null) {
      final sessionsProvider = Provider.of<SessionsProvider>(
        context,
        listen: false,
      );

      final examensProvider = Provider.of<ExamensProvider>(
        context,
        listen: false,
      );

      final examen = examensProvider.getExamenById(_selectedExamenId!);

      if (examen == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Examen introuvable')),
        );
        return;
      }

      final session = Session(
        id: _sessionId,
        nom: _nomController.text,
        date: _date,
        examen: examen,
        participantIds: _selectedParticipantIds.toList(),
        scores: _isEditing ? widget.session!.scores : {},
      );

      if (_isEditing) {
        sessionsProvider.updateSession(session);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Session mise à jour!')));
        Navigator.of(context).pop();
      } else {
        sessionsProvider.addSession(session);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Session créée!')));
      }

      Navigator.of(context).pop();
    } else if (_selectedExamenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un examen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final examensProvider = Provider.of<ExamensProvider>(context);
    final participantsProvider = Provider.of<ParticipantsProvider>(context);

    if (examensProvider.isLoading || participantsProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Modifier la session' : 'Créer une session'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la session' : 'Créer une session'),
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
                    labelText: 'Nom de la session',
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
                _buildDatePicker(),
                const SizedBox(height: 16.0),
                _buildExamenDropdown(examensProvider),
                const SizedBox(height: 24.0),
                const Text(
                  'Participants',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                _buildParticipantsList(participantsProvider),
                const SizedBox(height: 16.0),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveSession,
                      child: Text(
                        _isEditing ? 'Mettre à jour' : 'Créer la session',
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

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final newDate = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );

        if (newDate != null) {
          setState(() {
            _date = newDate;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date: ${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildExamenDropdown(ExamensProvider examensProvider) {
    final examens = examensProvider.examens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Sélectionnez un examen'),
          value: _selectedExamenId,
          items: examens.map((Examen examen) {
            return DropdownMenuItem<String>(
              value: examen.id,
              child: Text(
                '${examen.nom} (${examen.nombreDeTirs} tirs, ${examen.pointsMinPourValidation} points min)',
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedExamenId = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildParticipantsList(ParticipantsProvider participantsProvider) {
    final participants = participantsProvider.participants;

    if (participants.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Aucun participant disponible. Veuillez créer des participants.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: participants.length,
        itemBuilder: (context, index) {
          final participant = participants[index];
          final isSelected = _selectedParticipantIds.contains(participant.id);

          return CheckboxListTile(
            title: Text('${participant.prenom} ${participant.nom}'),
            subtitle: Text('Grade: ${participant.grade}'),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedParticipantIds.add(participant.id);
                } else {
                  _selectedParticipantIds.remove(participant.id);
                }
              });
            },
          );
        },
      ),
    );
  }
}
