import 'package:flutter/material.dart';
import 'package:shootingscore/models/participant.dart';

class ScoreHistoryScreen extends StatelessWidget {
  final Participant participant;

  const ScoreHistoryScreen({
    super.key,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique - ${participant.prenom} ${participant.nom}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: participant.scores.isEmpty
          ? const Center(
              child: Text(
                'Aucun score enregistré',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historique des scores de ${participant.prenom} ${participant.nom}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: participant.scores.length,
                      itemBuilder: (context, index) {
                        // Reverse order to show newest first
                        final reversedIndex = participant.scores.length - 1 - index;
                        final score = participant.scores[reversedIndex];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: score.isLowScore
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Session ${reversedIndex + 1}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: score.isLowScore
                                            ? Colors.red.withOpacity(0.2)
                                            : Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Total: ${score.totalScore}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: score.isLowScore
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                _buildScoreDetails(score),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildScoreDetails(Score score) {
    // Calculate sums for negative and positive points
    int totalNegative = 0;
    int totalPositive = 0;
    
    for (var shot in score.shots) {
      // Count negative points (horsZone is now 0-2, others are checkboxes)
      int negativeInShot = shot.horsZone + 
                          (shot.horsTemps ? 1 : 0) + 
                          (shot.manoeuvreDangereuse ? 1 : 0);
      totalNegative += negativeInShot;
      
      // Count positive points (enZone value)
      totalPositive += shot.enZone;
    }
    
    final int negativeResult = totalNegative * -5;
    final int positiveResult = totalPositive * 5;

    return Column(
      children: [
        _buildScoringTable(score),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Formule:'),
                  Expanded(
                    child: Text(
                      'SUM(Négatifs)*-5 + SUM(Positifs)*5',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Calcul:'),
                  Text(
                    '$totalNegative × (-5) + $totalPositive × 5 = $negativeResult + $positiveResult = ${score.totalScore}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoringTable(Score score) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails des tirs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) => Colors.grey.shade200,
                ),
                columns: const [
                  DataColumn(label: Text('N°TIR')),
                  DataColumn(label: Text('Hors Zone')),
                  DataColumn(label: Text('Hors temps')),
                  DataColumn(label: Text('Manoeuvre dangereuse')),
                  DataColumn(label: Text('En Zone')),
                  DataColumn(label: Text('Points')),
                ],
                rows: List.generate(score.shots.length, (index) {
                  final shot = score.shots[index];
                  // Calculate points for this shot
                  final int negativePoints = shot.horsZone + 
                                           (shot.horsTemps ? 1 : 0) + 
                                           (shot.manoeuvreDangereuse ? 1 : 0);
                  final int shotTotal = (negativePoints * -5) + (shot.enZone * 5);
                  
                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(_buildNumericIndicator(shot.horsZone)),
                      DataCell(_buildBooleanIndicator(shot.horsTemps)),
                      DataCell(_buildBooleanIndicator(shot.manoeuvreDangereuse)),
                      DataCell(Text('${shot.enZone}')),
                      DataCell(Text(
                        '$shotTotal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: shotTotal < 0 ? Colors.red : Colors.green,
                        ),
                      )),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBooleanIndicator(bool value) {
    return value
        ? const Icon(Icons.check_circle, color: Colors.red, size: 20)
        : const Icon(Icons.cancel_outlined, color: Colors.grey, size: 20);
  }
  
  Widget _buildNumericIndicator(int value) {
    if (value == 0) {
      return const Icon(Icons.cancel_outlined, color: Colors.grey, size: 20);
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value', 
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.check_circle, color: Colors.red, size: 20),
        ],
      );
    }
  }
}
