@echo off
echo Running Flutter commands...

echo "##########Cleaning project..."
flutter clean

echo "#########Getting dependencies..."
flutter pub get
flutter pub outdated


echo "##########Building APK..."
flutter build appbundle --release

echo All commands executed successfully!
pause