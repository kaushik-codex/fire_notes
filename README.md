# FireNotes 📱🔥

A production-ready, secure Flutter note-taking application built with Cloud Firestore, Firebase Authentication, and Hardware-Backed Secure Storage.

## Key Technical Highlights

* **Architecture:** Clean Architecture with Repository Pattern (`INotesRepository`) and `Provider` state management.
* **Security & Isolation:** Real-time Firestore CRUD strictly scoped to `users/{uid}/notes` backed by server-side Cloud Firestore Security Rules (`request.auth.uid == userId`).
* **Hardware Security:** Native Android Keystore exception handling (`PlatformException`) inside `SecureStorageService` to clear invalid keys and gracefully recover from hardware-level state changes.
* **Data Hygiene & Offline:** Firebase Auth logout clears hardware-backed keys and session state. Includes offline Firestore persistence.
* **Testing:** Unit tests with `mocktail` verifying `SecureStorageService` operations and error recovery.
* **Production Build:** Optimized release APK generated with R8/ProGuard rules enabled.

## Getting Started

1. Clone the repository.
2. Run `flutter pub get`.
3. Configure your Firebase project (`google-services.json` / `GoogleService-Info.plist`).
4. Apply `firestore.rules` to your Firebase Console.
5. Run tests: `flutter test`.
6. Run app: `flutter run`.