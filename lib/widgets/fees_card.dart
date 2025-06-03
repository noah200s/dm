import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeesCard extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const FeesCard({super.key, required this.doctorData});

  @override
  State<FeesCard> createState() => _FeesCardState();
}

class _FeesCardState extends State<FeesCard> {
  bool _isUpdating = false;
  final _regularFeeController = TextEditingController();
  final _emergencyFeeController = TextEditingController();
  final _followUpFeeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _regularFeeController.text = 
        widget.doctorData['consultationFee']?.toString() ?? '0';
    _emergencyFeeController.text = 
        widget.doctorData['emergencyFee']?.toString() ?? '0';
    _followUpFeeController.text = 
        widget.doctorData['followUpFee']?.toString() ?? '0';
  }

  @override
  void dispose() {
    _regularFeeController.dispose();
    _emergencyFeeController.dispose();
    _followUpFeeController.dispose();
    super.dispose();
  }

  Future<void> _updateFees() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final regularFee = double.tryParse(_regularFeeController.text) ?? 0;
      final emergencyFee = double.tryParse(_emergencyFeeController.text) ?? 0;
      final followUpFee = double.tryParse(_followUpFeeController.text) ?? 0;

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorData['id'])
          .update({
        'consultationFee': regularFee,
        'emergencyFee': emergencyFee,
        'followUpFee': followUpFee,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الرسوم بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث الرسوم: $e'),
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

  void _showFeesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحديث رسوم الاستشارة'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _regularFeeController,
                decoration: const InputDecoration(
                  labelText: 'الاستشارة العادية (ريال)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergencyFeeController,
                decoration: const InputDecoration(
                  labelText: 'الاستشارة الطارئة (ريال)',
                  prefixIcon: Icon(Icons.emergency),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _followUpFeeController,
                decoration: const InputDecoration(
                  labelText: 'المتابعة (ريال)',
                  prefixIcon: Icon(Icons.follow_the_signs),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
              _updateFees();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regularFee = widget.doctorData['consultationFee'] ?? 0;
    final emergencyFee = widget.doctorData['emergencyFee'] ?? 0;
    final followUpFee = widget.doctorData['followUpFee'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.attach_money, color: Color(0xFF6c547b)),
                SizedBox(width: 8),
                Text(
                  'رسوم الاستشارة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Fees display
            Expanded(
              child: Column(
                children: [
                  _buildFeeRow('عادية', regularFee, Icons.medical_services),
                  const SizedBox(height: 8),
                  _buildFeeRow('طارئة', emergencyFee, Icons.emergency),
                  const SizedBox(height: 8),
                  _buildFeeRow('متابعة', followUpFee, Icons.follow_the_signs),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _showFeesDialog,
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
                      label: const Text('تعديل الرسوم'),
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

  Widget _buildFeeRow(String type, dynamic fee, IconData icon) {
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
              type,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${fee ?? 0} ريال',
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
