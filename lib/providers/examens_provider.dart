import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shootingscore/models/examen.dart';

class ExamensProvider extends ChangeNotifier {
  List<Examen> _examens = [];
  bool _isLoading = false;
  final String _storageKey = 'examens_data';

  List<Examen> get examens => _examens;
  bool get isLoading => _isLoading;

  ExamensProvider() {
    loadExamens();
  }

  Future<void> loadExamens() async {
    // Si déjà en cours de chargement, ne pas relancer
    if (_isLoading) {
      debugPrint('=== LOAD EXAMENS: Déjà en cours de chargement, attente...');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('=== LOAD EXAMENS: Début du chargement des examens');
      final prefs = await SharedPreferences.getInstance();
      final String? examensJson = prefs.getString(_storageKey);

      if (examensJson != null) {
        debugPrint(
          '=== LOAD EXAMENS: Données JSON trouvées dans SharedPreferences',
        );
        final List<dynamic> decoded = jsonDecode(examensJson);
        _examens = decoded.map((item) => Examen.fromJson(item)).toList();
        debugPrint(
          '=== LOAD EXAMENS: ${_examens.length} examens chargés: ${_examens.map((e) => e.id).join(', ')}',
        );
      } else {
        debugPrint(
          '=== LOAD EXAMENS: Aucune donnée trouvée dans SharedPreferences',
        );
      }

      // Si aucun examen n'est présent, ajouter l'exercice par défaut "PA"
      if (_examens.isEmpty) {
        debugPrint('=== LOAD EXAMENS: Création de l\'examen par défaut "PA"');
        final examenPA = Examen(
          id: 'pa-default',
          nom: 'PA',
          nombreDeTirs: 4,
          pointsMinPourValidation: 45,
        );
        _examens.add(examenPA);
        saveExamens(); // Sauvegarder l'exercice par défaut
        debugPrint(
          '=== LOAD EXAMENS: Examen par défaut PA créé avec ID: ${examenPA.id}',
        );
      }
    } catch (e) {
      debugPrint('=== ERROR loading examens: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint(
        '=== LOAD EXAMENS: Chargement terminé avec ${_examens.length} examens disponibles',
      );
    }
  }

  Future<void> saveExamens() async {
    try {
      debugPrint('=== SAVE EXAMENS: Sauvegarde de ${_examens.length} examens');
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        _examens.map((examen) => examen.toJson()).toList(),
      );
      await prefs.setString(_storageKey, encoded);
      debugPrint(
        '=== SAVE EXAMENS: Sauvegarde réussie, IDs: ${_examens.map((e) => e.id).join(', ')}',
      );
    } catch (e) {
      debugPrint('=== ERROR saving examens: $e');
    }
  }

  void addExamen(Examen examen) {
    _examens.add(examen);
    notifyListeners();
    saveExamens();
  }

  void updateExamen(Examen updatedExamen) {
    final index = _examens.indexWhere(
      (examen) => examen.id == updatedExamen.id,
    );

    if (index != -1) {
      _examens[index] = updatedExamen;
      notifyListeners();
      saveExamens();
    }
  }

  void removeExamen(String id) {
    _examens.removeWhere((examen) => examen.id == id);
    notifyListeners();
    saveExamens();
  }

  Examen? getExamenById(String id) {
    try {
      return _examens.firstWhere((examen) => examen.id == id);
    } catch (e) {
      return null;
    }
  }
}
