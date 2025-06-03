import 'package:cloud_firestore/cloud_firestore.dart';

/// حالات الموعد
enum AppointmentStatus {
  pending('قيد الانتظار'),
  confirmed('مؤكد'),
  rejected('مرفوض'),
  completed('مكتمل'),
  cancelled('ملغي');

  const AppointmentStatus(this.arabicName);
  final String arabicName;
}

/// نموذج بيانات الموعد
class AppointmentModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String patientAge;
  final String appointmentDate;
  final String appointmentTime;
  final String? notes;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;
  final Map<String, dynamic>? doctorInfo;
  final Map<String, dynamic>? patientInfo;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.patientAge,
    required this.appointmentDate,
    required this.appointmentTime,
    this.notes,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.rejectionReason,
    this.doctorInfo,
    this.patientInfo,
  });

  /// تحويل من Firestore Document
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AppointmentModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientPhone: data['patientPhone'] ?? '',
      patientAge: data['patientAge'] ?? '',
      appointmentDate: data['appointmentDate'] ?? '',
      appointmentTime: data['appointmentTime'] ?? '',
      notes: data['notes'],
      status: _parseStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason'],
      doctorInfo: data['doctorInfo'] as Map<String, dynamic>?,
      patientInfo: data['patientInfo'] as Map<String, dynamic>?,
    );
  }

  /// تحويل إلى Map للحفظ في Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientAge': patientAge,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'notes': notes,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'rejectionReason': rejectionReason,
      'doctorInfo': doctorInfo,
      'patientInfo': patientInfo,
    };
  }

  /// نسخ مع تعديل بعض الحقول
  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? patientName,
    String? patientPhone,
    String? patientAge,
    String? appointmentDate,
    String? appointmentTime,
    String? notes,
    AppointmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? rejectionReason,
    Map<String, dynamic>? doctorInfo,
    Map<String, dynamic>? patientInfo,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientAge: patientAge ?? this.patientAge,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      doctorInfo: doctorInfo ?? this.doctorInfo,
      patientInfo: patientInfo ?? this.patientInfo,
    );
  }

  /// تحليل حالة الموعد من النص
  static AppointmentStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'rejected':
        return AppointmentStatus.rejected;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  /// الحصول على لون الحالة
  static String getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return '#FFA500'; // برتقالي
      case AppointmentStatus.confirmed:
        return '#28A745'; // أخضر
      case AppointmentStatus.rejected:
        return '#DC3545'; // أحمر
      case AppointmentStatus.completed:
        return '#007BFF'; // أزرق
      case AppointmentStatus.cancelled:
        return '#6C757D'; // رمادي
    }
  }

  /// الحصول على أيقونة الحالة
  static String getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return '⏳';
      case AppointmentStatus.confirmed:
        return '✅';
      case AppointmentStatus.rejected:
        return '❌';
      case AppointmentStatus.completed:
        return '✔️';
      case AppointmentStatus.cancelled:
        return '🚫';
    }
  }

  /// التحقق من إمكانية تعديل الموعد
  bool get canBeModified {
    return status == AppointmentStatus.pending;
  }

  /// التحقق من إمكانية إلغاء الموعد
  bool get canBeCancelled {
    return status == AppointmentStatus.pending || status == AppointmentStatus.confirmed;
  }

  /// الحصول على تاريخ ووقت الموعد مجمعين
  String get fullDateTime {
    return '$appointmentDate - $appointmentTime';
  }

  /// التحقق من انتهاء صلاحية الموعد
  bool get isExpired {
    try {
      final appointmentDateTime = DateTime.parse('$appointmentDate $appointmentTime');
      return appointmentDateTime.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() {
    return 'AppointmentModel(id: $id, patientName: $patientName, status: ${status.arabicName}, date: $appointmentDate, time: $appointmentTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppointmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
