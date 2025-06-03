import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationCard extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const LocationCard({super.key, required this.doctorData});

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  bool _isUpdating = false;
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final location = widget.doctorData['location'] ?? {};
    _latitudeController.text = location['latitude']?.toString() ?? '';
    _longitudeController.text = location['longitude']?.toString() ?? '';
    _addressController.text = widget.doctorData['address'] ?? '';
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateLocation() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final latitude = double.tryParse(_latitudeController.text);
      final longitude = double.tryParse(_longitudeController.text);

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorData['id'])
          .update({
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'address': _addressController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الموقع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث الموقع: $e'),
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

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحديث موقع العيادة'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                controller: _latitudeController,
                decoration: const InputDecoration(
                  labelText: 'خط العرض (Latitude)',
                  prefixIcon: Icon(Icons.my_location),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(
                  labelText: 'خط الطول (Longitude)',
                  prefixIcon: Icon(Icons.my_location),
                  border: OutlineInputBorder(),
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
                      'يمكنك الحصول على الإحداثيات من خرائط جوجل',
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
              _updateLocation();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.doctorData['location'] ?? {};
    final hasLocation = location['latitude'] != null && location['longitude'] != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF6c547b)),
                SizedBox(width: 8),
                Text(
                  'موقع العيادة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location display
            Expanded(
              child: Column(
                children: [
                  if (hasLocation) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(height: 8),
                          const Text(
                            'تم تحديد الموقع',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${location['latitude']?.toStringAsFixed(4)}, ${location['longitude']?.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.location_off, color: Colors.orange),
                          SizedBox(height: 8),
                          Text(
                            'لم يتم تحديد الموقع',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _showLocationDialog,
                      icon: _isUpdating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.edit_location),
                      label: const Text('تحديث الموقع'),
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
}
