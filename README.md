
# CASEFILE — The Investigation Lab

### A Cyber-Investigation Case Management Application

**Flutter | Dart | Firebase | Cloud Firestore | REST API**

---

## 1. Project Overview

CASEFILE — The Investigation Lab is a Flutter-based cyber-investigation case management application designed to provide a structured environment for creating, managing, tracking, and analysing simulated cybersecurity investigation cases.

The application combines user authentication, cloud-based data storage, case management, and cybersecurity threat intelligence into a unified interface.

CASEFILE uses Firebase Authentication for user access, Cloud Firestore for storing investigation records, and the CISA Known Exploited Vulnerabilities (KEV) catalogue to retrieve cybersecurity threat information.

> **Disclaimer:** This application is developed for educational and demonstration purposes. All investigation cases are simulated and do not represent actual criminal investigations.

---

## 2. Project Objectives

- Develop a cross-platform mobile application using Flutter.
- Implement user registration and login using Firebase Authentication.
- Integrate Cloud Firestore for cloud-based data management.
- Provide an interface for creating, viewing, and managing simulated investigation cases.
- Retrieve external cybersecurity threat intelligence using a REST API.
- Implement structured navigation between multiple application screens.
- Explore practical applications of cloud computing and mobile application development.

---

## 3. Key Features

### Authentication
- User registration and login.
- Firebase Authentication integration.
- Authentication-based application navigation.

### Case Management
- Create and manage simulated investigation cases.
- Generate unique case identifiers.
- View individual case details.
- Search and filter investigation records.

### Threat Intelligence
- Fetch cybersecurity vulnerability information from the CISA KEV catalogue.
- Display actively exploited vulnerabilities.
- Highlight vulnerabilities associated with ransomware.

### User Dashboard
- Centralised application dashboard.
- Navigation to investigation and threat intelligence modules.
- User profile section.

### Cloud Database
- Firebase Cloud Firestore integration.
- Store and retrieve investigation records.
- User-specific data management.

---

## 4. Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Application programming language |
| Firebase Authentication | User authentication |
| Cloud Firestore | Cloud database |
| REST API | External data retrieval |
| CISA KEV | Cybersecurity threat intelligence |
| Google Fonts | Typography and UI styling |
| Git & GitHub | Version control and source code management |

---

## 5. Application Screens

The application includes the following screens:

1. Splash Screen
2. Login Screen
3. Registration Screen
4. Dashboard Screen
5. Case Files Screen
6. Case Details Screen
7. Case Creation Screen
8. Threat Intelligence Screen
9. User Profile Screen

---

## 6. Project Structure

```text
casefile/
│
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── theme.dart
│   │
│   ├── models/
│   │   └── case_model.dart
│   │
│   ├── screens/
│   │   ├── auth_gate.dart
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── case_files_screen.dart
│   │   ├── case_details_screen.dart
│   │   ├── case_form_screen.dart
│   │   ├── threat_intel_screen.dart
│   │   ├── profile_screen.dart
│   │   └── home_shell.dart
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── case_service.dart
│   │   └── threat_service.dart
│   │
│   └── widgets/
│       └── common.dart
│
├── android/
├── ios/
├── web/
├── windows/
│
├── firestore.rules
├── firebase.json
├── pubspec.yaml
└── README.md
```

---

## 7. Firebase Database Design

The application uses Cloud Firestore for cloud-based data storage.

### Proposed Collection Structure

```text
users/
   └── {uid}/
       ├── name
       ├── email
       └── caseCounter

cases/
   └── {caseDocumentId}/
       ├── caseId
       ├── title
       ├── description
       ├── status
       ├── createdAt
       └── userId
```

Case identifiers follow a sequential format such as:

- CASE-001
- CASE-002
- CASE-003

A Firestore transaction is used to update the user's case counter.

---

## 8. External API Integration

CASEFILE integrates the CISA Known Exploited Vulnerabilities (KEV) catalogue.

**API Source:**

https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json

The API provides information about known exploited vulnerabilities, including:

- Vulnerability identifiers (CVE IDs).
- Vulnerability descriptions.
- Vendor and product information.
- Date added to the catalogue.
- Ransomware-related indicators.

The application retrieves and displays this information through HTTP requests.

---

## 9. Installation and Setup

### Prerequisites

- Flutter SDK 3.22 or newer.
- Dart SDK.
- Android Studio or Visual Studio Code.
- Node.js.
- Firebase account.
- Git.

### Step 1: Clone the Repository

```bash
git clone https://github.com/justchaos-s/casefile.me.git
cd casefile.me
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure Firebase

1. Create or select a Firebase project.
2. Enable Email/Password authentication.
3. Create a Cloud Firestore database.
4. Configure Firebase for the required platforms.
5. Run FlutterFire configuration if setting up a fresh environment.

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli

firebase login
flutterfire configure
```

### Step 4: Configure Firestore

Copy the rules from `firestore.rules` into the Firebase Console under:

**Firestore Database → Rules**

Publish the rules after verifying the access permissions.

### Step 5: Run the Application

```bash
flutter run
```

---

## 10. Security Considerations

- Firebase Authentication manages user authentication.
- Firestore security rules restrict access to authorised user data.
- Simulated investigation data is used.
- No real-world sensitive investigation information should be stored.
- Firebase configuration and API access should follow appropriate security practices.

---

## 11. Future Scope

Potential enhancements include:

- Advanced investigation analytics.
- Evidence attachment and document management.
- Improved search and filtering.
- Push notifications for important updates.
- Role-based access control.
- Enhanced threat intelligence dashboards.
- Exporting investigation reports.

---

## 12. Project Information

| Detail | Information |
|---|---|
| Project Name | CASEFILE — The Investigation Lab |
| Project Type | Mobile Application Development |
| Framework | Flutter |
| Programming Language | Dart |
| Backend | Firebase |
| Database | Cloud Firestore |
| External API | CISA KEV |
| Purpose | Academic Project |

---

## 13. Repository

**GitHub Repository:**

https://github.com/justchaos-s/casefile.me

---

### CASEFILE — Every Investigation Begins With a Question.

**Developed as an Academic Application Development Project.**


## Notes
- Case IDs (CASE-001, CASE-002...) come from a counter on `users/{uid}`, updated in a Firestore transaction.
- Search and filters run on the device, so no Firestore index is required.
- Threat data comes from the CISA KEV JSON feed (no API key). CISA does not publish CVSS scores in this feed, so the app shows "Used in ransomware" vs "Actively exploited" as the risk signal.
- If you run on Flutter Web, the CISA feed may be blocked by CORS. Test on Android, iOS or desktop.
