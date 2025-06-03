import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/calendar_schedule_screen.dart';

class ScheduleCard extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const ScheduleCard({super.key, required this.doctorData});

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  Map<String, dynamic> _schedule = {};

  @override
  void initState() {
    super.initState();
    _schedule = Map<String, dynamic>.from(
      widget.doctorData['schedule'] ?? {},
    );
  }





  @override
  Widget build(BuildContext context) {
    return Card(
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
                  'إدارة الجدول',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Current schedule summary
            Expanded(
              child: Column(
                children: [
                  Text(
                    'أيام العمل: ${_getWorkingDaysCount()}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ساعات العمل: ${_getWorkingHours()}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),

                  // Calendar button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CalendarScheduleScreen(
                              doctorData: widget.doctorData,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('التقويم المتقدم'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6c547b),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getWorkingDaysCount() {
    return _schedule.values
        .where((day) => day['isWorking'] == true)
        .length;
  }

  String _getWorkingHours() {
    final workingDays = _schedule.values
        .where((day) => day['isWorking'] == true)
        .toList();
    
    if (workingDays.isEmpty) return 'غير محدد';
    
    final firstDay = workingDays.first;
    return '${firstDay['startTime']} - ${firstDay['endTime']}';
  }
}
