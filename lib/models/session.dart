import 'package:shootingscore/models/examen.dart';
import 'package:shootingscore/models/participant.dart';

enum SessionStatus { enCours, enPause, termine }

class Session {
  final String id;
  final String nom;
  final DateTime date;
  final Examen examen;
  final List<String> participantIds;
  final Map<String, List<Score>> scores;
  final SessionStatus status;

  const Session({
    required this.id,
    required this.nom,
    required this.date,
    required this.examen,
    required this.participantIds,
    required this.scores,
    this.status = SessionStatus.enCours,
  });

  Map<String, dynamic> toJson() {
    // Convertir les scores en format JSON
    Map<String, List<dynamic>> scoresJson = {};
    scores.forEach((key, value) {
      scoresJson[key] = value.map((score) => score.toJson()).toList();
    });

    return {
      'id': id,
      'nom': nom,
      'date': date.toIso8601String(),
      'examenId': examen.id,
      'participantIds': participantIds,
      'scores': scoresJson,
      'status': status.index,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json, Examen examen) {
    // Convertir les scores du JSON
    Map<String, List<Score>> scoresMap = {};

    if (json['scores'] != null) {
      Map<String, dynamic> scoresJson = json['scores'];
      scoresJson.forEach((key, value) {
        scoresMap[key] = (value as List)
            .map((scoreJson) => Score.fromJson(scoreJson))
            .toList();
      });
    }

    return Session(
      id: json['id'],
      nom: json['nom'],
      date: DateTime.parse(json['date']),
      examen: examen,
      participantIds: List<String>.from(json['participantIds']),
      scores: scoresMap,
      status: json['status'] != null
          ? SessionStatus.values[json['status']]
          : SessionStatus.enCours,
    );
  }

  // Créer une copie de la session avec des valeurs modifiées
  Session copyWith({
    String? id,
    String? nom,
    DateTime? date,
    Examen? examen,
    List<String>? participantIds,
    Map<String, List<Score>>? scores,
    SessionStatus? status,
  }) {
    return Session(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      date: date ?? this.date,
      examen: examen ?? this.examen,
      participantIds: participantIds ?? this.participantIds,
      scores: scores ?? this.scores,
      status: status ?? this.status,
    );
  }

  // Ajouter un participant à la session
  void addParticipant(String participantId) {
    if (!participantIds.contains(participantId)) {
      participantIds.add(participantId);
      scores[participantId] = [];
    }
  }

  // Supprimer un participant de la session
  void removeParticipant(String participantId) {
    participantIds.remove(participantId);
    scores.remove(participantId);
  }

  // Ajouter un score pour un participant
  void addScore(String participantId, Score score) {
    if (participantIds.contains(participantId)) {
      if (!scores.containsKey(participantId)) {
        scores[participantId] = [];
      }
      scores[participantId]?.add(score);
    }
  }
}
