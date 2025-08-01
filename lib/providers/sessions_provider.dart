import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shootingscore/models/examen.dart';
import 'package:shootingscore/models/session.dart';
import 'package:shootingscore/models/participant.dart'; // Ajout de l'import pour Score
import 'package:shootingscore/providers/examens_provider.dart';

class SessionsProvider extends ChangeNotifier {
  List<Session> _sessions = [];
  bool _isLoading = false;
  final String _storageKey = 'sessions_data';
  final ExamensProvider _examensProvider;

  List<Session> get sessions => _sessions;
  bool get isLoading => _isLoading;

  // TODO: Amélioration future - Remplacer le délai fixe par une solution plus élégante:
  // 1. Utiliser un pattern async/await structuré avec des Futures
  // 2. Implémenter un système d'événements où ExamensProvider émettrait
  //    un événement "chargement terminé" que SessionsProvider écouterait
  //    (pattern Observer ou EventBus)
  SessionsProvider(this._examensProvider) {
    // Attendre que les examens soient chargés avant de charger les sessions
    // Ce délai est nécessaire pour éviter les conditions de course
    Future.delayed(Duration(milliseconds: 500), () {
      loadSessions();
    });
  }

  Future<void> loadSessions() async {
    debugPrint('=== LOAD SESSIONS: Début du chargement des sessions');
    _isLoading = true;
    notifyListeners();

    try {
      // Attendre que tous les examens soient chargés avant de charger les sessions
      debugPrint(
        '=== LOAD SESSIONS: Vérification de la disponibilité des examens',
      );
      final examens = _examensProvider.examens;
      debugPrint(
        '=== LOAD SESSIONS: ${examens.length} examens disponibles: ${examens.map((e) => e.id).join(', ')}',
      );

      final prefs = await SharedPreferences.getInstance();
      final String? sessionsJson = prefs.getString(_storageKey);

      if (sessionsJson != null) {
        debugPrint(
          '=== LOAD SESSIONS: Données JSON trouvées dans SharedPreferences (${sessionsJson.length} caractères)',
        );
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        debugPrint('=== LOAD SESSIONS: ${decoded.length} sessions à charger');
        _sessions = [];

        for (var item in decoded) {
          String examenId = item['examenId'];
          debugPrint(
            '=== LOAD SESSIONS: Chargement session avec examenId: $examenId',
          );
          Examen? examen = _examensProvider.getExamenById(examenId);

          if (examen != null) {
            final session = Session.fromJson(item, examen);
            _sessions.add(session);
            debugPrint(
              '=== LOAD SESSIONS: Session ${session.id} chargée avec succès',
            );
            // Afficher des informations sur les participants et scores de cette session
            if (item['participantIds'] != null) {
              debugPrint(
                '=== LOAD SESSIONS: Session contient ${(item['participantIds'] as List).length} participants',
              );
            }
          } else {
            debugPrint(
              '=== LOAD SESSIONS ERROR: Examen non trouvé pour la session avec examenId: $examenId',
            );
          }
        }

        debugPrint(
          '=== LOAD SESSIONS: ${_sessions.length} sessions chargées avec succès',
        );
      } else {
        debugPrint(
          '=== LOAD SESSIONS: Aucune donnée de session trouvée dans SharedPreferences',
        );
      }
    } catch (e) {
      debugPrint('=== LOAD SESSIONS ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('=== LOAD SESSIONS: Chargement terminé');
    }
  }

  Future<void> saveSessions() async {
    try {
      debugPrint(
        '=== SAVE SESSIONS: Preparing to save ${_sessions.length} sessions',
      );
      final prefs = await SharedPreferences.getInstance();

      final jsonList = _sessions.map((session) {
        final json = session.toJson();
        debugPrint(
          '=== SAVE SESSIONS: Session ${session.id} JSON: participants=${json["participantIds"]}?.length}, scores=${json["scores"]}?.length}',
        );
        return json;
      }).toList();

      final String encoded = jsonEncode(jsonList);
      debugPrint('=== SAVE SESSIONS: Encoded JSON length: ${encoded.length}');

      // Utiliser setString et s'assurer que l'opération est bien terminée
      bool success = await prefs.setString(_storageKey, encoded);
      debugPrint('=== SAVE SESSIONS: Save successful: $success');

      // Forcer le flush pour s'assurer que les données sont bien écrites sur le disque
      // Particulièrement important sur Android/iOS
      try {
        await prefs.reload();
        final verif = prefs.getString(_storageKey);
        debugPrint(
          '=== SAVE SESSIONS: Verification - data exists in prefs: ${verif != null && verif.isNotEmpty}',
        );
      } catch (e) {
        debugPrint('=== SAVE SESSIONS: Error during verification: $e');
      }
    } catch (e) {
      debugPrint('=== ERROR saving sessions: $e');
    }
  }

  void addSession(Session session) {
    _sessions.add(session);
    notifyListeners();
    saveSessions();
  }

  void updateSession(Session updatedSession) {
    final index = _sessions.indexWhere(
      (session) => session.id == updatedSession.id,
    );

    if (index != -1) {
      _sessions[index] = updatedSession;
      notifyListeners();
      saveSessions();
    }
  }

  void removeSession(String id) {
    _sessions.removeWhere((session) => session.id == id);
    notifyListeners();
    saveSessions();
  }

  Session? getSessionById(String id) {
    try {
      return _sessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  // Ajouter un score à un participant dans une session
  void addScoreToParticipant(
    String sessionId,
    String participantId,
    Score score,
  ) {
    final sessionIndex = _sessions.indexWhere(
      (session) => session.id == sessionId,
    );

    if (sessionIndex != -1) {
      _sessions[sessionIndex].addScore(participantId, score);
      notifyListeners();
      saveSessions();
    }
  }

  // Récupérer les scores d'un participant pour une session spécifique
  List<Score>? getParticipantScores(String sessionId, String participantId) {
    final session = getSessionById(sessionId);
    if (session != null && session.scores.containsKey(participantId)) {
      return session.scores[participantId];
    }
    return null;
  }

  // Vérifier si un participant a été évalué dans une session
  bool isParticipantEvaluated(String sessionId, String participantId) {
    final scores = getParticipantScores(sessionId, participantId);
    return scores != null && scores.isNotEmpty;
  }

  /// Récupère tous les scores d'un participant dans toutes les sessions.
  ///
  /// Retourne une liste de maps contenant la session et le score correspondant.
  /// Les résultats sont triés du plus récent au plus ancien (ordre chronologique inversé).
  ///
  /// @param participantId Identifiant du participant
  /// @return Liste de maps {session, score} ou liste vide si aucun résultat
  List<Map<String, dynamic>> getAllSessionScoresForParticipant(
    String participantId,
  ) {
    List<Map<String, dynamic>> results = [];

    for (var session in _sessions) {
      if (session.scores.containsKey(participantId) &&
          session.scores[participantId]!.isNotEmpty) {
        for (var score in session.scores[participantId]!) {
          results.add({
            'session': session,
            'score': score,
            'date': session.date, // Pour faciliter le tri
          });
        }
      }
    }

    // Tri par date décroissante (du plus récent au plus ancien)
    results.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    return results;
  }
}
