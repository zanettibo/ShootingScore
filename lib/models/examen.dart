class Examen {
  final String id;
  String nom;
  int nombreDeTirs;
  int pointsMinPourValidation;

  Examen({
    required this.id,
    required this.nom,
    required this.nombreDeTirs,
    required this.pointsMinPourValidation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'nombreDeTirs': nombreDeTirs,
      'pointsMinPourValidation': pointsMinPourValidation,
    };
  }

  factory Examen.fromJson(Map<String, dynamic> json) {
    return Examen(
      id: json['id'],
      nom: json['nom'],
      nombreDeTirs: json['nombreDeTirs'],
      pointsMinPourValidation: json['pointsMinPourValidation'],
    );
  }
}
