import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CapacityCard extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const CapacityCard({super.key, required this.doctorData});

  @override
  State<CapacityCard> createState() => _CapacityCardState();
}

class _CapacityCardState extends State<CapacityCard> {
  bool _isUpdating = false;
  final _dailyCapacityController = TextEditingController();
  final _hourlyCapacityController = TextEditingController();
  final _appointmentDurationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dailyCapacityController.text = 
        widget.doctorData['dailyCapacity']?.toString() ?? '20';
    _hourlyCapacityController.text = 
        widget.doctorData['hourlyCapacity']?.toString() ?? '4';
    _appointmentDurationController.text = 
        widget.doctorData['appointmentDuration']?.toString() ?? '15';
  }

  @override
  void dispose() {
    _dailyCapacityController.dispose();
    _hourlyCapacityController.dispose();
    _appointmentDurationController.dispose();
    super.dispose();
  }

  Future<void> _updateCapacity() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final dailyCapacity = int.tryParse(_dailyCapacityController.text) ?? 20;
      final hourlyCapacity = int.tryParse(_hourlyCapacityController.text) ?? 4;
      final appointmentDuration = int.tryParse(_appointmentDurationController.text) ?? 15;

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorData['id'])
          .update({
        'dailyCapacity': dailyCapacity,
        'hourlyCapacity': hourlyCapacity,
        'appointmentDuration': appointmentDuration,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث السعة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث السعة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _showCapacityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحديث سعة الحجوزات'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _dailyCapacityController,
                decoration: const InputDecoration(
                  labelText: 'الحد الأقصى للحجوزات اليومية',
                  prefixIcon: Icon(Icons.today),
                  border: OutlineInputBorder(),
                  suffixText: 'مريض',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hourlyCapacityController,
                decoration: const InputDecoration(
                  labelText: 'الحد الأقصى للحجوزات في الساعة',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                  suffixText: 'مريض',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _appointmentDurationController,
                decoration: const InputDecoration(
                  labelText: 'مدة الموعد',
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder(),
                  suffixText: 'دقيقة',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'هذه الإعدادات تحدد عدد المرضى الذين يمكن حجز مواعيد معهم',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateCapacity();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyCapacity = widget.doctorData['dailyCapacity'] ?? 20;
    final hourlyCapacity = widget.doctorData['hourlyCapacity'] ?? 4;
    final appointmentDuration = widget.doctorData['appointmentDuration'] ?? 15;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.people, color: Color(0xFF6c547b)),
                SizedBox(width: 8),
                Text(
                  'سعة الحجوزات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Capacity display
            Expanded(
              child: Column(
                children: [
                  _buildCapacityRow('يومياً', dailyCapacity, 'مريض', Icons.today),
                  const SizedBox(height: 8),
                  _buildCapacityRow('في الساعة', hourlyCapacity, 'مريض', Icons.access_time),
                  const SizedBox(height: 8),
                  _buildCapacityRow('مدة الموعد', appointmentDuration, 'دقيقة', Icons.timer),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _showCapacityDialog,
                      icon: _isUpdating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.edit),
                      label: const Text('تعديل السعة'),
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

  Widget _buildCapacityRow(String label, dynamic value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6c547b)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${value ?? 0} $unit',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6c547b),
            ),
          ),
        ],
      ),
    );
  }
}
