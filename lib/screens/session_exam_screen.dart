import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shootingscore/models/session.dart';
import 'package:shootingscore/providers/participants_provider.dart';
import 'package:shootingscore/providers/sessions_provider.dart';
import 'package:shootingscore/screens/score_entry_screen.dart';
import 'package:shootingscore/screens/score_history_screen.dart';

class SessionExamScreen extends StatefulWidget {
  final Session session;
  final bool isNew;

  const SessionExamScreen({
    super.key,
    required this.session,
    this.isNew = false,
  });

  @override
  State<SessionExamScreen> createState() => _SessionExamScreenState();
}

class _SessionExamScreenState extends State<SessionExamScreen> {
  late Session _session;
  bool _isLoading = false;
  // Suppression de la variable _currentParticipantIndex qui n'est plus nécessaire

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  void _evaluateParticipant(String participantId) {
    // Vérifier le statut de la session
    if (_session.status == SessionStatus.termine ||
        _session.status == SessionStatus.enPause) {
      // Si terminée ou en pause, afficher l'historique
      _showParticipantHistory(participantId);

      // Afficher un message informatif si en pause
      if (_session.status == SessionStatus.enPause) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Session en pause : consultation uniquement. Reprenez la session pour continuer la saisie.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final participantsProvider = Provider.of<ParticipantsProvider>(
      context,
      listen: false,
    );

    final participant = participantsProvider.getParticipantById(participantId);

    if (participant == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Participant introuvable')));
      return;
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                ScoreEntryScreen(participant: participant, session: _session),
          ),
        )
        .then((_) {
          // Rafraîchir la session après le retour de l'écran de score
          _loadSession();
        });
  }

  void _showParticipantHistory(String participantId) {
    final participantsProvider = Provider.of<ParticipantsProvider>(
      context,
      listen: false,
    );

    final participant = participantsProvider.getParticipantById(participantId);

    if (participant == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Participant introuvable')));
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ScoreHistoryScreen(participant: participant, session: _session),
      ),
    );
  }

  void _loadSession() {
    setState(() {
      _isLoading = true;
    });

    final sessionsProvider = Provider.of<SessionsProvider>(
      context,
      listen: false,
    );

    final updatedSession = sessionsProvider.getSessionById(_session.id);
    if (updatedSession != null) {
      setState(() {
        _session = updatedSession;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du chargement de la session'),
        ),
      );
    }
  }

  void _updateSessionStatus(SessionStatus newStatus) {
    setState(() {
      _isLoading = true;
    });

    final sessionsProvider = Provider.of<SessionsProvider>(
      context,
      listen: false,
    );

    final updatedSession = _session.copyWith(status: newStatus);
    sessionsProvider.updateSession(updatedSession);

    setState(() {
      _session = updatedSession;
      _isLoading = false;
    });

    String statusMessage;
    switch (newStatus) {
      case SessionStatus.enCours:
        statusMessage = 'Session en cours';
        break;
      case SessionStatus.enPause:
        statusMessage = 'Session mise en pause';
        break;
      case SessionStatus.termine:
        statusMessage = 'Session terminée';
        break;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(statusMessage)));
  }

  Widget _buildParticipantsList() {
    final participantsProvider = Provider.of<ParticipantsProvider>(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _session.participantIds.length,
      itemBuilder: (context, index) {
        final participantId = _session.participantIds[index];
        final participant = participantsProvider.getParticipantById(
          participantId,
        );

        if (participant == null) {
          return const ListTile(title: Text('Participant introuvable'));
        }

        // Vérifier si le participant a un score dans cette session
        // Rafraîchir depuis la dernière version en mémoire pour éviter les problèmes de cache
        final sessionsProvider = Provider.of<SessionsProvider>(
          context,
          listen: false,
        );
        final latestSessionScores = sessionsProvider.getParticipantScores(
          _session.id,
          participantId,
        );
        final hasScore = latestSessionScores?.isNotEmpty ?? false;
        final latestScore = hasScore ? latestSessionScores?.last : null;
        // Plus de sélection visuelle nécessaire depuis la suppression du bouton

        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide.none,
          ),
          child: ListTile(
            onTap: () {
              // Déclencher directement l'évaluation au clic sur un participant
              _evaluateParticipant(participantId);
            },
            leading: CircleAvatar(
              backgroundColor: hasScore
                  ? (latestScore!.isLowScore ? Colors.red : Colors.green)
                  : Colors.grey,
              child: hasScore
                  ? Icon(
                      latestScore!.isLowScore ? Icons.close : Icons.check,
                      color: Colors.white,
                    )
                  : const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              '${participant.prenom} ${participant.nom}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Grade: ${participant.grade}'),
            trailing: hasScore
                ? Text(
                    '${latestScore!.totalScore} pts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: latestScore.isLowScore ? Colors.red : Colors.green,
                      fontSize: 16,
                    ),
                  )
                : const Text(
                    'Non évalué',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_session.nom),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        bottom:
            true, // Important pour éviter la superposition avec les boutons Android
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Participants (${_session.participantIds.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildParticipantsList(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Examen: ${_session.examen.nom}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${_session.date.day.toString().padLeft(2, '0')}/${_session.date.month.toString().padLeft(2, '0')}/${_session.date.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                _buildStatusBadge(),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  'Nombre de tirs',
                  '${_session.examen.nombreDeTirs}',
                ),
                _buildInfoColumn(
                  'Minimum pour valider',
                  '${_session.examen.pointsMinPourValidation} pts',
                ),
                _buildInfoColumn(
                  'Participants évalués',
                  '${_session.scores.keys.length}/${_session.participantIds.length}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    String statusText;
    IconData icon;

    switch (_session.status) {
      case SessionStatus.enCours:
        backgroundColor = Colors.blue;
        statusText = 'En cours';
        icon = Icons.play_arrow;
        break;
      case SessionStatus.enPause:
        backgroundColor = Colors.orange;
        statusText = 'En pause';
        icon = Icons.pause;
        break;
      case SessionStatus.termine:
        backgroundColor = Colors.green;
        statusText = 'Terminé';
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: backgroundColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: backgroundColor, size: 16),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    // Différentes actions en fonction du statut de la session
    switch (_session.status) {
      case SessionStatus.enCours:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateSessionStatus(SessionStatus.enPause),
                icon: const Icon(Icons.pause),
                label: const Text('Mettre en pause'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _updateSessionStatus(SessionStatus.termine),
                icon: const Icon(Icons.check_circle),
                label: const Text('Terminer la session'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        );

      case SessionStatus.enPause:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateSessionStatus(SessionStatus.enCours),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Reprendre la session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _updateSessionStatus(SessionStatus.termine),
                icon: const Icon(Icons.check_circle),
                label: const Text('Terminer la session'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        );

      case SessionStatus.termine:
        return ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Retourner à la liste des sessions'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );
    }
  }
}
