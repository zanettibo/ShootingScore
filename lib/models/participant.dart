class Participant {
  final String id;
  String nom;
  String prenom;
  String grade;
  List<Score> scores;

  Participant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.grade,
    List<Score>? scores,
  }) : scores = scores ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'grade': grade,
      'scores': scores.map((score) => score.toJson()).toList(),
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      grade: json['grade'],
      scores: (json['scores'] as List?)
              ?.map((scoreJson) => Score.fromJson(scoreJson))
              .toList() ??
          [],
    );
  }
}

class ShotRecord {
  // Column: Hors Zone (out of zone) - maintenant un compteur de 0 à 2
  int horsZone;
  
  // Column: Hors temps (out of time)
  bool horsTemps;
  
  // Column: Manoeuvre dangereuse (dangerous maneuver)
  bool manoeuvreDangereuse;
  
  // Column: En Zone (in zone) - value can be 0, 1, 2 (as seen in screenshots)
  int enZone;

  ShotRecord({
    this.horsZone = 0,
    this.horsTemps = false,
    this.manoeuvreDangereuse = false,
    this.enZone = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'horsZone': horsZone,
      'horsTemps': horsTemps,
      'manoeuvreDangereuse': manoeuvreDangereuse,
      'enZone': enZone,
    };
  }

  factory ShotRecord.fromJson(Map<String, dynamic> json) {
    return ShotRecord(
      horsZone: (json['horsZone'] is bool) 
          ? (json['horsZone'] == true ? 1 : 0) 
          : (json['horsZone'] as int? ?? 0),
      horsTemps: json['horsTemps'] ?? false,
      manoeuvreDangereuse: json['manoeuvreDangereuse'] ?? false,
      enZone: json['enZone'] ?? 0,
    );
  }
}

class Score {
  // Based on the screenshots, we have 5 rows (shots) with these columns:
  // Hors Zone, Hors temps, Manoeuvre dangereuse (negative points) and En Zone (positive points)
  List<ShotRecord> shots;

  Score({
    List<ShotRecord>? shots,
  }) : shots = shots ?? List.generate(5, (_) => ShotRecord());

  int get totalScore {
    int total = 0;
    for (var shot in shots) {
      // Negative points: Hors Zone (maintenant un entier), Hors temps, Manoeuvre dangereuse
      int negativeSum = shot.horsZone + 
                        (shot.horsTemps ? 1 : 0) + 
                        (shot.manoeuvreDangereuse ? 1 : 0);
      
      // Positive points: En Zone
      int enZonePoints = shot.enZone;
      
      // Apply formula: negative*-5 + positive*5
      total += (negativeSum * -5) + (enZonePoints * 5);
    }
    return total;
  }

  bool get isLowScore => totalScore < 45;
  bool get isHighScore => totalScore >= 45;

  Map<String, dynamic> toJson() {
    return {
      'shots': shots.map((shot) => shot.toJson()).toList(),
    };
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      shots: (json['shots'] as List?)
              ?.map((shotJson) => ShotRecord.fromJson(shotJson as Map<String, dynamic>))
              .toList() ?? 
          List.generate(5, (_) => ShotRecord()),
    );
  }
}
