import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/time_slot_manager.dart';
import '../services/schedule_sync_service.dart';

class CalendarScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const CalendarScheduleScreen({super.key, required this.doctorData});

  @override
  State<CalendarScheduleScreen> createState() => _CalendarScheduleScreenState();
}

class _CalendarScheduleScreenState extends State<CalendarScheduleScreen> {
  late final ValueNotifier<List<DateTime>> _selectedDays;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, dynamic> _doctorSchedule = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedDays = ValueNotifier(_getSelectedDaysFromSchedule());
    _loadDoctorSchedule();
  }

  @override
  void dispose() {
    _selectedDays.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorSchedule() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorData['id'])
          .get();

      if (doc.exists) {
        setState(() {
          _doctorSchedule = doc.data()?['detailedSchedule'] ?? {};
          _selectedDays.value = _getSelectedDaysFromSchedule();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading schedule: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<DateTime> _getSelectedDaysFromSchedule() {
    List<DateTime> selectedDays = [];
    _doctorSchedule.forEach((dateStr, dayData) {
      try {
        final date = DateTime.parse(dateStr);
        if (dayData['isWorking'] == true) {
          selectedDays.add(date);
        }
      } catch (e) {
        // Invalid date format, skip
      }
    });
    return selectedDays;
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isDaySelected(DateTime day) {
    final dateKey = _formatDateKey(day);
    return _doctorSchedule[dateKey]?['isWorking'] == true;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    _showTimeSlotManager(selectedDay);
  }

  void _showTimeSlotManager(DateTime selectedDate) {
    final dateKey = _formatDateKey(selectedDate);
    final dayData = _doctorSchedule[dateKey] ?? {
      'isWorking': false,
      'timeSlots': [],
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          height: 700,
          padding: const EdgeInsets.all(16),
          child: TimeSlotManager(
            selectedDate: selectedDate,
            initialData: dayData,
            doctorId: widget.doctorData['id'],
            onSave: (updatedData) async {
              await _saveDaySchedule(dateKey, updatedData);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveDaySchedule(String dateKey, Map<String, dynamic> dayData) async {
    try {
      setState(() {
        _doctorSchedule[dateKey] = dayData;
        _selectedDays.value = _getSelectedDaysFromSchedule();
      });

      // Save to detailed schedule
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorData['id'])
          .update({
        'detailedSchedule.$dateKey': dayData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Sync to booking system immediately
      print('🔄 Syncing schedule to booking system...');
      await ScheduleSyncService.syncScheduleToBookingSystem(
        widget.doctorData['id'],
        {dateKey: dayData},
      );
      print('✅ Schedule synced successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الجدول  ومزامنته بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving/syncing schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ الجدول: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الجدول - التقويم'),
        backgroundColor: const Color(0xFF6c547b),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDoctorSchedule,
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ValueListenableBuilder<List<DateTime>>(
                valueListenable: _selectedDays,
                builder: (context, selectedDays, _) {
                  return TableCalendar<DateTime>(
                    firstDay: DateTime.now().subtract(const Duration(days: 30)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    eventLoader: (day) {
                      return _isDaySelected(day) ? [day] : [];
                    },
                    startingDayOfWeek: StartingDayOfWeek.saturday,
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Colors.red),
                      holidayTextStyle: TextStyle(color: Colors.red),
                      markerDecoration: BoxDecoration(
                        color: Color(0xFF6c547b),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: Color(0xFF6c547b),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      formatButtonTextStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onDaySelected: _onDaySelected,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  );
                },
              ),
            ),
          ),

          // Instructions
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF6c547b)),
                        SizedBox(width: 8),
                        Text(
                          'تعليمات الاستخدام',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• اضغط على أي يوم في التقويم لإدارة أوقات العمل'),
                    Text('• الأيام المحددة للعمل تظهر بنقطة ملونة'),
                    Text('• يمكنك إضافة عدة فترات زمنية لنفس اليوم'),
                    Text('• سيتم مزامنة الجدول مع تطبيق موعدك تلقائياً'),
                  ],
                ),
              ),
            ),
          ),

          // Current schedule summary
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.schedule, color: Color(0xFF6c547b)),
                          SizedBox(width: 8),
                          Text(
                            'ملخص الجدول الحالي',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildScheduleSummary(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSummary() {
    if (_doctorSchedule.isEmpty) {
      return const Center(
        child: Text(
          'لم يتم تحديد أي أوقات عمل بعد\nاضغط على أي يوم في التقويم للبدء',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    final workingDays = _doctorSchedule.entries
        .where((entry) => entry.value['isWorking'] == true)
        .toList();

    if (workingDays.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أيام عمل محددة',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: workingDays.length,
      itemBuilder: (context, index) {
        final entry = workingDays[index];
        final dateKey = entry.key;
        final dayData = entry.value;
        final timeSlots = dayData['timeSlots'] as List? ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Color(0xFF6c547b)),
            title: Text(dateKey),
            subtitle: Text('${timeSlots.length} فترة زمنية'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                try {
                  final date = DateTime.parse(dateKey);
                  _showTimeSlotManager(date);
                } catch (e) {
                  // Invalid date format
                }
              },
            ),
          ),
        );
      },
    );
  }
}
