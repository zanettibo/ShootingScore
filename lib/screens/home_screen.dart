import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shootingscore/models/participant.dart';
import 'package:shootingscore/providers/participants_provider.dart';
import 'package:shootingscore/screens/participant_form_screen.dart';
import 'package:shootingscore/screens/score_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scores de Tir'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<ParticipantsProvider>(
        builder: (context, participantsProvider, child) {
          if (participantsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (participantsProvider.participants.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun stagiaire enregistré',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un stagiaire'),
                      onPressed: () => _navigateToAddParticipant(context),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Liste des Stagiaires',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: participantsProvider.participants.length,
                    itemBuilder: (context, index) {
                      final participant = participantsProvider.participants[index];
                      return ParticipantCard(participant: participant);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddParticipant(context),
        tooltip: 'Ajouter un stagiaire',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddParticipant(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ParticipantFormScreen(),
      ),
    );
  }
}

class ParticipantCard extends StatelessWidget {
  final Participant participant;

  const ParticipantCard({
    super.key,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate average score if there are scores available
    final hasScores = participant.scores.isNotEmpty;
    final latestScore = hasScores ? participant.scores.last : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ScoreEntryScreen(participant: participant),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${participant.prenom} ${participant.nom}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Grade: ${participant.grade}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (latestScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: latestScore.isLowScore
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Score: ${latestScore.totalScore}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: latestScore.isLowScore ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sessions: ${participant.scores.length}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ScoreEntryScreen(participant: participant),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Saisir scores'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
