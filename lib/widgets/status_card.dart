import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusCard extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const StatusCard({super.key, required this.doctorData});

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  bool _isUpdating = false;
  String _currentStatus = 'غير متاح';

  final List<String> _statusOptions = [
    'متاح',
    'مشغول',
    'غير متاح',
    'في إجازة',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.doctorData['currentStatus'] ?? 'غير متاح';
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final doctorId = widget.doctorData['id'];
      print('🔄 Updating status for doctor ID: $doctorId');
      print('📝 New status: $newStatus');
      print('👤 Doctor name: ${widget.doctorData['name']}');

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .update({
        'currentStatus': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Status update successful in Firestore');

      setState(() {
        _currentStatus = newStatus;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث الحالة إلى: $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث الحالة: $e'),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'متاح':
        return Colors.green;
      case 'مشغول':
        return Colors.orange;
      case 'في إجازة':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'متاح':
        return Icons.check_circle;
      case 'مشغول':
        return Icons.access_time;
      case 'في إجازة':
        return Icons.beach_access;
      default:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: _getStatusColor(_currentStatus),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'حالة التوفر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Current status display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(_currentStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(_currentStatus),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(_currentStatus),
                    color: _getStatusColor(_currentStatus),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentStatus,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(_currentStatus),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Status change buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5,
                children: _statusOptions.map((status) {
                  final isSelected = status == _currentStatus;
                  return ElevatedButton(
                    onPressed: _isUpdating || isSelected 
                        ? null 
                        : () => _updateStatus(status),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected 
                          ? _getStatusColor(status)
                          : Colors.grey[200],
                      foregroundColor: isSelected 
                          ? Colors.white 
                          : Colors.black87,
                      elevation: isSelected ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            status,
                            style: const TextStyle(fontSize: 12),
                          ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
