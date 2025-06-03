import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/layout/responsive_layout.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_input.dart';
import '../core/design_system.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorProfileScreen({
    super.key,
    required this.doctorData,
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isUpdating = false;

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aboutController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _clinicInfoController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _consultationFeeController = TextEditingController();

  // Dropdown values
  String? _selectedSpecialty;
  String? _selectedProvince;
  int _selectedExperience = 1;

  // Location data
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _locationAddress;

  // قائمة التخصصات
  final List<String> _specialties = [
    'طب عام',
    'قلب وأوعية دموية',
    'أسنان',
    'جلدية',
    'نساء وولادة',
    'عظام',
    'عيون',
    'أطفال',
    'نفسية',
    'أنف وأذن وحنجرة',
    'جراحة عامة',
    'مسالك بولية',
    'أعصاب',
    'باطنية',
  ];

  // قائمة محافظات العراق
  final List<String> _iraqProvinces = [
    'بغداد',
    'البصرة',
    'نينوى',
    'أربيل',
    'النجف',
    'كربلاء',
    'بابل',
    'الديوانية',
    'ذي قار',
    'الأنبار',
    'كركوك',
    'واسط',
    'صلاح الدين',
    'المثنى',
    'دهوك',
    'السليمانية',
    'ميسان',
    'حلبجة',
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  void _loadDoctorData() {
    final data = widget.doctorData;

    // Load basic info
    _nameController.text = data['name'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    _aboutController.text = data['about'] ?? '';
    _qualificationsController.text = data['qualifications'] ?? '';
    _clinicInfoController.text = data['clinicInfo'] ?? '';
    _clinicNameController.text = data['clinicName'] ?? '';
    _clinicAddressController.text = data['clinicAddress'] ?? '';
    _consultationFeeController.text = data['consultationFee']?.toString() ?? '';

    // Load dropdowns
    _selectedSpecialty = data['specialty'];
    _selectedProvince = data['province'];

    // Load experience
    if (data['experience'] != null) {
      final exp = int.tryParse(data['experience'].toString()) ?? 1;
      _selectedExperience = exp.clamp(1, 20);
    }

    // Load location
    if (data['location'] != null) {
      final location = data['location'] as Map<String, dynamic>;
      _selectedLatitude = location['latitude']?.toDouble();
      _selectedLongitude = location['longitude']?.toDouble();
      _locationAddress = location['address'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.backgroundColor,
      appBar: ResponsiveAppBar(
        title: 'الملف الشخصي',
        actions: [
          AppIconButton(
            icon: _isUpdating ? Icons.hourglass_empty : Icons.save,
            onPressed: _isUpdating ? null : _saveProfile,
            tooltip: 'حفظ التغييرات',
          ),
          const SizedBox(width: AppDesignSystem.spaceMD),
        ],
      ),
      body: ResponsiveLayout(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageSection(
                  title: 'المعلومات الأساسية',
                  subtitle: 'أدخل معلوماتك الشخصية والمهنية',
                  child: _buildBasicInfoSection(),
                ),

                PageSection(
                  title: 'الموقع على الخريطة',
                  subtitle: 'حدد موقع عيادتك ليتمكن المرضى من الوصول إليك',
                  child: _buildLocationSection(),
                ),

                PageSection(
                  title: 'نبذة عن الطبيب',
                  subtitle: 'اكتب نبذة مختصرة عن خبرتك ومجال تخصصك',
                  child: _buildAboutSection(),
                ),

                PageSection(
                  title: 'المؤهلات والشهادات',
                  subtitle: 'أضف مؤهلاتك العلمية وشهاداتك المهنية',
                  child: _buildQualificationsSection(),
                ),

                PageSection(
                  title: 'معلومات العيادة',
                  subtitle: 'أدخل تفاصيل عيادتك وخدماتها',
                  child: _buildClinicInfoSection(),
                ),

                const SizedBox(height: AppDesignSystem.spaceXL),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6c547b),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return AppCard(
      child: ResponsiveRow(
        children: [
          // العمود الأول
          Column(
            children: [
              AppTextField(
                labelText: 'اسم الطبيب',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسم الطبيب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDesignSystem.spaceMD),

              AppTextField(
                labelText: 'رقم الهاتف',
                controller: _phoneController,
                prefixIcon: const Icon(Icons.phone),
                hintText: '07xxxxxxxxx',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  if (value.length != 11) {
                    return 'رقم الهاتف يجب أن يكون 11 رقم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDesignSystem.spaceMD),

              AppTextField(
                labelText: 'رسوم الاستشارة العادية (دينار عراقي)',
                controller: _consultationFeeController,
                prefixIcon: const Icon(Icons.attach_money),
                hintText: 'مثال: 25000',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال رسوم الاستشارة';
                  }
                  if (int.tryParse(value) == null) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
            ],
          ),

          // العمود الثاني
          Column(
            children: [
              AppDropdown<String>(
                labelText: 'التخصص',
                value: _selectedSpecialty,
                prefixIcon: const Icon(Icons.medical_services),
                items: _specialties.map((specialty) {
                  return DropdownMenuItem(
                    value: specialty,
                    child: Text(specialty),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialty = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'يرجى اختيار التخصص';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDesignSystem.spaceMD),

              AppDropdown<int>(
                labelText: 'سنوات الخبرة',
                value: _selectedExperience,
                prefixIcon: const Icon(Icons.work),
                items: List.generate(20, (index) => index + 1).map((years) {
                  return DropdownMenuItem(
                    value: years,
                    child: Text('$years ${years == 1 ? 'سنة' : 'سنوات'}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedExperience = value ?? 1;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildLocationSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // زر تحديد الموقع الحالي
          AppButton(
            text: 'تحديد موقعي الحالي',
            onPressed: _getCurrentLocation,
            icon: Icons.my_location,
            type: AppButtonType.secondary,
            fullWidth: true,
          ),

          const SizedBox(height: AppDesignSystem.spaceMD),

          // قائمة المحافظات
          AppDropdown<String>(
            labelText: 'المحافظة',
            value: _selectedProvince,
            prefixIcon: const Icon(Icons.location_city),
            items: _iraqProvinces.map((province) {
              return DropdownMenuItem(
                value: province,
                child: Text(province),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProvince = value;
                _locationAddress = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'يرجى اختيار المحافظة';
              }
              return null;
            },
          ),

          const SizedBox(height: AppDesignSystem.spaceMD),

          if (_selectedLatitude != null && _selectedLongitude != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDesignSystem.spaceMD),
              decoration: BoxDecoration(
                color: AppDesignSystem.successColor.withOpacity(0.1),
                border: Border.all(color: AppDesignSystem.successColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppDesignSystem.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppDesignSystem.spaceSM),
                  Expanded(
                    child: Text(
                      'تم تحديد الموقع: $_selectedLatitude, $_selectedLongitude',
                      style: AppDesignSystem.bodySM.copyWith(
                        color: AppDesignSystem.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDesignSystem.spaceSM),
          ],

          Text(
            'سيتمكن المرضى من رؤية موقع عيادتك والوصول إليها',
            style: AppDesignSystem.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _aboutController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'نبذة عن الطبيب',
                border: OutlineInputBorder(),
                hintText: 'اكتب نبذة مختصرة عن خبرتك ومجال تخصصك...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى كتابة نبذة عن الطبيب';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر هذه النبذة للمرضى في ملفك الشخصي',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _qualificationsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'المؤهلات والشهادات',
                border: OutlineInputBorder(),
                hintText: 'مثال: بكالوريوس طب وجراحة - جامعة الملك سعود\nماجستير في أمراض القلب...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال المؤهلات والشهادات';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _clinicNameController,
              decoration: const InputDecoration(
                labelText: 'اسم العيادة/المستشفى',
                prefixIcon: Icon(Icons.local_hospital),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم العيادة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clinicAddressController,
              decoration: const InputDecoration(
                labelText: 'عنوان العيادة',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال عنوان العيادة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clinicInfoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'معلومات إضافية عن العيادة',
                border: OutlineInputBorder(),
                hintText: 'ساعات العمل، الخدمات المتاحة، معلومات الاتصال...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return AppButton(
      text: 'حفظ التغييرات',
      onPressed: _saveProfile,
      icon: Icons.save,
      isLoading: _isUpdating,
      fullWidth: true,
      size: AppButtonSize.large,
    );
  }

  void _getCurrentLocation() async {
    try {
      // محاكاة الحصول على الموقع الحالي
      // في التطبيق الحقيقي، يمكن استخدام geolocator package
      setState(() {
        _selectedLatitude = 33.3152; // إحداثيات بغداد كمثال
        _selectedLongitude = 44.3661;
        _locationAddress = _selectedProvince ?? 'الموقع الحالي';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديد الموقع الحالي'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديد الموقع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      final updateData = <String, dynamic>{
        // المعلومات الأساسية
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'specialty': _selectedSpecialty,
        'experience': _selectedExperience.toString(),
        'consultationFee': int.tryParse(_consultationFeeController.text.trim()) ?? 0,
        'province': _selectedProvince,

        // المعلومات التفصيلية
        'about': _aboutController.text.trim(),
        'qualifications': _qualificationsController.text.trim(),
        'clinicInfo': _clinicInfoController.text.trim(),
        'clinicName': _clinicNameController.text.trim(),
        'clinicAddress': _clinicAddressController.text.trim(),

        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_selectedLatitude != null && _selectedLongitude != null) {
        updateData['location'] = {
          'latitude': _selectedLatitude!,
          'longitude': _selectedLongitude!,
          'address': _locationAddress ?? _selectedProvince ?? 'موقع محدد',
        };
      }

      // استخدام معرف المستند الصحيح بدلاً من data['id']
      final String doctorDocId = widget.doctorData['firebase_uid'] ??
                                 widget.doctorData['docId'] ??
                                 widget.doctorData['id'];

      print('🔧 Updating doctor profile with doc ID: $doctorDocId');

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorDocId)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التغييرات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ التغييرات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _qualificationsController.dispose();
    _clinicInfoController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    super.dispose();
  }
}
