# Workflow de Release pour ShootingScore

Ce document décrit le processus de release automatisé pour l'application ShootingScore, en détaillant les étapes du CI/CD, les tests, et la publication des builds.

## Table des matières

1. [Aperçu du workflow](#aperçu-du-workflow)
2. [Prérequis](#prérequis)
3. [Tests automatisés](#tests-automatisés)
4. [Gestion des versions](#gestion-des-versions)
5. [Build et signature](#build-et-signature)
6. [Publication](#publication)
7. [Étendre le workflow](#étendre-le-workflow)

## Aperçu du workflow

Le workflow de release pour ShootingScore comprend les étapes suivantes :

1. Exécution des tests unitaires et widget
2. Incrémentation de la version et création d'un tag Git
3. Génération des builds Android (APK/AAB) et iOS (IPA)
4. Signature des builds Android
5. Publication des builds en tant que release GitHub

## Prérequis

### Secrets GitHub

Pour que le workflow fonctionne correctement, les secrets suivants doivent être configurés dans le dépôt GitHub :

- `KEYSTORE_BASE64` : Keystore Android encodé en Base64
- `KEYSTORE_PASSWORD` : Mot de passe du keystore
- `KEY_PASSWORD` : Mot de passe de la clé
- `KEY_ALIAS` : Alias de la clé

#### Comment générer un keystore Android

```bash
keytool -genkey -v -keystore shootingscore.keystore -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

#### Comment encoder le keystore en Base64

```bash
base64 -i shootingscore.keystore | tr -d '\n' > keystore-base64.txt
```

Ensuite, ajoutez le contenu du fichier `keystore-base64.txt` comme secret GitHub.

## Tests automatisés

Les tests sont exécutés automatiquement lors de chaque pull request et push sur la branche principale via le workflow GitHub Actions `test.yml`.

Pour exécuter les tests localement :

```bash
./tools/run_tests.sh
```

### Structure des tests

- `test/models/` : Tests unitaires pour les modèles
- `test/providers/` : Tests unitaires pour les providers
- `test/widgets/` : Tests widget pour les écrans et composants

## Gestion des versions

Le versioning suit le format standard `X.Y.Z+N` où :
- `X.Y.Z` est la version sémantique (major.minor.patch)
- `N` est le numéro de build

### Script d'incrémentation de version

Pour incrémenter la version, utilisez le script `tools/bump_version.sh` :

```bash
# Incrémenter la version patch
./tools/bump_version.sh patch

# Incrémenter la version minor
./tools/bump_version.sh minor

# Incrémenter la version major
./tools/bump_version.sh major

# Incrémenter uniquement le numéro de build
./tools/bump_version.sh build
```

Ce script met à jour le fichier `pubspec.yaml` et crée un tag Git correspondant.

## Build et signature

### Android

Les builds Android sont signés automatiquement lors du workflow de release en utilisant les secrets GitHub. Le fichier `android/app/build.gradle.kts` est configuré pour utiliser le fichier `key.properties` généré pendant le workflow.

### iOS

Pour iOS, le workflow génère un build non signé (car la signature requiert un certificat Apple Developer qui ne peut pas être facilement intégré au CI/CD). Le build IPA généré devra être signé manuellement avant publication sur l'App Store.

## Publication

Lorsqu'un tag Git commençant par `v` (ex: `v1.0.0+1`) est poussé sur le dépôt, le workflow de release est automatiquement déclenché et :

1. Génère les builds Android et iOS
2. Crée une release GitHub
3. Attache les artefacts (APK, AAB, IPA) à la release

Pour déclencher une nouvelle release :

```bash
git tag v1.0.0+1
git push origin v1.0.0+1
```

## Étendre le workflow

### Publier sur le Play Store

Pour ajouter la publication automatique sur le Play Store, vous pouvez étendre le workflow en utilisant l'action `r0adkll/upload-google-play` et en configurant les secrets supplémentaires nécessaires (JSON de compte de service Google Play).

### Publier sur l'App Store

Pour la publication sur l'App Store, considérez l'utilisation de Fastlane avec l'action `maierj/fastlane-action` et configurez les certificats nécessaires.
