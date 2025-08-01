import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shootingscore/models/examen.dart';
import 'package:shootingscore/providers/examens_provider.dart';
import 'package:shootingscore/screens/examen_form_screen.dart';

class ExamensScreen extends StatelessWidget {
  const ExamensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamensProvider>(
      builder: (context, examensProvider, child) {
        if (examensProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (examensProvider.examens.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun examen configuré',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un examen'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ExamenFormScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          bottom:
              true, // Important pour éviter la superposition avec les boutons Android
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Configuration des examens',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ExamenFormScreen(),
                          ),
                        );
                      },
                      tooltip: 'Créer un examen',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: examensProvider.examens.length,
                    itemBuilder: (context, index) {
                      final examen = examensProvider.examens[index];
                      return _buildExamenCard(context, examen, examensProvider);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamenCard(
    BuildContext context,
    Examen examen,
    ExamensProvider provider,
  ) {
    return Dismissible(
      key: Key(examen.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text('Voulez-vous vraiment supprimer cet examen ?'),
            actions: [
              TextButton(
                child: const Text('Non'),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              TextButton(
                child: const Text('Oui'),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        provider.removeExamen(examen.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Examen supprimé')));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ExamenFormScreen(examen: examen),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  examen.nom,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nombre de tirs: ${examen.nombreDeTirs}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Validation: ${examen.pointsMinPourValidation} points',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
