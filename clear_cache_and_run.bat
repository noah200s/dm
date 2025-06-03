@echo off
echo 🧹 مسح الذاكرة المؤقتة وإعادة تشغيل التطبيق...
echo.

echo 📦 تنظيف مشروع Flutter...
flutter clean

echo 🗂️ حذف ملفات الذاكرة المؤقتة...
if exist ".dart_tool" rmdir /s /q ".dart_tool"
if exist "build" rmdir /s /q "build"
if exist "pubspec.lock" del "pubspec.lock"

echo 📥 تحديث التبعيات...
flutter pub get

echo 🚀 تشغيل التطبيق على الويب...
echo.
echo ⚠️  ملاحظة: بعد فتح التطبيق، اضغط Ctrl+F5 لإعادة تحميل الصفحة بدون ذاكرة مؤقتة
echo.

flutter run -d chrome --web-port=8080
