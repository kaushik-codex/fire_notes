# FireNotes 📱🔥

A production-grade, secure Flutter note-taking application powered by:

* ☁️ Cloud Firestore
* 🔐 Firebase Authentication
* 🖼️ Cloudinary Image Hosting
* 🔔 Firebase Cloud Messaging (FCM)
* 🛡️ Firebase App Check
* 🔑 Hardware-Backed Secure Storage

---

## 🏗️ Architecture & Engineering Highlights

### Clean Architecture & Repository Pattern

Domain logic is decoupled from external SDKs using `INotesRepository` and injected cleanly across the widget tree via `Provider`.

### Database Path Scoping & Security Rules

All CRUD operations are strictly isolated under:

```text
users/{uid}/notes
```

Backend access is validated using Cloud Firestore Security Rules:

```text
request.auth.uid == userId
```

### Media & Attachment Pipeline

Image attachments are compressed on-device and hosted via the Cloudinary Unsigned API to optimize cloud delivery without incurring unnecessary database bloat.

### Hardware-Backed Keystore Error Handling

A custom `SecureStorageService` captures native Android `PlatformException` keystore invalidation events and triggers automated recovery sweeps.

### Attestation & Request Verification

Integrated **Firebase App Check**:

* **Play Integrity** in release builds
* **Debug Provider** during local development

This helps block unauthorized API traffic and scraper bots.

### Real-Time Push Notifications

Configured **Firebase Cloud Messaging (FCM)** with:

* Android local notification channels
* Foreground notification handling
* Background message handling

### Custom Performance Traces

Firebase Performance Monitoring is used to monitor:

* Note creation latency
* Image network round-trip performance

### Unit Testing

Comprehensive unit tests are built using `mocktail`, verifying:

* `SecureStorageService` read operations
* `SecureStorageService` write operations
* Keystore failure recovery

### Production Build Verification

Release APK builds are verified with:

* ProGuard/R8 code shrinking
* Custom ProGuard/R8 keep rules

---

## 🚀 Getting Started

### 1. Clone & Install

```bash
git clone <your-repo-url>
cd fire_notes
flutter pub get
```

---

### 2. Configure Firebase & Backend

#### Add Firebase Configuration

Place your `google-services.json` file inside:

```text
android/app/
```

#### Add SHA Fingerprints

Add your application's:

* SHA-1 fingerprint
* SHA-256 fingerprint

to your Firebase Console project settings.

#### Deploy Firestore Security Rules

Deploy the Firestore security rules from:

```text
firestore.rules
```

#### Configure Firebase App Check

Register your App Check debug token in:

**Firebase Console → App Check → Manage debug tokens**

---

### 3. Configure Cloudinary

Open:

```text
lib/services/storage_service.dart
```

Set your Cloudinary cloud name and unsigned upload preset:

```dart
static const String _cloudName = 'YOUR_CLOUD_NAME';
static const String _uploadPreset = 'YOUR_UNSIGNED_PRESET';
```

> **⚠️ Security Note:** Never commit sensitive credentials, API secrets, or private keys to source control.

---

### 4. Run Tests

Run the complete Flutter test suite:

```bash
flutter test
```

---

### 5. Run the Application

Start the Flutter application:

```bash
flutter run
```

---

## 🔐 Security

FireNotes is designed with security as a core requirement.

The application uses:

* Firebase Authentication for user identity
* Firestore Security Rules for per-user database isolation
* Hardware-backed secure storage for sensitive local data
* Firebase App Check for request attestation
* Cloudinary for external image storage
* Strict `users/{uid}/notes` database scoping

---

## 🗄️ Firestore Data Structure

Notes are stored under the authenticated user's document:

```text
users/
└── {uid}/
    └── notes/
        └── {noteId}
```

This ensures that each user's notes remain logically isolated from other users.

---

## 🧪 Testing

Run all tests with:

```bash
flutter test
```

The test suite includes verification for secure storage operations and keystore failure recovery.

---

## 📦 Production Build

For a production Android build:

```bash
flutter build apk --release
```

The release build should be verified with:

* R8/ProGuard shrinking
* Custom keep rules
* Firebase configuration
* App Check
* Secure storage
* Firestore security rules

---

## 🛠️ Tech Stack

| Technology               | Purpose                               |
| ------------------------ | ------------------------------------- |
| Flutter                  | Cross-platform application framework  |
| Dart                     | Application programming language      |
| Firebase Authentication  | User authentication                   |
| Cloud Firestore          | Real-time note database               |
| Cloudinary               | Image hosting                         |
| Firebase Cloud Messaging | Push notifications                    |
| Firebase App Check       | API/request protection                |
| Firebase Performance     | Performance monitoring                |
| Secure Storage           | Secure local persistence              |
| Provider                 | Dependency injection/state management |
| Mocktail                 | Unit testing                          |

---

## 📁 Project Configuration

Important project files and directories include:

```text
fire_notes/
├── android/
│   └── app/
│       └── google-services.json
├── lib/
│   └── services/
│       └── storage_service.dart
├── firestore.rules
├── test/
├── pubspec.yaml
└── README.md
```

---

## 📌 Development Checklist

* [ ] Configure Firebase project
* [ ] Add `google-services.json`
* [ ] Configure SHA-1 fingerprint
* [ ] Configure SHA-256 fingerprint
* [ ] Configure Firestore
* [ ] Deploy Firestore security rules
* [ ] Configure Firebase App Check
* [ ] Register App Check debug token
* [ ] Configure Cloudinary
* [ ] Run `flutter pub get`
* [ ] Run `flutter test`
* [ ] Run `flutter run`
* [ ] Verify release APK
* [ ] Verify R8/ProGuard configuration

---

## 🔥 FireNotes

**Secure. Real-time. Production-ready.**

Built with Flutter, Firebase, Cloudinary, and modern application architecture.
