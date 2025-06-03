import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/doctor_profile_screen.dart';

class ProfileCard extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const ProfileCard({
    super.key,
    required this.doctorData,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الملف الشخصي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6c547b),
                        ),
                      ),
                      Text(
                        'إدارة معلوماتك الشخصية والمهنية',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _openProfileScreen(),
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blue.shade600,
                  ),
                  tooltip: 'تعديل الملف الشخصي',
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Profile completion status
            _buildProfileCompletion(),
            
            const SizedBox(height: 16),
            
            // Quick info
            _buildQuickInfo(),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openProfileScreen(),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('تعديل الملف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewProfile(),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('معاينة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade600,
                      side: BorderSide(color: Colors.blue.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCompletion() {
    final completion = _calculateProfileCompletion();
    final percentage = (completion * 100).round();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'اكتمال الملف الشخصي',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6c547b),
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _getCompletionColor(completion),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: completion,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getCompletionColor(completion),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildQuickInfo() {
    final data = widget.doctorData;
    
    return Column(
      children: [

        _buildInfoRow(
          Icons.location_on,
          'الموقع',
          data['location'] != null 
              ? 'محدد على الخريطة'
              : 'غير محدد',
          data['location'] != null,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.info,
          'النبذة الشخصية',
          data['about'] != null && data['about'].toString().isNotEmpty
              ? 'مكتملة'
              : 'غير مكتملة',
          data['about'] != null && data['about'].toString().isNotEmpty,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isComplete) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isComplete ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isComplete ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  double _calculateProfileCompletion() {
    final data = widget.doctorData;
    int completedFields = 0;
    int totalFields = 5;

    // Check required fields
    if (data['location'] != null) completedFields++;
    if (data['about'] != null && data['about'].toString().isNotEmpty) completedFields++;
    if (data['qualifications'] != null && data['qualifications'].toString().isNotEmpty) completedFields++;
    if (data['clinicName'] != null && data['clinicName'].toString().isNotEmpty) completedFields++;
    if (data['clinicAddress'] != null && data['clinicAddress'].toString().isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }

  Color _getCompletionColor(double completion) {
    if (completion >= 0.8) return Colors.green;
    if (completion >= 0.5) return Colors.orange;
    return Colors.red;
  }

  void _openProfileScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DoctorProfileScreen(
          doctorData: widget.doctorData,
        ),
      ),
    );
  }

  void _viewProfile() {
    showDialog(
      context: context,
      builder: (context) => _ProfilePreviewDialog(doctorData: widget.doctorData),
    );
  }
}

class _ProfilePreviewDialog extends StatelessWidget {
  final Map<String, dynamic> doctorData;

  const _ProfilePreviewDialog({required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.visibility,
                  color: Color(0xFF6c547b),
                ),
                const SizedBox(width: 8),
                const Text(
                  'معاينة الملف الشخصي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6c547b),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const Divider(),
            
            const SizedBox(height: 16),
            
            // Doctor basic info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF6c547b),
                  child: Text(
                    doctorData['name']?.toString().substring(0, 1) ?? 'د',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorData['name'] ?? 'اسم الطبيب',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctorData['specialty'] ?? 'التخصص',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (doctorData['consultationFee'] != null)
                        Text(
                          'رسوم الكشف: ${doctorData['consultationFee']} ريال',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFea7884),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // About section
            if (doctorData['about'] != null && doctorData['about'].toString().isNotEmpty) ...[
              const Text(
                'نبذة عن الطبيب:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                doctorData['about'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Clinic info
            if (doctorData['clinicName'] != null) ...[
              const Text(
                'معلومات العيادة:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                doctorData['clinicName'],
                style: const TextStyle(fontSize: 12),
              ),
              if (doctorData['clinicAddress'] != null)
                Text(
                  doctorData['clinicAddress'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6c547b),
                  foregroundColor: Colors.white,
                ),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
