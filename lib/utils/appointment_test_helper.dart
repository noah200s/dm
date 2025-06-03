import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';

/// مساعد لاختبار نظام المواعيد
class AppointmentTestHelper {
  /// إنشاء موعد تجريبي
  static Future<String?> createTestAppointment({
    required BuildContext context,
    required String doctorId,
    required String patientId,
    String? patientName,
    String? patientPhone,
    String? patientAge,
  }) async {
    try {
      // بيانات تجريبية افتراضية
      final testPatientName = patientName ?? 'مريض تجريبي';
      final testPatientPhone = patientPhone ?? '07701234567';
      final testPatientAge = patientAge ?? '30';
      
      // تاريخ ووقت تجريبي (غداً الساعة 10:00)
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final testDate = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      const testTime = '10:00';

      print('🧪 إنشاء موعد تجريبي:');
      print('   الطبيب: $doctorId');
      print('   المريض: $testPatientName');
      print('   التاريخ: $testDate');
      print('   الوقت: $testTime');

      final appointmentId = await AppointmentService.createAppointmentWithRetry(
        doctorId: doctorId,
        patientId: patientId,
        patientName: testPatientName,
        patientPhone: testPatientPhone,
        patientAge: testPatientAge,
        appointmentDate: testDate,
        appointmentTime: testTime,
        notes: 'موعد تجريبي للاختبار',
        doctorInfo: {
          'name': 'د. تجريبي',
          'specialty': 'طب عام',
          'phone': '07701234567',
        },
        patientInfo: {
          'name': testPatientName,
          'phone': testPatientPhone,
          'age': testPatientAge,
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء موعد تجريبي بنجاح! ID: $appointmentId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return appointmentId;
    } catch (e) {
      print('❌ خطأ في إنشاء الموعد التجريبي: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إنشاء الموعد التجريبي: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      
      return null;
    }
  }

  /// اختبار التحقق من توفر الوقت
  static Future<void> testTimeSlotAvailability({
    required BuildContext context,
    required String doctorId,
  }) async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final testDate = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      
      final testTimes = ['09:00', '10:00', '11:00', '14:00', '15:00'];
      
      print('🔍 اختبار توفر الأوقات للطبيب $doctorId في تاريخ $testDate:');
      
      for (final time in testTimes) {
        final isAvailable = await AppointmentService.isTimeSlotAvailable(
          doctorId,
          testDate,
          time,
        );
        
        print('   $time: ${isAvailable ? "متاح ✅" : "محجوز ❌"}');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم اختبار توفر الأوقات - تحقق من وحدة التحكم للنتائج'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('❌ خطأ في اختبار توفر الأوقات: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختبار توفر الأوقات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// عرض إحصائيات المواعيد
  static Future<void> showAppointmentStats({
    required BuildContext context,
    required String doctorId,
  }) async {
    try {
      final counts = await AppointmentService.getDoctorAppointmentsCounts(doctorId);
      
      print('📊 إحصائيات المواعيد للطبيب $doctorId:');
      for (final entry in counts.entries) {
        print('   ${entry.key.arabicName}: ${entry.value}');
      }

      final total = counts.values.fold(0, (sum, count) => sum + count);
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('إحصائيات المواعيد'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...counts.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key.arabicName),
                      Text('${entry.value}'),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المجموع:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$total', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ خطأ في جلب إحصائيات المواعيد: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في جلب الإحصائيات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// اختبار شامل للنظام
  static Future<void> runFullSystemTest({
    required BuildContext context,
    required String doctorId,
    required String patientId,
  }) async {
    try {
      print('🚀 بدء الاختبار الشامل لنظام المواعيد...');
      
      // 1. اختبار توفر الأوقات
      await testTimeSlotAvailability(context: context, doctorId: doctorId);
      
      // 2. إنشاء موعد تجريبي
      final appointmentId = await createTestAppointment(
        context: context,
        doctorId: doctorId,
        patientId: patientId,
      );
      
      if (appointmentId != null) {
        // 3. اختبار جلب الموعد
        final appointment = await AppointmentService.getAppointment(appointmentId);
        if (appointment != null) {
          print('✅ تم جلب الموعد بنجاح: ${appointment.patientName}');
        }
        
        // 4. اختبار تأكيد الموعد
        await AppointmentService.confirmAppointment(appointmentId);
        print('✅ تم تأكيد الموعد بنجاح');
        
        // 5. اختبار إكمال الموعد
        await AppointmentService.completeAppointment(appointmentId);
        print('✅ تم إكمال الموعد بنجاح');
      }
      
      // 6. عرض الإحصائيات
      await showAppointmentStats(context: context, doctorId: doctorId);
      
      print('🎉 انتهى الاختبار الشامل بنجاح!');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('انتهى الاختبار الشامل بنجاح! 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ خطأ في الاختبار الشامل: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الاختبار الشامل: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// تنظيف البيانات التجريبية
  static Future<void> cleanupTestData({
    required BuildContext context,
    required String doctorId,
  }) async {
    try {
      print('🧹 تنظيف البيانات التجريبية...');
      
      // جلب جميع المواعيد التجريبية
      final appointments = await AppointmentService.getAppointmentsByDate(
        doctorId,
        DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0],
      );
      
      int deletedCount = 0;
      for (final appointment in appointments) {
        if (appointment.notes?.contains('تجريبي') == true ||
            appointment.patientName.contains('تجريبي')) {
          await AppointmentService.deleteAppointment(appointment.id);
          deletedCount++;
        }
      }
      
      print('✅ تم حذف $deletedCount موعد تجريبي');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف $deletedCount موعد تجريبي'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ خطأ في تنظيف البيانات: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تنظيف البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
