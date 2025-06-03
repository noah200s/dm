@echo off
REM 🚨 Nuclear Firebase Fix for Windows
REM This script completely resets Firebase dependencies

echo 🚀 Starting NUCLEAR Firebase fix...

REM Step 1: Complete cleanup
echo 📦 Step 1: Nuclear cleanup...
flutter clean
if exist .dart_tool rmdir /s /q .dart_tool
if exist .packages del .packages
if exist pubspec.lock del pubspec.lock
if exist build rmdir /s /q build

REM Step 2: Clear problematic packages from cache
echo 🧹 Step 2: Clearing problematic packages from cache...
if exist "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\firebase_auth_web-5.*" (
    rmdir /s /q "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\firebase_auth_web-5.*"
)
if exist "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\firebase_auth_platform_interface-6.16.*" (
    rmdir /s /q "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\firebase_auth_platform_interface-6.16.*"
)

echo ✅ Nuclear cleanup completed

REM Step 3: Get dependencies with strict versions
echo 📦 Step 3: Getting dependencies with STRICT version control...
flutter pub get

if %ERRORLEVEL% neq 0 (
    echo ❌ pub get failed! Trying cache repair...
    flutter pub cache repair
    flutter pub get
    
    if %ERRORLEVEL% neq 0 (
        echo ❌ Still failing! Manual intervention needed.
        echo 🔧 Try these commands manually:
        echo    flutter pub cache clean
        echo    flutter pub get
        pause
        exit /b 1
    )
)

echo ✅ Dependencies resolved successfully

REM Step 4: Verify critical versions
echo 🔍 Step 4: Verifying critical package versions...
flutter pub deps | findstr firebase_auth_web
flutter pub deps | findstr firebase_auth_platform_interface

REM Step 5: Test compilation
echo 🏗️ Step 5: Testing web compilation...
flutter build web --release

if %ERRORLEVEL% eq 0 (
    echo ✅ SUCCESS! Web build completed without errors
    echo 🎉 Firebase handleThenable issues are resolved!
    echo.
    echo 📊 Build summary:
    echo   - Web files generated in: build\web\
    echo   - Ready for deployment
    echo.
    echo 🧪 Test the build:
    echo   cd build\web
    echo   python -m http.server 8000
    echo   Open: http://localhost:8000
) else (
    echo ❌ Build failed. Check the error messages above.
    echo.
    echo 🔍 Common issues:
    echo   - Check if firebase_auth_web is still 5.x.x
    echo   - Verify dependency_overrides in pubspec.yaml
    echo   - Try: flutter pub deps ^| findstr firebase
    echo.
    pause
    exit /b 1
)

echo.
echo 🎯 Nuclear fix completed successfully!
pause
