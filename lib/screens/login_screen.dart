import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testFirebaseConnection() async {
    try {
      print('🔥 Testing Firebase connection...');

      // Test Firestore connection
      final testQuery = await FirebaseFirestore.instance
          .collection('doctors')
          .limit(1)
          .get();

      print('✅ Firestore connection successful');
      print('📊 Found ${testQuery.docs.length} documents in doctors collection');

      // Test Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      print('👤 Current user: ${currentUser?.email ?? 'None'}');

      print('🔥 Firebase setup is working correctly');
    } catch (e) {
      print('❌ Firebase connection test failed: $e');
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 Starting login process...');
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      print('📝 Username/Email: $username');
      print('🔑 Password length: ${password.length}');

      // Find user by username or email in Firestore
      String? email;

      if (username.contains('@')) {
        // It's an email
        email = username;
        print('📧 Using email directly: $email');
      } else {
        // It's a username, find the email
        print('👤 Looking up username in Firestore: $username');

        final querySnapshot = await FirebaseFirestore.instance
            .collection('doctors')
            .where('username', isEqualTo: username.toLowerCase())
            .limit(1)
            .get();

        print('📊 Firestore query returned ${querySnapshot.docs.length} documents');

        if (querySnapshot.docs.isEmpty) {
          print('❌ No user found with username: $username');
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'لا يوجد مستخدم بهذا الاسم',
          );
        }

        final doctorData = querySnapshot.docs.first.data();
        email = doctorData['email'] as String?;

        print('📧 Found email for username $username: $email');
        print('📄 Doctor data keys: ${doctorData.keys.toList()}');

        if (email == null || email.isEmpty) {
          print('❌ Email is null or empty for user: $username');
          throw FirebaseAuthException(
            code: 'invalid-email',
            message: ' البريد الإلكتروني غير صحيح للمستخدم',
          );
        }
      }

      // Validate email format
      if (!email.contains('@') || !email.contains('.')) {
        print('❌ Invalid email format: $email');
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'تنسيق البريد الإلكتروني غير صحيح',
        );
      }

      print('🔑 Attempting Firebase Auth sign in with email: $email');

      // Sign in with Firebase Auth
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase Auth sign in successful!');
      print('👤 User UID: ${userCredential.user?.uid}');
      print('📧 User email: ${userCredential.user?.email}');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الدخول بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } on FirebaseAuthException catch (e) {
      print('🚨 Firebase Auth error: ${e.code} - ${e.message}');
      String message = 'حدث خطأ في تسجيل الدخول';

      switch (e.code) {
        case 'user-not-found':
          message = 'لا يوجد مستخدم بهذا البريد الإلكتروني أو اسم المستخدم';
          break;
        case 'wrong-password':
          message = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          message = 'البريد الإلكتروني غير صحيح';
          break;
        case 'invalid-credential':
          message = 'بيانات تسجيل الدخول غير صحيحة - تحقق من اسم المستخدم وكلمة المرور';
          break;
        case 'too-many-requests':
          message = 'تم حظر الطلبات مؤقتاً. انتظر قليلاً ثم حاول مرة أخرى';
          break;
        case 'network-request-failed':
          message = 'فشل في الاتصال بالشبكة. تحقق من اتصال الإنترنت';
          break;
        case 'user-disabled':
          message = 'تم تعطيل هذا الحساب. اتصل بالدعم الفني';
          break;
        default:
          message = e.message ?? 'حدث خطأ غير متوقع';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('💥 Unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ غير متوقع: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _testWithKnownUser() async {
    try {
      print('🧪 Testing with known user...');

      // Get all users from Firestore to see what's available
      final allUsers = await FirebaseFirestore.instance
          .collection('doctors')
          .limit(5)
          .get();

      print('📊 Found ${allUsers.docs.length} users in Firestore:');
      for (final doc in allUsers.docs) {
        final data = doc.data();
        print('👤 User: ${data['username']} - Email: ${data['email']}');
      }

      if (allUsers.docs.isNotEmpty) {
        final firstUser = allUsers.docs.first.data();
        final username = firstUser['username'];
        final email = firstUser['email'];

        _usernameController.text = username ?? '';
        _passwordController.text = 'test123'; // Default test password

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تعبئة البيانات للمستخدم: $username'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Test failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الاختبار: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6c547b),
              Color(0xFF8b6f9b),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo and title
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6c547b),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'موعدك',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6c547b),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'لوحة تحكم الأطباء',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Username field
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'اسم المستخدم أو البريد الإلكتروني',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال اسم المستخدم أو البريد الإلكتروني';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال كلمة المرور';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Test button for debugging
                        TextButton(
                          onPressed: _isLoading ? null : _testWithKnownUser,
                          child: const Text(
                            'اختبار مع مستخدم معروف',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
