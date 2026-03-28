# Gaanfy

A Spotify and JioSaavn inspired Flutter music app scaffold with:

- Online streaming discovery using the free public iTunes Search API for demo music previews
- Offline local-library playback from songs already stored on the device
- Separate online and offline playback queues
- SQLite checkpoint persistence for queue, current index, progress, and shuffle mode
- Firebase-ready email authentication with Firestore profile creation
- Animated logo splash and auth UI inspired by the reference design
- MVVM-style folder structure with separate screens, viewmodels, models, services, and widgets

## Structure

`lib/`

- `core/` theme, routes, enums
- `models/` song and checkpoint models
- `services/` Firebase bootstrap, auth, online API, offline music scan, SQLite, playback
- `viewmodels/` auth, online music, offline music
- `views/` splash, auth, home tabs, dedicated player screens
- `widgets/` reusable UI pieces

## Firebase setup

1. Create a Firebase project.
2. Add Android and iOS apps in Firebase.
3. Place `google-services.json` inside `android/app/`.
4. Place `GoogleService-Info.plist` inside `ios/Runner/`.
5. Enable Email/Password auth in Firebase Authentication.
6. Optionally enable Google, Phone, Facebook, and Apple providers later.

The app already handles missing Firebase config gracefully and still supports demo-mode exploration.

## Notes

- Online playback and offline playback are intentionally separated, including resume checkpoints.
- For very large scale, the profile screen documents the migration path to a dedicated NoSQL store such as Cassandra for metadata/session-heavy workloads while Firebase Auth remains the identity provider.
