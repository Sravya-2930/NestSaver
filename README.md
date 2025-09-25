# 🔐 SecureNest

**SecureNest** is a secure cloud vault built with **Flutter**, **Dart**, and **Firebase**. It lets users store passwords and important documents safely with **end-to-end encryption** — even the admin can’t see the data.

## 🚀 Features
- 🔑 Encrypted password storage  
- 📁 Upload and access documents securely  
- ☁️ Cloud storage with Firebase  
- 👤 Only user can view their data  
- 🔒 Zero-knowledge security  

## 🛠️ Tech Stack
- Flutter & Dart  
- Firebase Auth, Firestore, Storage  
- AES/RSA Client-Side Encryption

## 📁 Project Structure
```
securenest/
├─ lib/
│ ├─ main.dart # App entry point
│ ├─ pages/ # UI screens
│ ├─ services/ # Firebase + encryption
│ ├─ widgets/ # UI components
│ └─ utils/ # Helpers
├─ android/
├─ ios/
└─ pubspec.yaml
```


## ⚙️ Getting Started
```bash
git clone https://github.com/yourusername/securenest.git
cd securenest
flutter pub get
flutter run
```

# Set up Firebase:

 Create project at Firebase Console

 Add Android/iOS apps

 Add google-services.json and GoogleService-Info.plist

# 🔐 Security

 End-to-end encryption

 Zero-knowledge: only user can decrypt

 Admin cannot access stored data

# 📄 License

 MIT License
