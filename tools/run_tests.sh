#!/bin/bash

# Script pour exécuter les tests Flutter avec rapport détaillé
# Usage: ./run_tests.sh

set -e

# Vérifier si le script est exécuté depuis la racine du projet
if [ ! -f "pubspec.yaml" ]; then
  echo "Erreur: Ce script doit être exécuté depuis la racine du projet."
  exit 1
fi

echo "🧪 Exécution des tests Flutter..."

# Analyse du code
echo "📋 Analyse du code..."
flutter analyze

# Tests unitaires
echo "🔬 Exécution des tests unitaires..."
flutter test --coverage --machine > test-results.json

# Si lcov est installé, générer un rapport HTML de la couverture de code
if command -v lcov &> /dev/null && command -v genhtml &> /dev/null; then
  echo "📊 Génération du rapport de couverture de code..."
  lcov --summary coverage/lcov.info
  genhtml coverage/lcov.info -o coverage/html
  
  echo "✅ Rapport de couverture de code généré dans: coverage/html/index.html"
else
  echo "⚠️ lcov n'est pas installé. Le rapport de couverture HTML n'a pas été généré."
  echo "   Installation: sudo apt-get install lcov"
fi

# Afficher le résumé des tests
echo "📑 Résumé des tests:"
flutter test --coverage
