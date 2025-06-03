# 🏥 دليل تكامل نظام المواعيد

## 📋 نظرة عامة
تم تطوير نظام إدارة المواعيد المتكامل الذي يربط بين تطبيق إدارة الطبيب وتطبيق موعدك للمرضى.

## 🔄 تدفق العمل

### 1. حجز الموعد (من تطبيق موعدك)
```dart
// في تطبيق موعدك - عند تأكيد الحجز
final appointmentId = await AppointmentService.createAppointment(
  doctorId: selectedDoctor.id,
  patientId: currentUser.uid,
  patientName: patientName,
  patientPhone: patientPhone,
  patientAge: patientAge,
  appointmentDate: selectedDate,
  appointmentTime: selectedTime,
  notes: notes,
  doctorInfo: {
    'name': selectedDoctor.name,
    'specialty': selectedDoctor.specialty,
    'phone': selectedDoctor.phone,
  },
  patientInfo: {
    'name': patientName,
    'phone': patientPhone,
    'age': patientAge,
  },
);
```

### 2. إدارة المواعيد (من تطبيق إدارة الطبيب)
- **تأكيد الموعد**: `AppointmentService.confirmAppointment(appointmentId)`
- **رفض الموعد**: `AppointmentService.rejectAppointment(appointmentId, rejectionReason)`
- **إكمال الموعد**: `AppointmentService.completeAppointment(appointmentId)`

### 3. عرض المواعيد للمريض (في تطبيق موعدك)
```dart
// في صفحة "مواعيدي" في تطبيق موعدك
StreamBuilder<List<AppointmentModel>>(
  stream: AppointmentService.getPatientAppointments(currentUser.uid),
  builder: (context, snapshot) {
    final appointments = snapshot.data ?? [];
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AppointmentCard(appointment: appointment);
      },
    );
  },
);
```

## 📱 التغييرات المطلوبة في تطبيق موعدك

### 1. إضافة نموذج البيانات
```dart
// أضف ملف lib/models/appointment_model.dart
// (نفس الملف الموجود في تطبيق إدارة الطبيب)
```

### 2. إضافة خدمة المواعيد
```dart
// أضف ملف lib/services/appointment_service.dart
// (نفس الملف الموجود في تطبيق إدارة الطبيب)
```

### 3. تحديث شاشة الحجز
```dart
// في شاشة تأكيد الحجز
class BookingConfirmationScreen extends StatelessWidget {
  // ... الكود الحالي

  Future<void> _confirmBooking() async {
    try {
      // إنشاء الموعد في النظام الجديد
      final appointmentId = await AppointmentService.createAppointment(
        doctorId: widget.doctor.id,
        patientId: FirebaseAuth.instance.currentUser!.uid,
        patientName: _nameController.text,
        patientPhone: _phoneController.text,
        patientAge: _ageController.text,
        appointmentDate: widget.selectedDate,
        appointmentTime: widget.selectedTime,
        notes: _notesController.text,
        doctorInfo: {
          'name': widget.doctor.name,
          'specialty': widget.doctor.specialty,
          'phone': widget.doctor.phone,
          'consultationFee': widget.doctor.consultationFee,
        },
      );

      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حجز الموعد بنجاح! في انتظار تأكيد الطبيب'),
          backgroundColor: Colors.green,
        ),
      );

      // الانتقال إلى صفحة المواعيد
      Navigator.pushReplacementNamed(context, '/my-appointments');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حجز الموعد: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### 4. إنشاء صفحة "مواعيدي"
```dart
// أضف ملف lib/screens/my_appointments_screen.dart
class MyAppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواعيدي'),
      ),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: AppointmentService.getPatientAppointments(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('خطأ: ${snapshot.error}'),
            );
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد مواعيد'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              return PatientAppointmentCard(
                appointment: appointments[index],
              );
            },
          );
        },
      ),
    );
  }
}
```

### 5. إنشاء كارد الموعد للمريض
```dart
// أضف ملف lib/widgets/patient_appointment_card.dart
class PatientAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const PatientAppointmentCard({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطبيب
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF6c547b),
                  child: Text(
                    appointment.doctorInfo?['name']?.substring(0, 1) ?? 'د',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'د. ${appointment.doctorInfo?['name'] ?? 'غير محدد'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appointment.doctorInfo?['specialty'] ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(appointment.status),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // تاريخ ووقت الموعد
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(appointment.appointmentDate),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(appointment.appointmentTime),
              ],
            ),
            
            // رسالة الحالة
            const SizedBox(height: 12),
            _buildStatusMessage(appointment),
            
            // سبب الرفض إن وجد
            if (appointment.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سبب الرفض: ${appointment.rejectionReason}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // أزرار الإجراءات
            if (appointment.canBeCancelled) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelAppointment(context, appointment),
                  icon: const Icon(Icons.cancel),
                  label: const Text('إلغاء الموعد'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(AppointmentStatus status) {
    Color color;
    String text = status.arabicName;
    
    switch (status) {
      case AppointmentStatus.pending:
        color = Colors.orange;
        break;
      case AppointmentStatus.confirmed:
        color = Colors.green;
        break;
      case AppointmentStatus.rejected:
        color = Colors.red;
        break;
      case AppointmentStatus.completed:
        color = Colors.blue;
        break;
      case AppointmentStatus.cancelled:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusMessage(AppointmentModel appointment) {
    String message;
    Color color;
    IconData icon;

    switch (appointment.status) {
      case AppointmentStatus.pending:
        message = 'في انتظار رد الطبيب بالتأكيد';
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case AppointmentStatus.confirmed:
        message = 'تم تأكيد الموعد من قبل الطبيب';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case AppointmentStatus.rejected:
        message = 'تم رفض الموعد من قبل الطبيب';
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case AppointmentStatus.completed:
        message = 'تم إكمال الموعد';
        color = Colors.blue;
        icon = Icons.done_all;
        break;
      case AppointmentStatus.cancelled:
        message = 'تم إلغاء الموعد';
        color = Colors.grey;
        icon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAppointment(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الموعد'),
        content: const Text('هل أنت متأكد من إلغاء هذا الموعد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AppointmentService.cancelAppointment(appointment.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء الموعد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إلغاء الموعد: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

## 🔧 خطوات التنفيذ

### 1. في تطبيق موعدك:
1. أضف الملفات المطلوبة (models, services, screens, widgets)
2. حدث شاشة الحجز لاستخدام النظام الجديد
3. أضف صفحة "مواعيدي" إلى التنقل الرئيسي
4. اختبر التكامل مع تطبيق إدارة الطبيب

### 2. في تطبيق إدارة الطبيب:
✅ تم تنفيذ جميع الميزات المطلوبة:
- نموذج بيانات المواعيد
- خدمة إدارة المواعيد
- شاشة إدارة المواعيد مع التبويبات
- تأكيد/رفض/إكمال المواعيد
- إحصائيات المواعيد في لوحة التحكم

## 🎯 الميزات المتاحة

### للطبيب:
- ✅ عرض جميع المواعيد مقسمة حسب الحالة
- ✅ تأكيد المواعيد المعلقة
- ✅ رفض المواعيد مع إمكانية إضافة سبب
- ✅ إكمال المواعيد المؤكدة
- ✅ إحصائيات فورية في لوحة التحكم
- ✅ تصميم متجاوب وحديث

### للمريض:
- 📋 عرض جميع المواعيد مع حالاتها
- 📋 رسائل واضحة لكل حالة موعد
- 📋 إمكانية إلغاء المواعيد المناسبة
- 📋 عرض سبب الرفض إن وجد
- 📋 تحديثات فورية عند تغيير حالة الموعد

## 🔄 التحديثات الفورية
النظام يستخدم Firebase Firestore Streams لضمان التحديثات الفورية:
- عند تأكيد/رفض الطبيب للموعد، يظهر التحديث فوراً للمريض
- عند حجز موعد جديد، يظهر فوراً في تطبيق إدارة الطبيب
- الإحصائيات تتحدث تلقائياً

## 🎨 التصميم
- استخدام نظام التصميم الموحد
- ألوان متسقة مع هوية التطبيق
- تصميم متجاوب لجميع أحجام الشاشات
- واجهة سهلة الاستخدام ومفهومة
