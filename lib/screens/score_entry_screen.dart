import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shootingscore/models/participant.dart';
import 'package:shootingscore/providers/participants_provider.dart';
import 'package:shootingscore/screens/score_history_screen.dart';

class ScoreEntryScreen extends StatefulWidget {
  final Participant participant;

  const ScoreEntryScreen({
    super.key,
    required this.participant,
  });

  @override
  State<ScoreEntryScreen> createState() => _ScoreEntryScreenState();
}

class _ScoreEntryScreenState extends State<ScoreEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Track the state for each row
  List<ShotRecord> _shots = List.generate(5, (_) => ShotRecord());
  
  // Controllers for En Zone values (0-2)
  final List<TextEditingController> _enZoneControllers = 
      List.generate(5, (_) => TextEditingController(text: '0'));
      
  // Controllers for Hors Zone values (0-2)
  final List<TextEditingController> _horsZoneControllers = 
      List.generate(5, (_) => TextEditingController(text: '0'));
  
  int _calculateScore() {
    int total = 0;
    for (int i = 0; i < _shots.length; i++) {
      final shot = _shots[i];
      
      // Get the En Zone and Hors Zone values from controllers
      shot.enZone = int.tryParse(_enZoneControllers[i].text) ?? 0;
      shot.horsZone = int.tryParse(_horsZoneControllers[i].text) ?? 0;
      
      // Negative points: Hors Zone (maintenant un entier), Hors temps, Manoeuvre dangereuse
      int negativeSum = shot.horsZone + 
                        (shot.horsTemps ? 1 : 0) + 
                        (shot.manoeuvreDangereuse ? 1 : 0);
      
      // Apply formula: negative*-5 + positive*5
      total += (negativeSum * -5) + (shot.enZone * 5);
    }
    return total;
  }
  
  bool _isScoreLow() => _calculateScore() < 45;

  @override
  void dispose() {
    for (var controller in _enZoneControllers) {
      controller.dispose();
    }
    for (var controller in _horsZoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scores - ${widget.participant.prenom} ${widget.participant.nom}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (widget.participant.scores.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScoreHistoryScreen(participant: widget.participant),
                  ),
                );
              },
              tooltip: 'Historique des scores',
            ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildParticipantHeader(),
                    const SizedBox(height: 24),
                    _buildScoreEntryTable(orientation),
                    const SizedBox(height: 24),
                    _buildScoreResult(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveScore,
                        child: const Text(
                          'Enregistrer le score',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildParticipantHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.participant.prenom} ${widget.participant.nom}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Grade: ${widget.participant.grade}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreEntryTable(Orientation orientation) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saisie des Points',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildScoringTable(orientation),
          ],
        ),
      ),
    );
  }

  Widget _buildScoringTable(Orientation orientation) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            _buildHeaderRow(),
            const Divider(height: 1, thickness: 1),
            // Data Rows
            ...List.generate(5, (index) => _buildDataRow(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            _buildHeaderCell('N°TIR', width: 80),
            _buildHeaderCell('Hors Zone', width: 100),
            _buildHeaderCell('Hors temps', width: 100),
            _buildHeaderCell('Manoeuvre\ndangereuse', width: 120),
            _buildHeaderCell('En Zone', width: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required double width}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // N°TIR (Shot Number)
          Container(
            width: 80,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          // Hors Zone (Out of zone) - Numeric input 0-2
          _buildNumericInputCell(
            width: 100,
            controller: _horsZoneControllers[index],
          ),
          // Hors temps (Out of time)
          _buildCheckboxCell(
            width: 100,
            value: _shots[index].horsTemps,
            onChanged: (value) {
              setState(() {
                _shots[index].horsTemps = value ?? false;
              });
            },
          ),
          // Manoeuvre dangereuse (Dangerous maneuver)
          _buildCheckboxCell(
            width: 120,
            value: _shots[index].manoeuvreDangereuse,
            onChanged: (value) {
              setState(() {
                _shots[index].manoeuvreDangereuse = value ?? false;
              });
            },
          ),
          // En Zone (In zone) - Numeric input 0-2
          _buildNumericInputCell(
            width: 100,
            controller: _enZoneControllers[index],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxCell({required double width, required bool value, required Function(bool?) onChanged}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Checkbox(
        value: value,
        onChanged: (bool? newValue) {
          onChanged(newValue);
          setState(() {}); // Update score display
        },
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildNumericInputCell({required double width, required TextEditingController controller}) {
    // Get current value from controller
    int value = int.tryParse(controller.text) ?? 0;
    
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton moins
          InkWell(
            onTap: value > 0 ? () {
              setState(() {
                value = value - 1;
                controller.text = value.toString();
              });
            } : null,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.remove_circle, 
                color: value > 0 ? Colors.red : Colors.grey.shade300,
                size: 18,
              ),
            ),
          ),
          // Affichage de la valeur
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            constraints: const BoxConstraints(minWidth: 20),
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // Bouton plus
          InkWell(
            onTap: value < 2 ? () {
              setState(() {
                value = value + 1;
                controller.text = value.toString();
              });
            } : null,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.add_circle, 
                color: value < 2 ? Colors.green : Colors.grey.shade300,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreResult() {
    final score = _calculateScore();
    final isLow = _isScoreLow();
    // Modifier le seuil pour afficher en vert si score >= 45
    final isHigh = _calculateScore() >= 45;
    
    Color backgroundColor;
    Color textColor;
    
    if (isLow) {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red;
    } else if (isHigh) {
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green;
    } else {
      backgroundColor = Colors.grey.shade50;
      textColor = Colors.black87;
    }
    
    return Card(
      color: backgroundColor,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Total point: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (isLow)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _saveScore() {
    final participantsProvider = Provider.of<ParticipantsProvider>(
      context,
      listen: false,
    );

    // Update EnZone and HorsZone values from controllers to shot records
    for (int i = 0; i < _shots.length; i++) {
      _shots[i].enZone = int.tryParse(_enZoneControllers[i].text) ?? 0;
      _shots[i].horsZone = int.tryParse(_horsZoneControllers[i].text) ?? 0;
    }
    
    // Create a new score object with the shot records
    final newScore = Score(
      shots: List.from(_shots), // Create a copy of the shot records
    );
    
    // Save to provider
    participantsProvider.addScoreToParticipant(widget.participant.id, newScore);
    
    // Show confirmation and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Score enregistré!')),
    );
    
    Navigator.pop(context);
  }
}
