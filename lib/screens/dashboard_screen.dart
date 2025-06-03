import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/status_card.dart';
import '../widgets/appointments_card.dart';
import '../widgets/profile_card.dart';
import '../widgets/schedule_card.dart';
import '../widgets/capacity_card.dart';
import '../widgets/layout/responsive_layout.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_button.dart';
import '../core/design_system.dart';
import '../utils/appointment_test_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _doctorData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    if (_currentUser == null) return;

    try {
      // Find doctor by email
      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('email', isEqualTo: _currentUser!.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _doctorData = querySnapshot.docs.first.data();
          _doctorData!['id'] = querySnapshot.docs.first.id;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading doctor data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppDesignSystem.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppDesignSystem.primaryColor,
            ),
          ),
        ),
      );
    }

    if (_doctorData == null) {
      return Scaffold(
        backgroundColor: AppDesignSystem.backgroundColor,
        appBar: ResponsiveAppBar(
          title: 'لوحة التحكم',
          actions: [
            AppIconButton(
              icon: Icons.logout,
              onPressed: _signOut,
              tooltip: 'تسجيل الخروج',
            ),
            const SizedBox(width: AppDesignSystem.spaceMD),
          ],
        ),
        body: ResponsiveLayout(
          child: Center(
            child: EmptyCard(
              title: 'لم يتم العثور على بيانات الطبيب',
              subtitle: 'يرجى التأكد من تسجيل الدخول بالحساب الصحيح',
              icon: Icons.person_off,
              action: AppButton(
                text: 'إعادة المحاولة',
                onPressed: _loadDoctorData,
                icon: Icons.refresh,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundColor,
      appBar: ResponsiveAppBar(
        title: 'مرحباً د. ${_doctorData!['name'] ?? 'الطبيب'}',
        actions: [
          AppIconButton(
            icon: Icons.bug_report,
            onPressed: () => _testAppointmentSystem(),
            tooltip: 'اختبار نظام المواعيد',
            backgroundColor: Colors.orange.withOpacity(0.1),
            iconColor: Colors.orange,
          ),
          const SizedBox(width: AppDesignSystem.spaceSM),
          AppIconButton(
            icon: Icons.refresh,
            onPressed: _loadDoctorData,
            tooltip: 'تحديث البيانات',
          ),
          const SizedBox(width: AppDesignSystem.spaceSM),
          AppIconButton(
            icon: Icons.logout,
            onPressed: _signOut,
            tooltip: 'تسجيل الخروج',
          ),
          const SizedBox(width: AppDesignSystem.spaceMD),
        ],
      ),
      body: ResponsiveLayout(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              _buildWelcomeCard(),
              const SizedBox(height: AppDesignSystem.spaceXL),

              // Dashboard Cards
              PageSection(
                title: 'لوحة التحكم',
                subtitle: 'إدارة عيادتك ومواعيدك',
                child: ResponsiveGrid(
                  children: [
                    StatusCard(doctorData: _doctorData!),
                    ProfileCard(doctorData: _doctorData!),
                    ScheduleCard(doctorData: _doctorData!),
                    AppointmentsCard(doctorData: _doctorData!),
                    CapacityCard(doctorData: _doctorData!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final doctorName = _doctorData!['name']?.toString() ?? 'الطبيب';
    final specialty = _doctorData!['specialty']?.toString() ?? 'طب عام';
    final status = _doctorData!['currentStatus']?.toString() ?? 'غير متاح';

    return AppCard(
      child: Row(
        children: [
          // Doctor Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppDesignSystem.primaryColor,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
              gradient: LinearGradient(
                colors: [
                  AppDesignSystem.primaryColor,
                  AppDesignSystem.secondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                doctorName.substring(0, 1),
                style: AppDesignSystem.headingLG.copyWith(
                  color: Colors.white,
                  fontSize: AppDesignSystem.getResponsiveFontSize(
                    context,
                    AppDesignSystem.fontSize2XL,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDesignSystem.spaceLG),

          // Doctor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'د. $doctorName',
                  style: AppDesignSystem.headingLG.copyWith(
                    fontSize: AppDesignSystem.getResponsiveFontSize(
                      context,
                      AppDesignSystem.fontSize2XL,
                    ),
                  ),
                ),
                const SizedBox(height: AppDesignSystem.spaceXS),
                Text(
                  specialty,
                  style: AppDesignSystem.bodyLG.copyWith(
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDesignSystem.spaceSM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.spaceMD,
                    vertical: AppDesignSystem.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
                  ),
                  child: Text(
                    status,
                    style: AppDesignSystem.bodySM.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'متاح':
        return AppDesignSystem.successColor;
      case 'مشغول':
        return AppDesignSystem.warningColor;
      case 'في إجازة':
        return AppDesignSystem.infoColor;
      default:
        return AppDesignSystem.errorColor;
    }
  }

  /// اختبار نظام المواعيد
  Future<void> _testAppointmentSystem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختبار نظام المواعيد'),
        content: const Text(
          'هل تريد تشغيل اختبار شامل لنظام المواعيد؟\n\n'
          'سيتم إنشاء موعد تجريبي واختبار جميع الوظائف.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تشغيل الاختبار'),
          ),
        ],
      ),
    );

    if (confirmed == true && _doctorData != null) {
      await AppointmentTestHelper.runFullSystemTest(
        context: context,
        doctorId: _doctorData!['id'],
        patientId: 'test_patient_123', // معرف مريض تجريبي
      );
    }
  }
}
