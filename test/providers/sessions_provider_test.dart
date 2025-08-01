import 'package:flutter_test/flutter_test.dart';
import 'package:shootingscore/models/examen.dart';
import 'package:shootingscore/models/participant.dart';
import 'package:shootingscore/models/session.dart';
import 'package:shootingscore/providers/examens_provider.dart';
import 'package:shootingscore/providers/participants_provider.dart';
import 'package:shootingscore/providers/sessions_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/test_helpers.dart';

void main() {
  // Initialiser le binding Flutter pour permettre l'utilisation de SharedPreferences
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Configuration du mock pour SharedPreferences
    SharedPreferences.setMockInitialValues({});
    await TestHelpers.setUpSharedPreferences();
  });
  group('SessionsProvider Tests', () {
    late ExamensProvider mockExamensProvider;
    late ParticipantsProvider mockParticipantsProvider;
    late SessionsProvider sessionsProvider;

    setUp(() {
      // Initialiser les providers et les données de test avant chaque test
      mockExamensProvider = ExamensProvider();
      mockParticipantsProvider = ParticipantsProvider();

      // Créer l'examen et les participants de test
      final examen = Examen(
        id: 'exam1',
        nom: 'Examen Test',
        nombreDeTirs: 5,
        pointsMinPourValidation: 45,
      );

      final participant1 = Participant(
        id: 'part1',
        nom: 'Dupont',
        prenom: 'Jean',
        grade: 'Lieutenant',
      );

      final participant2 = Participant(
        id: 'part2',
        nom: 'Martin',
        prenom: 'Sophie',
        grade: 'Capitaine',
      );

      // Ajouter aux providers
      mockExamensProvider.addExamen(examen);
      mockParticipantsProvider.addParticipant(participant1);
      mockParticipantsProvider.addParticipant(participant2);

      // Initialiser le SessionsProvider avec le mock ExamensProvider uniquement
      sessionsProvider = SessionsProvider(mockExamensProvider);
    });

    test('addSession should add a new session', () {
      final examen = mockExamensProvider.examens.first;
      final testDate = DateTime(2025, 7, 1);

      // Créer une session
      final session = Session(
        id: 'session1',
        nom: 'Session de Test',
        date: testDate,
        examen: examen,
        participantIds: ['part1', 'part2'],
        scores: {},
      );

      sessionsProvider.addSession(session);

      // Vérifier que la session a été ajoutée
      expect(sessionsProvider.sessions.length, equals(1));
      expect(sessionsProvider.sessions.first.nom, equals('Session de Test'));
      expect(sessionsProvider.sessions.first.date, equals(testDate));
      expect(sessionsProvider.sessions.first.examen.id, equals(examen.id));
      expect(sessionsProvider.sessions.first.participantIds.length, equals(2));
    });

    test('updateSession should modify an existing session', () {
      final examen = mockExamensProvider.examens.first;
      final testDate = DateTime(2025, 7, 1);

      // Créer une session initiale
      final session = Session(
        id: 'session1',
        nom: 'Session de Test',
        date: testDate,
        examen: examen,
        participantIds: ['part1', 'part2'],
        scores: {},
      );

      sessionsProvider.addSession(session);

      // Créer une version modifiée de la session
      final newDate = DateTime(2025, 7, 15);
      final updatedSession = Session(
        id: 'session1',
        nom: 'Session Modifiée',
        date: newDate,
        examen: examen,
        participantIds: ['part1'], // Réduire à un seul participant
        scores: {},
      );

      // Mettre à jour la session
      sessionsProvider.updateSession(updatedSession);

      // Vérifier les modifications
      expect(sessionsProvider.sessions.first.nom, equals('Session Modifiée'));
      expect(sessionsProvider.sessions.first.date, equals(newDate));
      expect(sessionsProvider.sessions.first.participantIds.length, equals(1));
    });

    test('deleteSession should remove a session', () {
      final examen = mockExamensProvider.examens.first;
      final testDate = DateTime(2025, 7, 1);

      // Créer une session
      final session = Session(
        id: 'session1',
        nom: 'Session de Test',
        date: testDate,
        examen: examen,
        participantIds: ['part1', 'part2'],
        scores: {},
      );

      sessionsProvider.addSession(session);

      // Supprimer la session
      sessionsProvider.removeSession(
        session.id,
      ); // Utiliser la méthode correcte

      // Vérifier que la session a été supprimée
      expect(sessionsProvider.sessions.length, equals(0));
    });

    test('addScore should add a score to a session', () {
      final examen = mockExamensProvider.examens.first;
      final testDate = DateTime(2025, 7, 1);

      // Créer une session
      final session = Session(
        id: 'session1',
        nom: 'Session de Test',
        date: testDate,
        examen: examen,
        participantIds: ['part1'],
        scores: {},
      );

      sessionsProvider.addSession(session);

      // Créer un score
      final score = Score();
      // Modifier quelques valeurs
      score.shots[0].enZone = 2; // +10 points
      score.shots[1].horsTemps = true; // -5 points

      // Ajouter le score à la session
      final updatedSession = session.copyWith(
        scores: {
          ...session.scores,
          'part1': [score],
        },
      );

      sessionsProvider.updateSession(updatedSession);

      // Vérifier que le score a été ajouté
      expect(
        sessionsProvider.sessions.first.scores.containsKey('part1'),
        isTrue,
      );
      expect(
        sessionsProvider.sessions.first.scores['part1']?.length,
        equals(1),
      );
      expect(
        sessionsProvider.sessions.first.scores['part1']?[0].totalScore,
        equals(5),
      ); // 10-5=5
    });
  });
}
