import 'package:flutter_test/flutter_test.dart';
import 'package:shootingscore/models/participant.dart';

void main() {
  group('Participant Model Tests', () {
    test('Participant creation test', () {
      final participant = Participant(
        id: 'part1',
        nom: 'Dupont',
        prenom: 'Jean',
        grade: 'Lieutenant',
      );

      expect(participant.id, equals('part1'));
      expect(participant.nom, equals('Dupont'));
      expect(participant.prenom, equals('Jean'));
      expect(participant.grade, equals('Lieutenant'));
    });

    test('Participant toJson/fromJson serialization', () {
      // Créer un participant de test
      final originalParticipant = Participant(
        id: 'part1',
        nom: 'Dupont',
        prenom: 'Jean',
        grade: 'Lieutenant',
      );

      // Sérialiser et désérialiser
      final json = originalParticipant.toJson();
      final deserializedParticipant = Participant.fromJson(json);

      // Vérifier que les données correspondent
      expect(deserializedParticipant.id, equals(originalParticipant.id));
      expect(deserializedParticipant.nom, equals(originalParticipant.nom));
      expect(
        deserializedParticipant.prenom,
        equals(originalParticipant.prenom),
      );
      expect(deserializedParticipant.grade, equals(originalParticipant.grade));
    });

    test('ShotRecord creation and serialization', () {
      final shotRecord = ShotRecord(
        horsZone: 1,
        horsTemps: false,
        manoeuvreDangereuse: false,
        enZone: 2,
      );

      expect(shotRecord.horsZone, equals(1));
      expect(shotRecord.horsTemps, equals(false));
      expect(shotRecord.manoeuvreDangereuse, equals(false));
      expect(shotRecord.enZone, equals(2));

      // Test de conversion en JSON
      final json = shotRecord.toJson();
      expect(json['horsZone'], equals(1));
      expect(json['horsTemps'], equals(false));
      expect(json['manoeuvreDangereuse'], equals(false));
      expect(json['enZone'], equals(2));

      // Test de création depuis JSON
      final deserializedShotRecord = ShotRecord.fromJson(json);
      expect(deserializedShotRecord.horsZone, equals(shotRecord.horsZone));
      expect(deserializedShotRecord.horsTemps, equals(shotRecord.horsTemps));
      expect(
        deserializedShotRecord.manoeuvreDangereuse,
        equals(shotRecord.manoeuvreDangereuse),
      );
      expect(deserializedShotRecord.enZone, equals(shotRecord.enZone));
    });

    test('Score creation and calculation', () {
      final score = Score();

      // Par défaut, tous les shots sont à 0
      expect(score.shots.length, equals(5));
      expect(score.totalScore, equals(0));

      // Modification de quelques valeurs
      score.shots[0].enZone = 1; // +5 points
      score.shots[1].horsTemps = true; // -5 points
      score.shots[2].enZone = 2; // +10 points
      score.shots[3].manoeuvreDangereuse = true; // -5 points
      score.shots[4].horsZone = 2; // -10 points

      // Calcul du score total: 5 - 5 + 10 - 5 - 10 = -5
      expect(score.totalScore, equals(-5));

      // Test des propriétés isLowScore et isHighScore
      expect(score.isLowScore, isTrue);
      expect(score.isHighScore, isFalse);

      // Test de conversion en JSON
      final json = score.toJson();
      expect(json['shots'], isNotNull);
      expect(json['shots'].length, equals(5));

      // Test de création depuis JSON
      final deserializedScore = Score.fromJson(json);
      expect(deserializedScore.shots.length, equals(5));
      expect(deserializedScore.shots[0].enZone, equals(1));
      expect(deserializedScore.shots[1].horsTemps, isTrue);
      expect(deserializedScore.shots[2].enZone, equals(2));
      expect(deserializedScore.shots[3].manoeuvreDangereuse, isTrue);
      expect(deserializedScore.shots[4].horsZone, equals(2));
      expect(deserializedScore.totalScore, equals(-5));
    });
  });
}
