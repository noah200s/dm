import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

/// خدمة إدارة المواعيد
class AppointmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _appointmentsCollection = 'appointments';

  /// إنشاء موعد جديد
  static Future<String> createAppointment({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String patientAge,
    required String appointmentDate,
    required String appointmentTime,
    String? notes,
    Map<String, dynamic>? doctorInfo,
    Map<String, dynamic>? patientInfo,
  }) async {
    try {
      // التحقق من صحة البيانات المدخلة
      _validateAppointmentData(
        doctorId: doctorId,
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        patientAge: patientAge,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
      );

      print('📝 إنشاء موعد جديد:');
      print('   طبيب: $doctorId');
      print('   مريض: $patientName ($patientId)');
      print('   تاريخ: $appointmentDate');
      print('   وقت: $appointmentTime');

      // التحقق من توفر الوقت أولاً
      final isAvailable = await isTimeSlotAvailable(
        doctorId,
        appointmentDate,
        appointmentTime,
      );

      if (!isAvailable) {
        throw Exception('الوقت المحدد محجوز بالفعل. يرجى اختيار وقت آخر.');
      }

      // التحقق من عدم وجود موعد مكرر لنفس المريض في نفس اليوم
      final existingAppointments = await getAppointmentsByDate(doctorId, appointmentDate);
      final patientHasAppointment = existingAppointments.any((apt) =>
        apt.patientId == patientId &&
        (apt.status == AppointmentStatus.pending || apt.status == AppointmentStatus.confirmed)
      );

      if (patientHasAppointment) {
        throw Exception('لديك موعد آخر في نفس اليوم مع هذا الطبيب.');
      }

      final appointment = AppointmentModel(
        id: '', // سيتم تعيينه تلقائياً
        doctorId: doctorId,
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        patientAge: patientAge,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        notes: notes,
        status: AppointmentStatus.pending,
        createdAt: DateTime.now(),
        doctorInfo: doctorInfo,
        patientInfo: patientInfo,
      );

      final docRef = await _firestore
          .collection(_appointmentsCollection)
          .add(appointment.toFirestore());

      return docRef.id;
    } catch (e) {
      // إذا كانت الرسالة تحتوي على معلومات مفيدة، أعدها كما هي
      if (e.toString().contains('الوقت المحدد محجوز') ||
          e.toString().contains('لديك موعد آخر')) {
        rethrow;
      }
      throw Exception('خطأ في إنشاء الموعد: $e');
    }
  }

  /// الحصول على مواعيد الطبيب
  static Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return _firestore
        .collection(_appointmentsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();

          // ترتيب البيانات في الكود لتجنب الحاجة للفهرس
          appointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return appointments;
        });
  }

  /// الحصول على مواعيد المريض
  static Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    return _firestore
        .collection(_appointmentsCollection)
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();

          // ترتيب البيانات في الكود لتجنب الحاجة للفهرس
          appointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return appointments;
        });
  }

  /// تأكيد الموعد من قبل الطبيب
  static Future<void> confirmAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .update({
        'status': AppointmentStatus.confirmed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('خطأ في تأكيد الموعد: $e');
    }
  }

  /// رفض الموعد من قبل الطبيب
  static Future<void> rejectAppointment(
    String appointmentId, {
    String? rejectionReason,
  }) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .update({
        'status': AppointmentStatus.rejected.name,
        'rejectionReason': rejectionReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('خطأ في رفض الموعد: $e');
    }
  }

  /// إلغاء الموعد
  static Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .update({
        'status': AppointmentStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('خطأ في إلغاء الموعد: $e');
    }
  }

  /// تحديث حالة الموعد إلى مكتمل
  static Future<void> completeAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .update({
        'status': AppointmentStatus.completed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('خطأ في تحديث حالة الموعد: $e');
    }
  }

  /// الحصول على موعد محدد
  static Future<AppointmentModel?> getAppointment(String appointmentId) async {
    try {
      final doc = await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .get();

      if (doc.exists) {
        return AppointmentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في جلب بيانات الموعد: $e');
    }
  }

  /// الحصول على عدد المواعيد حسب الحالة للطبيب
  static Future<Map<AppointmentStatus, int>> getDoctorAppointmentsCounts(
      String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection(_appointmentsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      final counts = <AppointmentStatus, int>{};
      for (final status in AppointmentStatus.values) {
        counts[status] = 0;
      }

      for (final doc in snapshot.docs) {
        final appointment = AppointmentModel.fromFirestore(doc);
        counts[appointment.status] = (counts[appointment.status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw Exception('خطأ في جلب إحصائيات المواعيد: $e');
    }
  }

  /// الحصول على المواعيد المعلقة للطبيب
  static Stream<List<AppointmentModel>> getPendingAppointments(String doctorId) {
    return _firestore
        .collection(_appointmentsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: AppointmentStatus.pending.name)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();

          // ترتيب البيانات في الكود بدلاً من Firestore لتجنب الحاجة للفهرس
          appointments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return appointments;
        });
  }

  /// الحصول على المواعيد لتاريخ محدد
  static Future<List<AppointmentModel>> getAppointmentsByDate(
    String doctorId,
    String date,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_appointmentsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentDate', isEqualTo: date)
          .get();

      final appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();

      // ترتيب البيانات في الكود لتجنب الحاجة للفهرس
      appointments.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));

      return appointments;
    } catch (e) {
      throw Exception('خطأ في جلب مواعيد التاريخ المحدد: $e');
    }
  }

  /// التحقق من توفر الوقت
  static Future<bool> isTimeSlotAvailable(
    String doctorId,
    String date,
    String time,
  ) async {
    try {
      print('🔍 التحقق من توفر الوقت: طبيب=$doctorId، تاريخ=$date، وقت=$time');

      // استعلام بسيط بدون whereIn لتجنب الحاجة للفهرس المركب
      final snapshot = await _firestore
          .collection(_appointmentsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentDate', isEqualTo: date)
          .where('appointmentTime', isEqualTo: time)
          .get();

      // فلترة النتائج في الكود للحصول على المواعيد النشطة فقط
      final activeAppointments = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String?;
        return status == AppointmentStatus.pending.name ||
               status == AppointmentStatus.confirmed.name;
      }).toList();

      final isAvailable = activeAppointments.isEmpty;
      print('✅ نتيجة التحقق: ${isAvailable ? "متاح" : "محجوز"} (عدد المواعيد النشطة: ${activeAppointments.length})');

      if (!isAvailable) {
        print('📋 المواعيد الموجودة:');
        for (final doc in activeAppointments) {
          final data = doc.data() as Map<String, dynamic>;
          print('   - مريض: ${data['patientName']}, حالة: ${data['status']}');
        }
      }

      return isAvailable;
    } catch (e) {
      print('❌ خطأ في التحقق من توفر الوقت: $e');
      throw Exception('خطأ في التحقق من توفر الوقت: $e');
    }
  }

  /// حذف موعد
  static Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .delete();
    } catch (e) {
      throw Exception('خطأ في حذف الموعد: $e');
    }
  }

  /// التحقق من صحة بيانات الموعد
  static void _validateAppointmentData({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String patientAge,
    required String appointmentDate,
    required String appointmentTime,
  }) {
    // التحقق من الحقول المطلوبة
    if (doctorId.trim().isEmpty) {
      throw Exception('معرف الطبيب مطلوب');
    }

    if (patientId.trim().isEmpty) {
      throw Exception('معرف المريض مطلوب');
    }

    if (patientName.trim().isEmpty) {
      throw Exception('اسم المريض مطلوب');
    }

    if (patientPhone.trim().isEmpty) {
      throw Exception('رقم هاتف المريض مطلوب');
    }

    if (patientAge.trim().isEmpty) {
      throw Exception('عمر المريض مطلوب');
    }

    if (appointmentDate.trim().isEmpty) {
      throw Exception('تاريخ الموعد مطلوب');
    }

    if (appointmentTime.trim().isEmpty) {
      throw Exception('وقت الموعد مطلوب');
    }

    // التحقق من صحة رقم الهاتف
    if (patientPhone.length != 11 || !patientPhone.startsWith('07')) {
      throw Exception('رقم الهاتف يجب أن يكون 11 رقم ويبدأ بـ 07');
    }

    // التحقق من صحة العمر
    final age = int.tryParse(patientAge);
    if (age == null || age < 1 || age > 120) {
      throw Exception('العمر يجب أن يكون رقم صحيح بين 1 و 120');
    }

    // التحقق من صحة التاريخ
    try {
      final date = DateTime.parse(appointmentDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final appointmentDay = DateTime(date.year, date.month, date.day);

      if (appointmentDay.isBefore(today)) {
        throw Exception('لا يمكن حجز موعد في تاريخ سابق');
      }

      // التحقق من أن التاريخ ليس بعيداً جداً (مثلاً 6 أشهر)
      final maxDate = today.add(const Duration(days: 180));
      if (appointmentDay.isAfter(maxDate)) {
        throw Exception('لا يمكن حجز موعد بعد 6 أشهر من الآن');
      }
    } catch (e) {
      if (e.toString().contains('لا يمكن حجز موعد')) {
        rethrow;
      }
      throw Exception('تنسيق التاريخ غير صحيح');
    }

    // التحقق من صحة الوقت
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(appointmentTime)) {
      throw Exception('تنسيق الوقت غير صحيح (يجب أن يكون HH:MM)');
    }

    print('✅ تم التحقق من صحة جميع البيانات');
  }

  /// إنشاء موعد مع إعادة المحاولة
  static Future<String> createAppointmentWithRetry({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String patientAge,
    required String appointmentDate,
    required String appointmentTime,
    String? notes,
    Map<String, dynamic>? doctorInfo,
    Map<String, dynamic>? patientInfo,
    int maxRetries = 3,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        attempts++;
        print('🔄 محاولة رقم $attempts من $maxRetries');

        return await createAppointment(
          doctorId: doctorId,
          patientId: patientId,
          patientName: patientName,
          patientPhone: patientPhone,
          patientAge: patientAge,
          appointmentDate: appointmentDate,
          appointmentTime: appointmentTime,
          notes: notes,
          doctorInfo: doctorInfo,
          patientInfo: patientInfo,
        );
      } catch (e) {
        print('❌ فشلت المحاولة $attempts: $e');

        // إذا كانت المشكلة في البيانات أو الوقت محجوز، لا تعيد المحاولة
        if (e.toString().contains('الوقت المحدد محجوز') ||
            e.toString().contains('لديك موعد آخر') ||
            e.toString().contains('مطلوب') ||
            e.toString().contains('غير صحيح')) {
          rethrow;
        }

        // إذا كانت آخر محاولة، ارمي الخطأ
        if (attempts >= maxRetries) {
          rethrow;
        }

        // انتظار قصير قبل إعادة المحاولة
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }

    throw Exception('فشل في إنشاء الموعد بعد $maxRetries محاولات');
  }

  /// الحصول على مواعيد الطبيب حسب الحالة (بدون فهرس مركب)
  static Stream<List<AppointmentModel>> getDoctorAppointmentsByStatus(
    String doctorId,
    AppointmentStatus status,
  ) {
    return _firestore
        .collection(_appointmentsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();

          // ترتيب البيانات في الكود
          appointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return appointments;
        });
  }

  /// الحصول على مواعيد اليوم للطبيب
  static Stream<List<AppointmentModel>> getTodayAppointments(String doctorId) {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return _firestore
        .collection(_appointmentsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .where('appointmentDate', isEqualTo: todayString)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();

          // ترتيب حسب الوقت
          appointments.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
          return appointments;
        });
  }

  /// الحصول على المواعيد القادمة للطبيب
  static Stream<List<AppointmentModel>> getUpcomingAppointments(String doctorId) {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return _firestore
        .collection(_appointmentsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .where((apt) =>
                (apt.status == AppointmentStatus.pending || apt.status == AppointmentStatus.confirmed) &&
                apt.appointmentDate.compareTo(todayString) >= 0
              )
              .toList();

          // ترتيب حسب التاريخ والوقت
          appointments.sort((a, b) {
            final dateComparison = a.appointmentDate.compareTo(b.appointmentDate);
            if (dateComparison != 0) return dateComparison;
            return a.appointmentTime.compareTo(b.appointmentTime);
          });

          return appointments;
        });
  }
}
