import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/schedule_sync_service.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../widgets/layout/responsive_layout.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_button.dart';
import '../core/design_system.dart';

class AppointmentsScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const AppointmentsScreen({super.key, required this.doctorData});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dateKey = _formatDateKey(_selectedDate);
      final appointments = await ScheduleSyncService.getDoctorAppointments(
        widget.doctorData['id'],
        dateKey,
      );

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    const weekdays = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
    ];
    
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      _loadAppointments();
    }
  }

  // دوال إدارة المواعيد الجديدة
  Future<void> _confirmAppointment(AppointmentModel appointment) async {
    try {
      await AppointmentService.confirmAppointment(appointment.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تأكيد موعد ${appointment.patientName}'),
          backgroundColor: AppDesignSystem.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تأكيد الموعد: $e'),
          backgroundColor: AppDesignSystem.errorColor,
        ),
      );
    }
  }

  Future<void> _rejectAppointment(AppointmentModel appointment) async {
    final reason = await _showRejectDialog();
    if (reason != null) {
      try {
        await AppointmentService.rejectAppointment(
          appointment.id,
          rejectionReason: reason,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم رفض موعد ${appointment.patientName}'),
            backgroundColor: AppDesignSystem.errorColor,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفض الموعد: $e'),
            backgroundColor: AppDesignSystem.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _completeAppointment(AppointmentModel appointment) async {
    final confirmed = await _showConfirmDialog(
      'إكمال الموعد',
      'هل تم إكمال موعد ${appointment.patientName}؟',
    );

    if (confirmed) {
      try {
        await AppointmentService.completeAppointment(appointment.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إكمال موعد ${appointment.patientName}'),
            backgroundColor: AppDesignSystem.successColor,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إكمال الموعد: $e'),
            backgroundColor: AppDesignSystem.errorColor,
          ),
        );
      }
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الموعد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال سبب رفض الموعد:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'سبب الرفض...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.errorColor,
            ),
            child: const Text('رفض الموعد'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _cancelAppointment(Map<String, dynamic> appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الموعد'),
        content: Text(
          'هل أنت متأكد من إلغاء موعد ${appointment['patientName']} في ${appointment['startTime']}؟'
        ),
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
        final dateKey = _formatDateKey(_selectedDate);
        final success = await ScheduleSyncService.cancelBooking(
          widget.doctorData['id'],
          dateKey,
          appointment['startTime'],
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء الموعد بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAppointments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في إلغاء الموعد'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundColor,
      appBar: ResponsiveAppBar(
        title: 'إدارة المواعيد',
        actions: [
          AppIconButton(
            icon: Icons.refresh,
            onPressed: _loadAppointments,
            tooltip: 'تحديث',
          ),
          const SizedBox(width: AppDesignSystem.spaceMD),
        ],
      ),
      body: ResponsiveLayout(
        child: Column(
          children: [
            // إحصائيات سريعة
            _buildQuickStats(),
            const SizedBox(height: AppDesignSystem.spaceLG),

            // تبويبات المواعيد
            _buildTabBar(),

            // محتوى التبويبات
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPendingAppointments(),
                  _buildConfirmedAppointments(),
                  _buildCompletedAppointments(),
                  _buildAllAppointments(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دوال بناء الواجهة الجديدة
  Widget _buildQuickStats() {
    return FutureBuilder<Map<AppointmentStatus, int>>(
      future: AppointmentService.getDoctorAppointmentsCounts(widget.doctorData['id']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final counts = snapshot.data!;
        return ResponsiveGrid(
          forceColumns: 4,
          childAspectRatio: 2.5,
          children: [
            StatCard(
              title: 'قيد الانتظار',
              value: '${counts[AppointmentStatus.pending] ?? 0}',
              icon: Icons.pending_actions,
              iconColor: AppDesignSystem.warningColor,
            ),
            StatCard(
              title: 'مؤكدة',
              value: '${counts[AppointmentStatus.confirmed] ?? 0}',
              icon: Icons.check_circle,
              iconColor: AppDesignSystem.successColor,
            ),
            StatCard(
              title: 'مكتملة',
              value: '${counts[AppointmentStatus.completed] ?? 0}',
              icon: Icons.done_all,
              iconColor: AppDesignSystem.infoColor,
            ),
            StatCard(
              title: 'المجموع',
              value: '${counts.values.fold(0, (sum, count) => sum + count)}',
              icon: Icons.calendar_month,
              iconColor: AppDesignSystem.primaryColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: AppDesignSystem.cardDecoration,
      child: TabBar(
        controller: _tabController,
        labelColor: AppDesignSystem.primaryColor,
        unselectedLabelColor: AppDesignSystem.textMuted,
        indicatorColor: AppDesignSystem.primaryColor,
        labelStyle: AppDesignSystem.bodySM.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'قيد الانتظار'),
          Tab(text: 'مؤكدة'),
          Tab(text: 'مكتملة'),
          Tab(text: 'جميع المواعيد'),
        ],
      ),
    );
  }

  Widget _buildPendingAppointments() {
    return StreamBuilder<List<AppointmentModel>>(
      stream: AppointmentService.getPendingAppointments(widget.doctorData['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return _buildEmptyWidget('لا توجد مواعيد قيد الانتظار');
        }

        return _buildAppointmentsList(appointments, showActions: true);
      },
    );
  }

  Widget _buildConfirmedAppointments() {
    return StreamBuilder<List<AppointmentModel>>(
      stream: AppointmentService.getDoctorAppointments(widget.doctorData['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final allAppointments = snapshot.data ?? [];
        final confirmedAppointments = allAppointments
            .where((apt) => apt.status == AppointmentStatus.confirmed)
            .toList();

        if (confirmedAppointments.isEmpty) {
          return _buildEmptyWidget('لا توجد مواعيد مؤكدة');
        }

        return _buildAppointmentsList(confirmedAppointments, showCompleteAction: true);
      },
    );
  }

  Widget _buildCompletedAppointments() {
    return StreamBuilder<List<AppointmentModel>>(
      stream: AppointmentService.getDoctorAppointments(widget.doctorData['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final allAppointments = snapshot.data ?? [];
        final completedAppointments = allAppointments
            .where((apt) => apt.status == AppointmentStatus.completed)
            .toList();

        if (completedAppointments.isEmpty) {
          return _buildEmptyWidget('لا توجد مواعيد مكتملة');
        }

        return _buildAppointmentsList(completedAppointments);
      },
    );
  }

  Widget _buildAllAppointments() {
    return StreamBuilder<List<AppointmentModel>>(
      stream: AppointmentService.getDoctorAppointments(widget.doctorData['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return _buildEmptyWidget('لا توجد مواعيد');
        }

        return _buildAppointmentsList(appointments);
      },
    );
  }

  Widget _buildAppointmentsList(
    List<AppointmentModel> appointments, {
    bool showActions = false,
    bool showCompleteAction = false,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDesignSystem.spaceMD),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildNewAppointmentCard(
          appointment,
          showActions: showActions,
          showCompleteAction: showCompleteAction,
        );
      },
    );
  }

  Widget _buildNewAppointmentCard(
    AppointmentModel appointment, {
    bool showActions = false,
    bool showCompleteAction = false,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppDesignSystem.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات المريض والموعد
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: AppDesignSystem.headingSM,
                    ),
                    const SizedBox(height: AppDesignSystem.spaceXS),
                    Text(
                      'الهاتف: ${appointment.patientPhone}',
                      style: AppDesignSystem.bodySM,
                    ),
                    Text(
                      'العمر: ${appointment.patientAge} سنة',
                      style: AppDesignSystem.bodySM,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.spaceSM,
                  vertical: AppDesignSystem.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status),
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
                ),
                child: Text(
                  appointment.status.arabicName,
                  style: AppDesignSystem.bodySM.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDesignSystem.spaceMD),

          // تاريخ ووقت الموعد
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppDesignSystem.textMuted,
              ),
              const SizedBox(width: AppDesignSystem.spaceXS),
              Text(
                appointment.appointmentDate,
                style: AppDesignSystem.bodySM,
              ),
              const SizedBox(width: AppDesignSystem.spaceMD),
              Icon(
                Icons.access_time,
                size: 16,
                color: AppDesignSystem.textMuted,
              ),
              const SizedBox(width: AppDesignSystem.spaceXS),
              Text(
                appointment.appointmentTime,
                style: AppDesignSystem.bodySM,
              ),
            ],
          ),

          // الملاحظات
          if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDesignSystem.spaceSM),
            Text(
              'ملاحظات: ${appointment.notes}',
              style: AppDesignSystem.bodySM.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // سبب الرفض
          if (appointment.rejectionReason != null) ...[
            const SizedBox(height: AppDesignSystem.spaceSM),
            Container(
              padding: const EdgeInsets.all(AppDesignSystem.spaceSM),
              decoration: BoxDecoration(
                color: AppDesignSystem.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM),
              ),
              child: Text(
                'سبب الرفض: ${appointment.rejectionReason}',
                style: AppDesignSystem.bodySM.copyWith(
                  color: AppDesignSystem.errorColor,
                ),
              ),
            ),
          ],

          // أزرار الإجراءات
          if (showActions || showCompleteAction) ...[
            const SizedBox(height: AppDesignSystem.spaceMD),
            _buildActionButtons(appointment, showActions, showCompleteAction),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    AppointmentModel appointment,
    bool showActions,
    bool showCompleteAction,
  ) {
    return ResponsiveRow(
      children: [
        if (showActions) ...[
          AppButton(
            text: 'تأكيد',
            onPressed: () => _confirmAppointment(appointment),
            icon: Icons.check,
            type: AppButtonType.primary,
            size: AppButtonSize.small,
          ),
          AppButton(
            text: 'رفض',
            onPressed: () => _rejectAppointment(appointment),
            icon: Icons.close,
            type: AppButtonType.outline,
            size: AppButtonSize.small,
            textColor: AppDesignSystem.errorColor,
          ),
        ],
        if (showCompleteAction) ...[
          AppButton(
            text: 'إكمال الموعد',
            onPressed: () => _completeAppointment(appointment),
            icon: Icons.done_all,
            type: AppButtonType.secondary,
            size: AppButtonSize.small,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          AppDesignSystem.primaryColor,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: EmptyCard(
        title: 'خطأ في تحميل البيانات',
        subtitle: error,
        icon: Icons.error,
        action: AppButton(
          text: 'إعادة المحاولة',
          onPressed: _loadAppointments,
          icon: Icons.refresh,
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Center(
      child: EmptyCard(
        title: message,
        icon: Icons.event_busy,
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppDesignSystem.warningColor;
      case AppointmentStatus.confirmed:
        return AppDesignSystem.successColor;
      case AppointmentStatus.rejected:
        return AppDesignSystem.errorColor;
      case AppointmentStatus.completed:
        return AppDesignSystem.infoColor;
      case AppointmentStatus.cancelled:
        return AppDesignSystem.textMuted;
    }
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6c547b),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${appointment['startTime']} - ${appointment['endTime']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 8),
                          Text('إلغاء الموعد'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'cancel') {
                      _cancelAppointment(appointment);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF6c547b)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment['patientName'] ?? 'غير محدد',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (appointment['patientPhone'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, color: Color(0xFF6c547b)),
                  const SizedBox(width: 8),
                  Text(
                    appointment['patientPhone'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'موعد مؤكد',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
