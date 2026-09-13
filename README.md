# Lumiconte

Application mobile Flutter d'histoires pour enfants, à lire ou à écouter. Chaque enfant a son profil, ses favoris, sa progression et ses récompenses.

## Fonctionnalités

- **Comptes** : connexion par e-mail, Google ou Apple (Firebase Auth).
- **Profils enfants** : plusieurs profils par compte, chacun avec son avatar.
- **Bibliothèque** : histoires classées par catégorie, recherche, favoris, morales. L'accueil propose les histoires adaptées à l'âge du profil.
- **Lecture** : trois modes d'affichage (classique, immersif, manuscrit), taille de police réglable, option dyslexie, thème clair ou sombre.
- **Écoute** : lecture audio avec voix féminine ou masculine, synchronisée avec les pages du texte. La lecture continue en arrière-plan, avec des commandes dans la notification Android et sur l'écran de verrouillage.
- **Suivi** : reprise là où l'enfant s'est arrêté, temps de lecture, séries de jours et badges.
- **Rappels** : notifications locales programmées pour inviter à finir une histoire.
- **Retours** : page pour envoyer ses remarques sur l'application.

## Stack technique

| Domaine | Outils |
|---|---|
| Framework | Flutter (Dart SDK ≥ 3.0) |
| Navigation | `go_router` |
| Backend | Firebase : Auth, Cloud Firestore, Cloud Functions |
| Stockage des médias | Backblaze B2 (API compatible S3) |
| Audio | `just_audio`, `audio_service`, `audio_session` |
| Synthèse vocale | Google Cloud Text-to-Speech |
| Notifications | `flutter_local_notifications`, `timezone` |
| Images | `cached_network_image` avec un cache disque local |

## Structure du projet

```
lib/
├── config/       # Options Firebase, routes go_router
├── constants/    # Avatars
├── models/       # Histoire, profil, réglages, progression, récompenses…
├── navigation/   # Barre de navigation du bas
├── pages/        # Écrans (accueil, bibliothèque, profil, réglages…)
│   └── story/    # Écran de lecture et ses trois modes d'affichage
├── services/     # Auth, Firestore, stockage B2, audio, synchronisation texte/audio
├── theme/        # Thèmes clair et sombre
├── utils/
└── widget/       # Composants réutilisables
functions/        # Cloud Functions Firebase (Node.js)
assets/images/    # Logos, avatars, illustrations
```