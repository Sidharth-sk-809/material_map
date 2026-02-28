#!/bin/bash

# Firebase to FastAPI Migration Cleanup Script
# This script removes Firebase-related dependencies and configurations

echo "🧹 Cleaning up Firebase dependencies from Flutter app..."

# 1. Clean Flutter build
echo "Cleaning Flutter build artifacts..."
flutter clean

# 2. Remove iOS Firebase pods (if applicable)
if [ -d "ios/Pods" ]; then
    echo "Removing iOS pods..."
    rm -rf ios/Pods
    rm -f ios/Podfile.lock
fi

# 3. Remove Android Firebase build artifacts
echo "Removing Android Firebase build artifacts..."
rm -rf build/firebase*
rm -rf android/build/firebase*

# 4. Remove pub cache for Firebase packages
echo "Removing Firebase packages from pub cache..."
# This is handled by 'flutter pub get' after pubspec.yaml update

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "Next steps:"
echo "1. Run: flutter pub get"
echo "2. Update API URL in lib/core/constants/api_config.dart"
echo "3. Start the FastAPI backend: cd backend && python main.py"
echo "4. Run: flutter run"
