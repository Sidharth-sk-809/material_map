# Optional: Firebase Cleanup Instructions

After migration, you may optionally remove Firebase-related files from your project.

## ⚠️ Important Notes

- Generated build files will be recreated if not deleted
- The actual android/app/google-services.json can be safely deleted
- Running `flutter clean` will remove Firebase build artifacts

## Firebase Files You Can Delete

### Android
```
android/app/google-services.json  # Safe to delete - no longer used
```

### iOS (if Firebase was configured)
```
ios/Firebase/         # If it exists - Firebase iOS config
GoogleService-Info.plist  # If it exists - iOS config
```

### Build Artifacts (Safe - will be recreated)
These are auto-generated and will reappear if you rebuild:
```
build/firebase_auth/
build/firebase_core/
build/firebase_storage/
build/firebase_firestore/
build/cloud_firestore/
```

## How to Clean

### Method 1: Automatic Cleanup
```bash
# Run cleanup script
chmod +x cleanup_firebase.sh
./cleanup_firebase.sh
```

### Method 2: Manual Cleanup
```bash
# Android
rm android/app/google-services.json

# iOS (if needed)
rm ios/GoogleService-Info.plist

# Flutter clean (removes build artifacts)
flutter clean
flutter pub get
```

## Verification

After cleanup, verify:
1. ✅ No Firebase references in compilation
2. ✅ App builds successfully
3. ✅ Authentication still works
4. ✅ Data still loads from backend

## Why Keep google-services.json?

The file doesn't hurt if left behind since:
- Flutter doesn't process it anymore
- It can be useful as reference
- Deletion is optional

## Revert Firebase (Not Recommended)

If you need to revert back to Firebase:
1. Restore `pubspec.yaml` from git
2. Restore `lib/main.dart` from git
3. Restore repositories and providers from git
4. Restore `google-services.json`
5. Run `flutter pub get`

However, migration to FastAPI is complete and recommended.
