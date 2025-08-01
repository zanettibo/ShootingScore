# Workflow de Release - ShootingScore

Ce document décrit le processus complet de release pour l'application ShootingScore.

## Outils et services utilisés

- **GitHub Actions** : Pour l'automatisation des tests, builds et déploiements
- **Script de versioning** : Pour gérer facilement les versions et tags

## Cycle de développement et release

### 1. Développement quotidien

- Les développements se font sur des branches de fonctionnalités (`feature/*`)
- Une fois prêts, ils sont fusionnés dans la branche `develop` via des Pull Requests
- Les tests automatiques sont exécutés à chaque commit et PR

### 2. Préparation d'une release

Lorsqu'une nouvelle version est prête à être publiée :

1. **Incrémentation de version** :

   ```bash
   # Depuis la racine du projet
   ./tools/bump_version.sh [major|minor|patch|build]
   ```

   Exemples :
   - `./tools/bump_version.sh patch` : 1.0.0+3 → 1.0.1+3
   - `./tools/bump_version.sh minor` : 1.0.0+3 → 1.1.0+3 
   - `./tools/bump_version.sh major` : 1.0.0+3 → 2.0.0+3
   - `./tools/bump_version.sh build` : 1.0.0+3 → 1.0.0+4 (par défaut)

2. **Pousser les changements et le tag** :

   ```bash
   git push && git push --tags
   ```

3. **Déclenchement automatique du workflow** :

   Le tag poussé déclenchera automatiquement le workflow de release sur GitHub Actions qui :
   - Extraira la version du tag
   - Construira les artifacts pour Android (APK + AAB) et iOS (IPA)
   - Créera une release GitHub avec les artifacts disponibles en téléchargement

### 3. Publication sur les stores (manuel)

Les artifacts générés peuvent ensuite être publiés manuellement sur les stores :

- **Google Play Store** : Utiliser le fichier AAB depuis la release GitHub
- **Apple App Store** : Utiliser le fichier IPA ou reconstruire avec les certificats appropriés

## Personnalisation avancée

### Publication automatique sur les stores

Pour automatiser complètement le processus de publication sur les stores, vous pourriez :

1. **Google Play** : Ajouter l'action `r0adkll/upload-google-play` au workflow
2. **App Store** : Utiliser l'action `apple-actions/upload-app-store`

Ces intégrations nécessitent la configuration de secrets GitHub pour stocker les clés API et certificats.

### Tests avancés

Pour améliorer la qualité des tests, vous pourriez ajouter :

- Tests d'intégration avec `flutter_integration_test`
- Tests sur différents appareils avec Firebase Test Lab

## Troubleshooting

### En cas d'échec de build

1. Vérifier les logs dans GitHub Actions
2. Corriger les erreurs et refaire un commit
3. Si nécessaire, créer un nouveau tag avec le script de versioning

### En cas de problèmes avec les versions

Si une version incorrecte a été taguée, vous pouvez :

```bash
# Supprimer le tag local
git tag -d v1.0.0+3

# Supprimer le tag distant
git push origin :refs/tags/v1.0.0+3

# Corriger le pubspec.yaml et créer un nouveau tag
./tools/bump_version.sh
```
