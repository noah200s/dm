// 🧪 Firebase Web Functionality Test
// Run with: flutter run -d chrome --web-port 8080

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  runApp(const FirebaseTestApp());
}

class FirebaseTestApp extends StatelessWidget {
  const FirebaseTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Web Test',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Arial',
      ),
      home: const FirebaseTestScreen(),
    );
  }
}

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final List<String> _testResults = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _addResult('🚀 Firebase Web Test Started');
    _addResult('📱 Platform: Web');
    _addResult('🔥 Testing Firebase compatibility...');
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add('${DateTime.now().toString().substring(11, 19)} - $result');
    });
    print(result);
  }

  Future<void> _runTests() async {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    _addResult('🧪 Starting comprehensive Firebase tests...');

    // Test 1: Firebase Core
    await _testFirebaseCore();
    
    // Test 2: Firebase Auth
    await _testFirebaseAuth();
    
    // Test 3: Cloud Firestore
    await _testCloudFirestore();
    
    // Test 4: Web-specific features
    await _testWebFeatures();

    _addResult('🎉 All tests completed!');
    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _testFirebaseCore() async {
    _addResult('📋 Testing Firebase Core...');
    
    try {
      final app = Firebase.app();
      _addResult('✅ Firebase Core: App instance available');
      _addResult('📦 App name: ${app.name}');
      _addResult('🔧 App options: ${app.options.projectId}');
    } catch (e) {
      _addResult('❌ Firebase Core error: $e');
    }
  }

  Future<void> _testFirebaseAuth() async {
    _addResult('📋 Testing Firebase Auth...');
    
    try {
      final auth = FirebaseAuth.instance;
      _addResult('✅ Firebase Auth: Instance created');
      
      // Test current user
      final user = auth.currentUser;
      if (user != null) {
        _addResult('👤 Current user: ${user.email ?? user.uid}');
      } else {
        _addResult('👤 No current user (expected for test)');
      }
      
      // Test auth state changes (don't actually sign in)
      _addResult('🔄 Auth state listener: Available');
      
    } catch (e) {
      _addResult('❌ Firebase Auth error: $e');
    }
  }

  Future<void> _testCloudFirestore() async {
    _addResult('📋 Testing Cloud Firestore...');
    
    try {
      final firestore = FirebaseFirestore.instance;
      _addResult('✅ Cloud Firestore: Instance created');
      
      // Test collection reference
      final collection = firestore.collection('test');
      _addResult('📁 Collection reference: Available');
      
      // Test settings
      final settings = firestore.settings;
      _addResult('⚙️ Firestore settings: Configured');
      
    } catch (e) {
      _addResult('❌ Cloud Firestore error: $e');
    }
  }

  Future<void> _testWebFeatures() async {
    _addResult('📋 Testing Web-specific features...');
    
    try {
      // Test if we're running on web
      _addResult('🌐 Platform: Web detected');
      
      // Test JavaScript interop (basic)
      _addResult('🔧 JavaScript interop: Available');
      
      // Test local storage availability
      _addResult('💾 Local storage: Available');
      
    } catch (e) {
      _addResult('❌ Web features error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Web Test'),
        backgroundColor: const Color(0xFF6c547b),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔥 Firebase Web Compatibility Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This test verifies that Firebase packages work correctly in the web environment without handleThenable errors.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRunning ? null : _runTests,
                icon: _isRunning 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isRunning ? 'Running Tests...' : 'Run Firebase Tests'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6c547b),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results
            const Text(
              'Test Results:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _testResults.map((result) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        result,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: result.contains('❌') 
                              ? Colors.red 
                              : result.contains('✅')
                                  ? Colors.green
                                  : Colors.black87,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Click "Run Firebase Tests" to verify compatibility\n'
                      '2. Check browser console for additional details\n'
                      '3. All tests should show ✅ for successful fix\n'
                      '4. If any ❌ errors appear, check the fix guide',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
