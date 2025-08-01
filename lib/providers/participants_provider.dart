import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shootingscore/models/participant.dart';

class ParticipantsProvider extends ChangeNotifier {
  List<Participant> _participants = [];
  bool _isLoading = false;
  final String _storageKey = 'participants_data';

  List<Participant> get participants => _participants;
  bool get isLoading => _isLoading;

  ParticipantsProvider() {
    loadParticipants();
  }

  Future<void> loadParticipants() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? participantsJson = prefs.getString(_storageKey);

      if (participantsJson != null) {
        final List<dynamic> decoded = jsonDecode(participantsJson);
        _participants = decoded
            .map((item) => Participant.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading participants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveParticipants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        _participants.map((participant) => participant.toJson()).toList(),
      );
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving participants: $e');
    }
  }

  void addParticipant(Participant participant) {
    _participants.add(participant);
    notifyListeners();
    saveParticipants();
  }

  void updateParticipant(Participant updatedParticipant) {
    final index = _participants.indexWhere(
      (participant) => participant.id == updatedParticipant.id,
    );

    if (index != -1) {
      _participants[index] = updatedParticipant;
      notifyListeners();
      saveParticipants();
    }
  }

  void removeParticipant(String id) {
    _participants.removeWhere((participant) => participant.id == id);
    notifyListeners();
    saveParticipants();
  }

  // Note: Les méthodes de gestion de scores ont été déplacées dans SessionsProvider
  // car les scores sont maintenant gérés par session et non par participant

  // Récupérer un participant par son id
  Participant? getParticipantById(String id) {
    try {
      return _participants.firstWhere((participant) => participant.id == id);
    } catch (e) {
      return null;
    }
  }
}
