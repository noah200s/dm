import 'package:flutter/material.dart';
import '../services/schedule_sync_service.dart';

class TimeSlotManager extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onSave;
  final String? doctorId;

  const TimeSlotManager({
    super.key,
    required this.selectedDate,
    required this.initialData,
    required this.onSave,
    this.doctorId,
  });

  @override
  State<TimeSlotManager> createState() => _TimeSlotManagerState();
}

class _TimeSlotManagerState extends State<TimeSlotManager> {
  bool _isWorking = false;
  List<Map<String, String>> _timeSlots = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _isWorking = widget.initialData['isWorking'] ?? false;
    _timeSlots = List<Map<String, String>>.from(
      (widget.initialData['timeSlots'] as List?)?.map((slot) => 
        Map<String, String>.from(slot)) ?? []
    );
    
    // Add default slot if working but no slots exist
    if (_isWorking && _timeSlots.isEmpty) {
      _timeSlots.add({'startTime': '09:00', 'endTime': '17:00'});
    }
  }

  void _addTimeSlot() {
    setState(() {
      _timeSlots.add({'startTime': '09:00', 'endTime': '17:00'});
    });
  }

  void _removeTimeSlot(int index) {
    setState(() {
      _timeSlots.removeAt(index);
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    const weekdays = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
    ];
    
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'isWorking': _isWorking,
        'timeSlots': _isWorking ? _timeSlots : [],
      };

      // Save the schedule
      widget.onSave(data);

      // Sync to booking system if doctorId is provided
      if (widget.doctorId != null) {
        try {
          // Create a temporary schedule map for sync
          final dateKey = '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';
          final tempSchedule = {dateKey: data};

          await ScheduleSyncService.syncScheduleToBookingSystem(
            widget.doctorId!,
            tempSchedule,
          );
        } catch (e) {
          print('Error syncing schedule: $e');
        }
      }
    }
  }

  Widget _buildTimeSlotCard(int index) {
    final slot = _timeSlots[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'الفترة ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (_timeSlots.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeTimeSlot(index),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: 'من',
                    value: slot['startTime']!,
                    onChanged: (value) {
                      setState(() {
                        _timeSlots[index]['startTime'] = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeField(
                    label: 'إلى',
                    value: slot['endTime']!,
                    onChanged: (value) {
                      setState(() {
                        _timeSlots[index]['endTime'] = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: int.parse(value.split(':')[0]),
                minute: int.parse(value.split(':')[1]),
              ),
            );
            if (time != null) {
              final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              onChanged(formattedTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF6c547b)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إدارة أوقات العمل',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDate(widget.selectedDate),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Working day toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.work, color: Color(0xFF6c547b)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'يوم عمل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: _isWorking,
                    onChanged: (value) {
                      setState(() {
                        _isWorking = value;
                        if (value && _timeSlots.isEmpty) {
                          _timeSlots.add({'startTime': '09:00', 'endTime': '17:00'});
                        }
                      });
                    },
                    activeColor: const Color(0xFF6c547b),
                  ),
                ],
              ),
            ),
          ),

          if (_isWorking) ...[
            const SizedBox(height: 16),
            
            // Time slots header
            Row(
              children: [
                const Text(
                  'الفترات الزمنية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addTimeSlot,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة فترة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6c547b),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Time slots list
            Expanded(
              child: _timeSlots.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد فترات زمنية\nاضغط "إضافة فترة" للبدء',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _timeSlots.length,
                      itemBuilder: (context, index) {
                        return _buildTimeSlotCard(index);
                      },
                    ),
            ),
          ] else ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.free_breakfast,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'يوم راحة',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'فعّل "يوم عمل" لإضافة أوقات العمل',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Action buttons
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6c547b),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
