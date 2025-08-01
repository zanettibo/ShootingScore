#!/bin/bash

# Script pour incrémenter la version et créer un tag Git pour les releases
# Usage: ./bump_version.sh [major|minor|patch|build]

set -e

# Vérifier si le script est exécuté depuis la racine du projet
if [ ! -f "pubspec.yaml" ]; then
  echo "Erreur: Ce script doit être exécuté depuis la racine du projet."
  exit 1
fi

# Extraire la version actuelle du pubspec.yaml
CURRENT_VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')
echo "Version actuelle: $CURRENT_VERSION"

# Séparer la version sémantique et le numéro de build
VERSION=$(echo $CURRENT_VERSION | cut -d'+' -f1)
BUILD=$(echo $CURRENT_VERSION | cut -d'+' -f2)

# Séparer la version sémantique en ses composants
MAJOR=$(echo $VERSION | cut -d'.' -f1)
MINOR=$(echo $VERSION | cut -d'.' -f2)
PATCH=$(echo $VERSION | cut -d'.' -f3)

# Déterminer quelle partie de la version incrémenter
INCREMENT_TYPE=${1:-"build"}

case $INCREMENT_TYPE in
  "major")
    NEW_MAJOR=$((MAJOR + 1))
    NEW_MINOR=0
    NEW_PATCH=0
    NEW_BUILD=$BUILD
    ;;
  "minor")
    NEW_MAJOR=$MAJOR
    NEW_MINOR=$((MINOR + 1))
    NEW_PATCH=0
    NEW_BUILD=$BUILD
    ;;
  "patch")
    NEW_MAJOR=$MAJOR
    NEW_MINOR=$MINOR
    NEW_PATCH=$((PATCH + 1))
    NEW_BUILD=$BUILD
    ;;
  "build")
    NEW_MAJOR=$MAJOR
    NEW_MINOR=$MINOR
    NEW_PATCH=$PATCH
    NEW_BUILD=$((BUILD + 1))
    ;;
  *)
    echo "Usage: ./bump_version.sh [major|minor|patch|build]"
    exit 1
    ;;
esac

# Construire la nouvelle version
NEW_VERSION="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH+$NEW_BUILD"
echo "Nouvelle version: $NEW_VERSION"

# Mettre à jour pubspec.yaml
sed -i "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml
echo "✅ pubspec.yaml mis à jour"

# Vérifier si Git est disponible et si nous sommes dans un dépôt Git
if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &> /dev/null; then
  # Commit des changements
  git add pubspec.yaml
  git commit -m "chore: bump version à $NEW_VERSION"
  
  # Créer un tag Git
  git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"
  
  echo "✅ Commit et tag Git créés"
  echo "Pour pousser les changements vers le dépôt distant, exécutez:"
  echo "git push && git push --tags"
else
  echo "⚠️ Git non disponible ou pas dans un dépôt Git. Seul pubspec.yaml a été mis à jour."
fi
