import 'package:flutter/material.dart';
import '../screens/appointments_screen.dart';
import '../services/schedule_sync_service.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';
import '../widgets/common/app_card.dart';
import '../core/design_system.dart';

class AppointmentsCard extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const AppointmentsCard({super.key, required this.doctorData});

  @override
  State<AppointmentsCard> createState() => _AppointmentsCardState();
}

class _AppointmentsCardState extends State<AppointmentsCard> {
  int _todayAppointments = 0;
  int _tomorrowAppointments = 0;
  int _pendingAppointments = 0;
  int _confirmedAppointments = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointmentCounts();
  }

  Future<void> _loadAppointmentCounts() async {
    try {
      // تحميل إحصائيات المواعيد الجديدة
      final counts = await AppointmentService.getDoctorAppointmentsCounts(
        widget.doctorData['id'],
      );

      // تحميل المواعيد القديمة للمقارنة
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      final todayKey = _formatDateKey(today);
      final tomorrowKey = _formatDateKey(tomorrow);

      final todayAppointments = await ScheduleSyncService.getDoctorAppointments(
        widget.doctorData['id'],
        todayKey,
      );

      final tomorrowAppointments = await ScheduleSyncService.getDoctorAppointments(
        widget.doctorData['id'],
        tomorrowKey,
      );

      setState(() {
        _todayAppointments = todayAppointments.length;
        _tomorrowAppointments = tomorrowAppointments.length;
        _pendingAppointments = counts[AppointmentStatus.pending] ?? 0;
        _confirmedAppointments = counts[AppointmentStatus.confirmed] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading appointment counts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AppointmentsScreen(
              doctorData: widget.doctorData,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.spaceSM),
                decoration: BoxDecoration(
                  color: AppDesignSystem.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
                ),
                child: Icon(
                  Icons.event,
                  color: AppDesignSystem.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDesignSystem.spaceMD),
              Expanded(
                child: Text(
                  'المواعيد',
                  style: AppDesignSystem.headingSM,
                ),
              ),
              if (_pendingAppointments > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.spaceSM,
                    vertical: AppDesignSystem.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesignSystem.warningColor,
                    borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
                  ),
                  child: Text(
                    '$_pendingAppointments',
                    style: AppDesignSystem.bodySM.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.spaceLG),

          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppDesignSystem.primaryColor,
                ),
              ),
            )
          else ...[
            // إحصائيات المواعيد
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'قيد الانتظار',
                    _pendingAppointments.toString(),
                    AppDesignSystem.warningColor,
                    Icons.pending_actions,
                  ),
                ),
                const SizedBox(width: AppDesignSystem.spaceSM),
                Expanded(
                  child: _buildStatItem(
                    'مؤكدة',
                    _confirmedAppointments.toString(),
                    AppDesignSystem.successColor,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDesignSystem.spaceMD),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'اليوم',
                    _todayAppointments.toString(),
                    AppDesignSystem.primaryColor,
                    Icons.today,
                  ),
                ),
                const SizedBox(width: AppDesignSystem.spaceSM),
                Expanded(
                  child: _buildStatItem(
                    'غداً',
                    _tomorrowAppointments.toString(),
                    AppDesignSystem.secondaryColor,
                    Icons.event_available,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.spaceSM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: AppDesignSystem.spaceXS),
          Text(
            value,
            style: AppDesignSystem.headingSM.copyWith(
              color: color,
              fontSize: AppDesignSystem.fontSizeLG,
            ),
          ),
          Text(
            label,
            style: AppDesignSystem.caption.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
