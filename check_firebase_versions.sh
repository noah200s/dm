#!/bin/bash

# 🔍 Quick Firebase Version Checker
# Run this to verify Firebase versions before building

echo "🔍 Firebase Version Checker"
echo "=========================="

# Check if pubspec.lock exists
if [ ! -f "pubspec.lock" ]; then
    echo "❌ pubspec.lock not found. Run 'flutter pub get' first."
    exit 1
fi

echo ""
echo "📋 Checking critical Firebase packages..."

# Check firebase_auth_web (most critical)
AUTH_WEB_VERSION=$(grep -A 5 "firebase_auth_web:" pubspec.lock | grep "version:" | cut -d'"' -f2)
if [ -n "$AUTH_WEB_VERSION" ]; then
    echo "📦 firebase_auth_web: $AUTH_WEB_VERSION"
    
    if [[ $AUTH_WEB_VERSION == 5.* ]]; then
        echo "❌ CRITICAL: firebase_auth_web 5.x.x will cause handleThenable errors!"
        echo "💡 Fix: Add dependency_overrides in pubspec.yaml"
        echo "   firebase_auth_web: 4.6.3"
        exit 1
    elif [[ $AUTH_WEB_VERSION == 4.6.3 ]]; then
        echo "✅ PERFECT: firebase_auth_web 4.6.3 (handleThenable-free)"
    elif [[ $AUTH_WEB_VERSION == 4.* ]]; then
        echo "✅ GOOD: firebase_auth_web 4.x.x (should work)"
    else
        echo "⚠️  UNKNOWN: Unexpected firebase_auth_web version"
    fi
else
    echo "❌ firebase_auth_web not found in pubspec.lock"
fi

# Check firebase_core
CORE_VERSION=$(grep -A 5 "firebase_core:" pubspec.lock | grep "version:" | cut -d'"' -f2)
if [ -n "$CORE_VERSION" ]; then
    echo "📦 firebase_core: $CORE_VERSION"
    if [[ $CORE_VERSION == 2.15.0 ]]; then
        echo "✅ PERFECT: firebase_core 2.15.0"
    elif [[ $CORE_VERSION == 2.* ]]; then
        echo "✅ GOOD: firebase_core 2.x.x"
    else
        echo "⚠️  WARNING: firebase_core version may be too new"
    fi
else
    echo "❌ firebase_core not found"
fi

# Check firebase_auth
AUTH_VERSION=$(grep -A 5 "firebase_auth:" pubspec.lock | grep "version:" | cut -d'"' -f2)
if [ -n "$AUTH_VERSION" ]; then
    echo "📦 firebase_auth: $AUTH_VERSION"
    if [[ $AUTH_VERSION == 4.6.3 ]]; then
        echo "✅ PERFECT: firebase_auth 4.6.3"
    elif [[ $AUTH_VERSION == 4.* ]]; then
        echo "✅ GOOD: firebase_auth 4.x.x"
    else
        echo "⚠️  WARNING: firebase_auth version may cause issues"
    fi
else
    echo "❌ firebase_auth not found"
fi

# Check cloud_firestore
FIRESTORE_VERSION=$(grep -A 5 "cloud_firestore:" pubspec.lock | grep "version:" | cut -d'"' -f2)
if [ -n "$FIRESTORE_VERSION" ]; then
    echo "📦 cloud_firestore: $FIRESTORE_VERSION"
    if [[ $FIRESTORE_VERSION == 4.8.0 ]]; then
        echo "✅ PERFECT: cloud_firestore 4.8.0"
    elif [[ $FIRESTORE_VERSION == 4.* ]]; then
        echo "✅ GOOD: cloud_firestore 4.x.x"
    else
        echo "⚠️  WARNING: cloud_firestore version may be incompatible"
    fi
else
    echo "❌ cloud_firestore not found"
fi

echo ""
echo "🎯 Summary:"

# Overall assessment
if [[ $AUTH_WEB_VERSION == 5.* ]]; then
    echo "❌ WILL FAIL: firebase_auth_web 5.x.x detected"
    echo "🔧 Action needed: Fix dependency_overrides in pubspec.yaml"
    exit 1
elif [[ $AUTH_WEB_VERSION == 4.6.3 ]]; then
    echo "✅ READY TO BUILD: All versions are optimal"
    echo "🚀 Safe to run: flutter build web --release"
elif [[ $AUTH_WEB_VERSION == 4.* ]]; then
    echo "✅ SHOULD WORK: firebase_auth_web 4.x.x detected"
    echo "🚀 Try: flutter build web --release"
else
    echo "⚠️  UNKNOWN STATUS: Manual verification needed"
    echo "🔍 Check: flutter pub deps | grep firebase_auth_web"
fi

echo ""
echo "📋 Quick commands:"
echo "  Check deps: flutter pub deps | grep firebase"
echo "  Clean build: flutter clean && flutter pub get"
echo "  Test build: flutter build web --release"
