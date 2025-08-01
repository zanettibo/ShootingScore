import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shootingscore/models/participant.dart';
import 'package:shootingscore/models/session.dart';
import 'package:shootingscore/providers/participants_provider.dart';
import 'package:shootingscore/providers/sessions_provider.dart';
import 'package:shootingscore/screens/score_history_screen.dart';

class ParticipantFormScreen extends StatefulWidget {
  final Participant? participant;

  const ParticipantFormScreen({super.key, this.participant});

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
                const Text(
                  'Informations du Stagiaire',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SizedBox(
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
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  _buildSessionResultsTable(),
                  const SizedBox(height: 24),
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
      ),
    );
  }

  void _saveParticipant() {
    if (_formKey.currentState!.validate()) {
      final participantsProvider = Provider.of<ParticipantsProvider>(
        context,
        listen: false,
      );

      if (_isEditing) {
        // Update existing participant
        final updatedParticipant = Participant(
          id: widget.participant!.id,
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          grade: _gradeController.text.trim(),
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

  Widget _buildSessionResultsTable() {
    if (!_isEditing) return const SizedBox.shrink();

    final sessionsProvider = Provider.of<SessionsProvider>(context);
    final allScores = sessionsProvider.getAllSessionScoresForParticipant(
      widget.participant!.id,
    );

    if (allScores.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Résultats des sessions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Aucun résultat disponible pour ce participant'),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Résultats des sessions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Session')),
                DataColumn(label: Text('Examen')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Score')),
                DataColumn(label: Text('Résultat')),
                DataColumn(label: Text('Actions')),
              ],
              rows: allScores.map((scoreData) {
                final session = scoreData['session'] as Session;
                final score = scoreData['score'] as Score;
                final isPass =
                    score.totalScore >= 45; // Seuil de réussite défini à 45

                return DataRow(
                  cells: [
                    DataCell(Text(session.nom)),
                    DataCell(Text(session.examen.nom)),
                    DataCell(Text(_formatDate(session.date))),
                    DataCell(
                      Text(
                        '${score.totalScore} points',
                        style: TextStyle(
                          color: isPass ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPass
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isPass ? 'RÉUSSITE' : 'ÉCHEC',
                          style: TextStyle(
                            color: isPass
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      TextButton(
                        child: const Text('Détails'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ScoreHistoryScreen(
                                participant: widget.participant!,
                                session: session,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer Stagiaire'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${widget.participant!.prenom} ${widget.participant!.nom}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ParticipantsProvider>(
                context,
                listen: false,
              ).removeParticipant(widget.participant!.id);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
