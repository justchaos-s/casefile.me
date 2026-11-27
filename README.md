# CASEFILE (Flutter + Firebase)

Cyber-investigation case manager. Simulated cases only.

## 1. Install the tools
1. Flutter SDK (3.22 or newer): https://docs.flutter.dev/get-started/install
2. Node.js (needed for the Firebase CLI): https://nodejs.org
3. Firebase CLI and FlutterFire CLI:
   ```
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```
   Add `~/.pub-cache/bin` (Windows: `%LOCALAPPDATA%\Pub\Cache\bin`) to your PATH.
4. Check everything with `flutter doctor`.

## 2. Create the Flutter project and copy the code
```
flutter create casefile
cd casefile
flutter pub add firebase_core firebase_auth cloud_firestore http google_fonts intl
```
Delete the generated `lib/main.dart`, then copy this kit's `lib/` folder over the project's `lib/`.

## 3. Set up Firebase
1. Go to https://console.firebase.google.com and create a project named `casefile`.
2. Build > Authentication > Get started > enable **Email/Password**.
3. Build > Firestore Database > Create database (production mode, nearest region).
4. Firestore > Rules tab: paste the contents of `firestore.rules` and Publish.
5. In your project folder run:
   ```
   firebase login
   flutterfire configure
   ```
   Pick your project and the platforms you need (Android/iOS). This generates `lib/firebase_options.dart`.

## 4. Platform settings
- **Android**: in `android/app/build.gradle(.kts)` set `minSdk = 23` (Firebase Auth needs 23+).
  Internet permission is already included for release builds.
- **iOS** (Mac only): in `ios/Podfile` set `platform :ios, '13.0'`, then `cd ios && pod install`.

## 5. Run
```
flutter run
```

## Notes
- Case IDs (CASE-001, CASE-002...) come from a counter on `users/{uid}`, updated in a Firestore transaction.
- Search and filters run on the device, so no Firestore index is required.
- Threat data comes from the CISA KEV JSON feed (no API key). CISA does not publish CVSS scores in this feed, so the app shows "Used in ransomware" vs "Actively exploited" as the risk signal.
- If you run on Flutter Web, the CISA feed may be blocked by CORS. Test on Android, iOS or desktop.
