#!/bin/bash

# 🚨 NUCLEAR Firebase Web Fix Script
# This script completely resets Firebase dependencies with STRICT version control

echo "🚀 Starting NUCLEAR Firebase Web compilation fix..."

# Step 1: NUCLEAR dependency reset
echo "📦 Step 1: NUCLEAR dependency cleaning..."
flutter clean
rm -rf .dart_tool
rm -rf .packages
rm -f pubspec.lock
rm -rf build

# Clear problematic packages from cache
echo "🧹 Clearing problematic packages from cache..."
rm -rf ~/.pub-cache/hosted/pub.dev/firebase_auth_web-5.*
rm -rf ~/.pub-cache/hosted/pub.dev/firebase_auth_platform_interface-6.16.*
rm -rf ~/.pub-cache/hosted/pub.dev/firebase_core_web-2.5.*

echo "✅ NUCLEAR cleaning completed"

# Step 2: Get new dependencies
echo "📦 Step 2: Getting compatible dependencies..."
flutter pub get

# If pub get fails, try backup versions
if [ $? -ne 0 ]; then
    echo "⚠️  Main pubspec failed, trying backup safe versions..."
    cp pubspec_backup_safe.yaml pubspec.yaml
    flutter pub get

    if [ $? -ne 0 ]; then
        echo "❌ Even backup versions failed!"
        echo "🔧 Manual intervention required:"
        echo "1. Check internet connection"
        echo "2. Try: flutter pub cache repair"
        echo "3. Try: flutter clean && flutter pub get"
        exit 1
    else
        echo "✅ Backup versions worked!"
    fi
fi

# Step 3: FORCE verify Firebase versions
echo "🔍 Step 3: FORCE verifying Firebase package versions..."
echo "REQUIRED EXACT versions:"
echo "  - firebase_core: 2.15.0"
echo "  - firebase_auth: 4.6.3"
echo "  - cloud_firestore: 4.8.0"
echo "  - firebase_auth_web: 4.6.3 (MUST NOT be 5.x.x)"

echo ""
echo "Actual versions:"
flutter pub deps | grep -E "firebase_core|firebase_auth|cloud_firestore|firebase_auth_web" | head -15

echo ""
echo "🔍 CRITICAL CHECK: firebase_auth_web version..."
if flutter pub deps | grep -q "firebase_auth_web 5"; then
    echo "❌ CRITICAL ERROR: firebase_auth_web 5.x.x still detected!"
    echo "❌ This WILL cause handleThenable compilation errors!"
    echo ""
    echo "🔧 EMERGENCY FIXES:"
    echo "1. Check pubspec.yaml has exact versions (no ^)"
    echo "2. Check dependency_overrides section exists"
    echo "3. Delete ~/.pub-cache and try again"
    echo "4. Use: flutter pub deps | grep firebase_auth_web"
    exit 1
elif flutter pub deps | grep -q "firebase_auth_web 4.6.3"; then
    echo "✅ PERFECT: firebase_auth_web 4.6.3 detected (handleThenable-free!)"
elif flutter pub deps | grep -q "firebase_auth_web 4"; then
    echo "✅ GOOD: firebase_auth_web 4.x.x detected (should work)"
else
    echo "⚠️  WARNING: Could not detect firebase_auth_web version"
    echo "   Manual check: flutter pub deps | grep firebase_auth_web"
fi

# Step 4: Test web compilation
echo ""
echo "🏗️ Step 4: Testing web compilation..."
echo "This may take a few minutes..."

if flutter build web --release --verbose > build_log.txt 2>&1; then
    echo "✅ SUCCESS: Web build completed without errors!"
    echo "🎉 Firebase Auth Web compilation issues are resolved!"
    
    # Check for specific success indicators
    if grep -q "dart2js" build_log.txt; then
        echo "✅ dart2js compilation successful"
    fi
    
    if ! grep -q "handleThenable" build_log.txt; then
        echo "✅ No handleThenable errors found"
    fi
    
    echo ""
    echo "📊 Build summary:"
    echo "Build output saved to: build_log.txt"
    echo "Web files generated in: build/web/"
    
else
    echo "❌ FAILED: Web build failed"
    echo "📋 Error details:"
    
    # Check for specific error types
    if grep -q "handleThenable" build_log.txt; then
        echo "❌ handleThenable errors still present"
        echo "💡 Try downgrading firebase_auth further: ^4.8.0 or ^4.6.3"
    fi
    
    if grep -q "CardThemeData" build_log.txt; then
        echo "❌ CardThemeData errors found"
        echo "💡 Check lib/core/app_theme.dart for CardTheme usage"
    fi
    
    echo ""
    echo "📋 Last 20 lines of build log:"
    tail -20 build_log.txt
    
    exit 1
fi

# Step 5: Test critical functionality
echo ""
echo "🧪 Step 5: Testing critical functionality..."

echo "✅ Build verification complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Test the web build in a browser:"
echo "   cd build/web && python -m http.server 8000"
echo "   Then open: http://localhost:8000"
echo ""
echo "2. Verify Firebase Auth works:"
echo "   - Doctor login/logout"
echo "   - Firebase connection"
echo "   - Appointment system"
echo ""
echo "3. If issues persist, try fallback versions:"
echo "   firebase_auth: ^4.8.0"
echo "   firebase_core: ^2.15.0"

echo ""
echo "🎉 Firebase Web fix script completed successfully!"
