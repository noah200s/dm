// 🔍 Firebase Web Compatibility Verification Script
// Run with: dart run verify_compatibility.dart

import 'dart:io';

void main() async {
  print('🔍 Firebase Web Compatibility Verification');
  print('==========================================');
  
  // Check Dart SDK version
  await checkDartSDK();
  
  // Check Flutter version  
  await checkFlutterVersion();
  
  // Check pubspec.yaml
  await checkPubspecYaml();
  
  // Check for problematic files
  await checkProblematicFiles();
  
  // Verify dependencies
  await verifyDependencies();
  
  print('\n🎯 Verification complete!');
}

Future<void> checkDartSDK() async {
  print('\n📋 Checking Dart SDK...');
  
  try {
    final result = await Process.run('dart', ['--version']);
    final version = result.stdout.toString();
    print('✅ Dart SDK: $version');
    
    if (version.contains('3.4.1')) {
      print('✅ Compatible Dart SDK version detected');
    } else if (version.contains('3.5') || version.contains('3.6') || version.contains('3.7') || version.contains('3.8')) {
      print('⚠️  Newer Dart SDK detected - Firebase versions can be upgraded');
    } else {
      print('❌ Unexpected Dart SDK version');
    }
  } catch (e) {
    print('❌ Error checking Dart SDK: $e');
  }
}

Future<void> checkFlutterVersion() async {
  print('\n📋 Checking Flutter version...');
  
  try {
    final result = await Process.run('flutter', ['--version']);
    final version = result.stdout.toString();
    print('✅ Flutter: ${version.split('\n')[0]}');
  } catch (e) {
    print('❌ Error checking Flutter version: $e');
  }
}

Future<void> checkPubspecYaml() async {
  print('\n📋 Checking pubspec.yaml...');
  
  try {
    final file = File('pubspec.yaml');
    if (!file.existsSync()) {
      print('❌ pubspec.yaml not found');
      return;
    }
    
    final content = await file.readAsString();
    
    // Check SDK constraint
    if (content.contains("sdk: '>=3.0.0 <4.0.0'")) {
      print('✅ SDK constraint is compatible');
    } else {
      print('❌ SDK constraint may be incompatible');
    }
    
    // Check Firebase versions
    final firebaseVersions = {
      'firebase_core': '2.17.0',
      'firebase_auth': '4.10.1', 
      'cloud_firestore': '4.9.3',
    };
    
    for (final entry in firebaseVersions.entries) {
      if (content.contains('${entry.key}: ^${entry.value}')) {
        print('✅ ${entry.key}: Compatible version found');
      } else {
        print('⚠️  ${entry.key}: Version may need adjustment');
      }
    }
    
  } catch (e) {
    print('❌ Error reading pubspec.yaml: $e');
  }
}

Future<void> checkProblematicFiles() async {
  print('\n📋 Checking for problematic code patterns...');
  
  // Check app_theme.dart
  try {
    final themeFile = File('lib/core/app_theme.dart');
    if (themeFile.existsSync()) {
      final content = await themeFile.readAsString();
      
      if (content.contains('CardThemeData(')) {
        print('✅ app_theme.dart: CardThemeData usage is correct');
      } else if (content.contains('CardTheme(')) {
        print('❌ app_theme.dart: CardTheme should be CardThemeData');
      } else {
        print('⚠️  app_theme.dart: No CardTheme usage found');
      }
    }
  } catch (e) {
    print('❌ Error checking app_theme.dart: $e');
  }
  
  // Check for handleThenable usage (shouldn't exist in our code)
  try {
    final result = await Process.run('grep', ['-r', 'handleThenable', 'lib/']);
    if (result.exitCode == 0) {
      print('❌ handleThenable found in source code - this should not exist');
      print(result.stdout);
    } else {
      print('✅ No handleThenable usage in source code');
    }
  } catch (e) {
    // grep not found or no matches - this is good
    print('✅ No handleThenable usage detected');
  }
}

Future<void> verifyDependencies() async {
  print('\n📋 Verifying dependency resolution...');
  
  try {
    // Check if pubspec.lock exists
    final lockFile = File('pubspec.lock');
    if (!lockFile.existsSync()) {
      print('⚠️  pubspec.lock not found - run flutter pub get first');
      return;
    }
    
    final lockContent = await lockFile.readAsString();
    
    // Check firebase_auth_web version
    final authWebMatch = RegExp(r'firebase_auth_web:\s*dependency: transitive\s*description:.*?version: "([^"]+)"', 
                               dotAll: true).firstMatch(lockContent);
    
    if (authWebMatch != null) {
      final version = authWebMatch.group(1)!;
      print('📦 firebase_auth_web version: $version');
      
      if (version.startsWith('4.')) {
        print('✅ firebase_auth_web 4.x.x - Compatible with Dart 3.4.1');
      } else if (version.startsWith('5.')) {
        print('❌ firebase_auth_web 5.x.x - Will cause handleThenable errors');
        print('💡 Solution: Downgrade firebase_auth to ^4.8.0 or ^4.6.3');
      } else {
        print('⚠️  Unexpected firebase_auth_web version');
      }
    } else {
      print('⚠️  Could not determine firebase_auth_web version');
    }
    
    // Check other critical packages
    final packages = ['firebase_core_web', 'cloud_firestore_web'];
    for (final package in packages) {
      if (lockContent.contains('$package:')) {
        print('✅ $package: Present in dependencies');
      } else {
        print('⚠️  $package: Not found in dependencies');
      }
    }
    
  } catch (e) {
    print('❌ Error verifying dependencies: $e');
  }
}
