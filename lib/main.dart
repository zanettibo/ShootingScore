import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shootingscore/providers/participants_provider.dart';
import 'package:shootingscore/providers/examens_provider.dart';
import 'package:shootingscore/providers/sessions_provider.dart';
import 'package:shootingscore/screens/tabs_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ParticipantsProvider()),
        ChangeNotifierProvider(create: (_) => ExamensProvider()),
      ],
      child: AppInitializer(),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    final examensProvider = Provider.of<ExamensProvider>(
      context,
      listen: false,
    );

    // Chargement séquentiel des données
    return FutureBuilder(
      // D'abord charger les examens
      future: examensProvider.loadExamens(),
      builder: (context, snapshot) {
        // Si les examens sont en train de charger, afficher un écran de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // Si le chargement est terminé, initialiser le SessionsProvider et démarrer l'application
        return ChangeNotifierProvider(
          create: (_) => SessionsProvider(examensProvider),
          child: MaterialApp(
            title: 'Shooting Score',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),
            home: const TabsScreen(),
          ),
        );
      },
    );
  }
}
