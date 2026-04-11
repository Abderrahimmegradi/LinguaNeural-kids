@echo off
REM Audio Directory Setup Script for lingua_neural_kids_app

echo.
echo ====================================================
echo   Creating Audio Directory Structure
echo ====================================================
echo.

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo ERROR: pubspec.yaml not found!
    echo Please run this script from the project root directory
    pause
    exit /b 1
)

REM Create audio directories
echo Creating audio directories...

mkdir "assets" 2>nul
mkdir "assets\audio" 2>nul
mkdir "assets\audio\ui" 2>nul
mkdir "assets\audio\feedback" 2>nul
mkdir "assets\audio\celebration" 2>nul
mkdir "assets\audio\ambient" 2>nul

if exist "assets\audio\ui" (
    echo ✓ assets/audio/ui created
)
if exist "assets\audio\feedback" (
    echo ✓ assets/audio/feedback created
)
if exist "assets\audio\celebration" (
    echo ✓ assets/audio/celebration created
)
if exist "assets\audio\ambient" (
    echo ✓ assets/audio/ambient created
)

echo.
echo ====================================================
echo   Directory Structure Created Successfully!
echo ====================================================
echo.
echo Next Steps:
echo 1. Download audio files from zapsplat.com or mixkit.co
echo 2. Place them in the corresponding folders:
echo    - assets/audio/ui/ → tap.mp3, success.mp3, error.mp3, swipe.mp3
echo    - assets/audio/feedback/ → correct_answer.mp3, wrong_answer.mp3, etc.
echo    - assets/audio/celebration/ → lesson_complete.mp3, perfect_score.mp3, etc.
echo 3. Run: flutter clean
echo 4. Run: flutter pub get
echo 5. Run: flutter run
echo.
echo Character voices (TTS) work automatically without any downloads!
echo.
pause
