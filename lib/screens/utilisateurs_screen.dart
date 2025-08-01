import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shootingscore/models/participant.dart';
import 'package:shootingscore/models/session.dart';
import 'package:shootingscore/providers/participants_provider.dart';
import 'package:shootingscore/providers/sessions_provider.dart';
import 'package:shootingscore/screens/participant_form_screen.dart';

class UtilisateursScreen extends StatelessWidget {
  const UtilisateursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ParticipantsProvider>(
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
                    'Aucun utilisateur enregistré',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un utilisateur'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ParticipantFormScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          bottom:
              true, // Important pour éviter la superposition avec les boutons Android
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Liste des Utilisateurs',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ParticipantFormScreen(),
                          ),
                        );
                      },
                      tooltip: 'Ajouter un utilisateur',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: participantsProvider.participants.length,
                    itemBuilder: (context, index) {
                      final participant =
                          participantsProvider.participants[index];
                      return _buildParticipantCard(
                        context,
                        participant,
                        participantsProvider,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticipantCard(
    BuildContext context,
    Participant participant,
    ParticipantsProvider provider,
  ) {
    final sessionsProvider = Provider.of<SessionsProvider>(context);
    final allScores = sessionsProvider.getAllSessionScoresForParticipant(
      participant.id,
    );

    // Calculate average score if there are scores available
    final hasScores = allScores.isNotEmpty;
    final latestScoreData = hasScores ? allScores.last : null;
    final latestScore = latestScoreData != null
        ? latestScoreData['score'] as Score
        : null;
    final latestSession = latestScoreData != null
        ? latestScoreData['session'] as Session
        : null;

    return Dismissible(
      key: Key(participant.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Voulez-vous vraiment supprimer cet utilisateur ?',
            ),
            actions: [
              TextButton(
                child: const Text('Non'),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              TextButton(
                child: const Text('Oui'),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        provider.removeParticipant(participant.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Utilisateur supprimé')));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ParticipantFormScreen(participant: participant),
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
                    if (latestScore != null && latestSession != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: latestScore.isLowScore
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Score: ${latestScore.totalScore} pts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: latestScore.isLowScore
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              latestSession.examen.nom,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${latestSession.date.day.toString().padLeft(2, "0")}/${latestSession.date.month.toString().padLeft(2, "0")}/${latestSession.date.year}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Sessions: ${allScores.length}',
                  style: const TextStyle(color: Colors.grey),
                ),
                if (hasScores && latestSession != null)
                  Text(
                    'Dernière évaluation: ${latestSession.nom}',
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
