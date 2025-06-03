#!/bin/bash

echo "🧹 مسح الذاكرة المؤقتة وإعادة تشغيل التطبيق..."
echo

echo "📦 تنظيف مشروع Flutter..."
flutter clean

echo "🗂️ حذف ملفات الذاكرة المؤقتة..."
rm -rf .dart_tool
rm -rf build
rm -f pubspec.lock

echo "📥 تحديث التبعيات..."
flutter pub get

echo "🚀 تشغيل التطبيق على الويب..."
echo
echo "⚠️  ملاحظة: بعد فتح التطبيق، اضغط Ctrl+F5 لإعادة تحميل الصفحة بدون ذاكرة مؤقتة"
echo

flutter run -d chrome --web-port=8080
