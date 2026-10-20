@echo off
echo Running Flutter commands...

echo "##########Cleaning project..."
flutter clean

echo "#########Getting dependencies..."
flutter pub get
flutter pub outdated

echo "##########upgrading flutter"
flutter pub upgrade
flutter pub outdated

echo "##########gradle clean..."
cd android
./gradlew clean
adb uninstall com.nahro.arqamy
flutter channel stable
cd ..
flutter clean
flutter pub get
flutter run

echo All commands executed successfully!
pause

