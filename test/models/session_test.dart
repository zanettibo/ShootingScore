import 'package:flutter_test/flutter_test.dart';
import 'package:shootingscore/models/examen.dart';
import 'package:shootingscore/models/participant.dart';
import 'package:shootingscore/models/session.dart';

void main() {
  group('Session Model Tests', () {
    // Données de test
    final examen = Examen(
      id: 'exam1',
      nom: 'Examen Standard',
      nombreDeTirs: 5,
      pointsMinPourValidation: 45,
    );

    final testDate = DateTime(2025, 7, 1);

    test('Session creation test', () {
      final session = Session(
        id: 'session1',
        nom: 'Session de Test',
        date: testDate,
        examen: examen,
        participantIds: ['part1', 'part2'],
        scores: {},
      );

      expect(session.id, equals('session1'));
      expect(session.nom, equals('Session de Test'));
      expect(session.date, equals(testDate));
      expect(session.examen, equals(examen));
      expect(session.participantIds, contains('part1'));
      expect(session.participantIds.length, equals(2));
      expect(session.status, equals(SessionStatus.enCours));
    });

    test('Session toJson/fromJson serialization', () {
      // Créer une session de test avec quelques scores
      final score1 = Score();
      final score2 = Score();

      // Modifier les valeurs des scores pour les tests
      score1.shots[0].enZone = 2; // 10 points
      score1.shots[1].enZone = 1; // 5 points

      score2.shots[0].enZone = 1; // 5 points
      score2.shots[0].horsTemps = true; // -5 points

      final originalSession = Session(
        id: 'session1',
        nom: 'Session de Test',
        date: testDate,
        examen: examen,
        participantIds: ['part1', 'part2'],
        scores: {
          'part1': [score1, score2],
        },
        status: SessionStatus.termine,
      );

      // Sérialiser et désérialiser
      final json = originalSession.toJson();
      final deserializedSession = Session.fromJson(json, examen);

      // Vérifier que les données correspondent
      expect(deserializedSession.id, equals(originalSession.id));
      expect(deserializedSession.nom, equals(originalSession.nom));
      expect(deserializedSession.date.year, equals(originalSession.date.year));
      expect(
        deserializedSession.date.month,
        equals(originalSession.date.month),
      );
      expect(deserializedSession.date.day, equals(originalSession.date.day));
      expect(
        deserializedSession.participantIds,
        equals(originalSession.participantIds),
      );
      expect(deserializedSession.status, equals(originalSession.status));

      // Vérifier les scores
      expect(deserializedSession.scores.containsKey('part1'), isTrue);
      expect(deserializedSession.scores['part1']?.length, equals(2));
    });

    test('Session score calculation', () {
      // Créer des scores pour les tests
      final score1 = Score();
      final score2 = Score();
      final score3 = Score();

      // Premier score: +15 points (3 zones touchées)
      score1.shots[0].enZone = 1;
      score1.shots[1].enZone = 1;
      score1.shots[2].enZone = 1;

      // Deuxième score: +5 -5 = 0 points (1 zone touchée, 1 hors temps)
      score2.shots[0].enZone = 1;
      score2.shots[1].horsTemps = true;

      // Troisième score: +10 -5 = 5 points (1 zone touchée de valeur 2, 1 manoeuvre dangereuse)
      score3.shots[0].enZone = 2;
      score3.shots[1].manoeuvreDangereuse = true;

      final session = Session(
        id: 'session1',
        nom: 'Session de Test',
        date: testDate,
        examen: examen,
        participantIds: ['part1', 'part2'],
        scores: {
          'part1': [score1, score2],
          'part2': [score3],
        },
      );

      // Calcul manuel des scores totaux par participant pour vérifier
      // que la structure des scores est correcte
      final part1TotalScore =
          session.scores['part1']?.fold<int>(
            0,
            (sum, score) => sum + score.totalScore,
          ) ??
          0;
      final part2TotalScore =
          session.scores['part2']?.fold<int>(
            0,
            (sum, score) => sum + score.totalScore,
          ) ??
          0;

      expect(part1TotalScore, equals(15));
      expect(part2TotalScore, equals(5));

      // Sinon, on peut tester si les scores individuels se calculent correctement
      expect(score1.totalScore, equals(15));
      expect(score2.totalScore, equals(0));
      expect(score3.totalScore, equals(5));
    });
  });
}
