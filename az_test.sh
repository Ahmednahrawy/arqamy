@echo off
echo Running Flutter commands...

echo "##########analyzing project..."
flutter analyze

echo "#########Testing..."
flutter test

echo All commands executed successfully!
pause