@echo off
REM 🧪 Test Firebase Versions Step by Step

echo 🧪 Testing Firebase versions step by step...

REM Step 1: Clean everything
echo 📦 Step 1: Cleaning project...
flutter clean
if exist .dart_tool rmdir /s /q .dart_tool
if exist pubspec.lock del pubspec.lock

REM Step 2: Try main pubspec.yaml
echo 📦 Step 2: Testing main pubspec.yaml...
flutter pub get

if %ERRORLEVEL% eq 0 (
    echo ✅ Main pubspec.yaml worked!
    goto :check_versions
) else (
    echo ❌ Main pubspec.yaml failed, trying minimal version...
    
    REM Step 3: Try minimal version
    copy pubspec_minimal.yaml pubspec.yaml
    flutter pub get
    
    if %ERRORLEVEL% eq 0 (
        echo ✅ Minimal pubspec.yaml worked!
        goto :check_versions
    ) else (
        echo ❌ Even minimal version failed!
        echo 🔧 Manual intervention needed:
        echo    1. Check internet connection
        echo    2. Try: flutter pub cache repair
        echo    3. Try: flutter doctor
        pause
        exit /b 1
    )
)

:check_versions
echo.
echo 🔍 Checking Firebase versions...
flutter pub deps | findstr firebase_auth_web
flutter pub deps | findstr firebase_auth_platform_interface
flutter pub deps | findstr firebase_core

echo.
echo 🏗️ Testing web build...
flutter build web --release

if %ERRORLEVEL% eq 0 (
    echo.
    echo ✅ SUCCESS! All tests passed!
    echo 🎉 Firebase is now working correctly!
    echo.
    echo 📊 Summary:
    flutter pub deps | findstr "firebase_auth_web\|firebase_core\|cloud_firestore" | findstr -v "platform_interface"
    echo.
    echo 🚀 Ready for deployment!
) else (
    echo.
    echo ❌ Build failed. Checking for specific errors...
    
    REM Check for specific error types
    flutter build web --release 2>&1 | findstr "handleThenable" > nul
    if %ERRORLEVEL% eq 0 (
        echo ❌ handleThenable errors detected
        echo 💡 firebase_auth_web version is still too new
        echo    Try even older versions: firebase_auth: 3.11.0
    )
    
    flutter build web --release 2>&1 | findstr "emailVerified" > nul
    if %ERRORLEVEL% eq 0 (
        echo ❌ Platform interface errors detected
        echo 💡 Version mismatch between packages
        echo    Check dependency_overrides in pubspec.yaml
    )
    
    echo.
    echo 🔧 Suggested fixes:
    echo    1. Use even older Firebase versions
    echo    2. Remove dependency_overrides completely
    echo    3. Check Flutter/Dart SDK versions
    pause
    exit /b 1
)

echo.
echo 🎯 Test completed successfully!
pause
