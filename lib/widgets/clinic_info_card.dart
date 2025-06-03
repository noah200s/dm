import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicInfoCard extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const ClinicInfoCard({super.key, required this.doctorData});

  @override
  State<ClinicInfoCard> createState() => _ClinicInfoCardState();
}

class _ClinicInfoCardState extends State<ClinicInfoCard> {
  bool _isUpdating = false;
  final _nameController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.doctorData['name'] ?? '';
    _clinicNameController.text = widget.doctorData['clinicName'] ?? '';
    _addressController.text = widget.doctorData['address'] ?? '';
    _phoneController.text = widget.doctorData['phone'] ?? '';
    _specialtyController.text = widget.doctorData['specialty'] ?? '';
    _experienceController.text = widget.doctorData['experience']?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clinicNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _updateInfo() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorData['id'])
          .update({
        'name': _nameController.text,
        'clinicName': _clinicNameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'specialty': _specialtyController.text,
        'experience': int.tryParse(_experienceController.text) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المعلومات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث المعلومات: $e'),
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

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحديث معلومات العيادة'),
        content: SizedBox(
          width: 400,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الطبيب',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clinicNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم العيادة',
                    prefixIcon: Icon(Icons.local_hospital),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(
                    labelText: 'التخصص',
                    prefixIcon: Icon(Icons.medical_services),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  decoration: const InputDecoration(
                    labelText: 'سنوات الخبرة',
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
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
              _updateInfo();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
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
                Icon(Icons.info, color: Color(0xFF6c547b)),
                SizedBox(width: 8),
                Text(
                  'معلومات العيادة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Info display
            Expanded(
              child: Column(
                children: [
                  _buildInfoRow('الطبيب', widget.doctorData['name'], Icons.person),
                  const SizedBox(height: 8),
                  _buildInfoRow('العيادة', widget.doctorData['clinicName'], Icons.local_hospital),
                  const SizedBox(height: 8),
                  _buildInfoRow('التخصص', widget.doctorData['specialty'], Icons.medical_services),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _showInfoDialog,
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
                      label: const Text('تعديل المعلومات'),
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

  Widget _buildInfoRow(String label, dynamic value, IconData icon) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value?.toString() ?? 'غير محدد',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
