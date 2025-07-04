# 📝 Notes On Short - Flutter Notes App

**Notes On Short** is a comprehensive, cross-platform notes application developed using **Flutter**. It allows users to efficiently create, organize, and manage notes with advanced features like color coding, note searching, and filtering.

This project demonstrates clean architecture, efficient state management, and integration of both local and cloud storage solutions.

---

## 🚀 Features
- ✅ **Create, Edit & Delete Notes**
- ✅ **Local Storage using Isar Database (Fast & Offline-First)**
- ✅ **Manual Cloud Sync via Firebase Firestore**
- ✅ **Starred Notes for Quick Access**
- ✅ **Color Coded Notes for Easy Organization**
- ✅ **Search Notes by Title or Content**
- ✅ **Filter Notes by Color Tags**
- ✅ **Cross-Platform:** Android & iOS
- ✅ **Responsive UI**

---

## 🏗️ Architecture & Tech Stack
- **Flutter** (Dart) - Cross-platform UI framework
- **Isar Database** - Local, NoSQL, high-performance storage
- **Firebase Firestore** - Cloud database for manual sync
- **Provider** - State Management
- **Feature Folder Architecture + MVC Pattern**
  - Organized, scalable project structure for ease of maintenance.

---

## 📂 Project Structure

```plaintext
lib/
│
├── common/                     # Reusable Components & Styles
│   ├── styles/
│   └── widgets/
│
├── data/                       # Data Layer
│   ├── repositories/
│   └── services/
│
├── features/                   # Feature Modules (Feature-first Structure)
│   ├── authentication/
│   │   ├── controllers/
│   │   ├── models/
│   │   └── screens/
│   │
│   └── notes/
│       ├── controllers/
│       ├── models/
│       ├── screens/
│       ├── services/
│       └── widgets/
│
├── utils/                      # Utilities & Helpers
│   ├── constants/
│   ├── device/
│   ├── helpers/
│   ├── logger/
│   └── themes/
│
└── main.dart                   # App Entry Point

```

## 📲 Installation & Setup
> ⚠️ This is a personal project for learning and portfolio purposes, not intended for production use.
> ### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Firebase account

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/your-repo.git
```

2. **Navigate to the project folder**
```bash
cd your-repo
```

3. **Fetch project dependencies**
```bash
flutter pub get
```

4. **Configure Firebase**
- Add your `google-services.json` (for Android) to `android/app/`
- Add your `GoogleService-Info.plist` (for iOS) to `ios/Runner/`
- Ensure Firebase is properly set up in your Firebase Console for Firestore

5. **Run the application**
```bash
flutter run
```

## 🧪 Testing

Run the test suite to ensure everything is working correctly:

```bash
flutter test
```

## 🌱 Future Improvements

- [ ] Automatic Cloud Sync in Background
- [ ] Cloud Conflict Resolution Strategies
- [ ] UI/UX Enhancements
- [ ] Multi-Device Syncing Support

## 📜 License

This project is built for educational and portfolio purposes only.

## 🎯 Purpose

This project showcases my ability to:

- Build scalable and maintainable Flutter applications
- Implement both local and cloud storage solutions
- Apply advanced state management techniques
- Architect apps following clean, modular principles
## 📸 Screenshots

### 📝 Notes App Screenshots

#### Home Screen
<img src="assets/screenshots/notes1.jpg" width="250">

#### Starred Screen
<img src="assets/screenshots/notes2.jpg" width="250">

#### Search and Filter
<img src="assets/screenshots/notes3.jpg" width="250">

#### Filter Notes
<img src="assets/screenshots/notes4.jpg" width="250">

#### Create Note Screen
<img src="assets/screenshots/notes5.jpg" width="250">

#### Edit Note Screen
<img src="assets/screenshots/notes6.jpg" width="250">


---

*Built with ❤️ using Flutter*



