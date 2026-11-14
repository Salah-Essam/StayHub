import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/host_verification_form_model.dart';

import 'package:dio/dio.dart';

class HostVerificationFormScreen extends StatefulWidget {
  final String?
  clarificationMessage; // يمرر في حالة طلب التوضيح NEEDS_CLARIFICATION

  const HostVerificationFormScreen({super.key, this.clarificationMessage});

  @override
  State<HostVerificationFormScreen> createState() =>
      _HostVerificationFormScreenState();
}

class _HostVerificationFormScreenState
    extends State<HostVerificationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _model = HostVerificationFormModel();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(
    ImageSource source,
    Function(File) onImageSelected,
  ) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80, // لضغط حجم الصورة قليلاً لسرعة الرفع
    );
    if (pickedFile != null) {
      setState(() {
        onImageSelected(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (!_model.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('برجاء رفع جميع الصور المطلوبة قبل الإرسال'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // إظهار مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // 1. تجهيز الـ FormData بالشكل المطابق تماماً للـ API Contract
        // الأسماء يجب أن تكون snake_case تماماً كما طلب السيرفر: full_name, phone_number, id_front, id_back, selfie_photo[cite: 20]
        FormData formData = FormData.fromMap({
          'full_name': _model.fullName.trim(),
          'phone_number': _model.phoneNumber.trim(),
          'id_front': await MultipartFile.fromFile(
            _model.idFront!.path,
            filename: 'id_front.jpg',
          ),
          'id_back': await MultipartFile.fromFile(
            _model.idBack!.path,
            filename: 'id_back.jpg',
          ),
          'selfie_photo': await MultipartFile.fromFile(
            _model.selfiePhoto!.path,
            filename: 'selfie_photo.jpg',
          ),
        });

        // 2. إعداد الـ Dio مع الـ Base URL والـ Port الذي يطلبه صديقك
        // استبدل الـ IP أو الـ Port بالرابط الذي سيمنحه لك صديقك (مثلاً: http://192.168.1.15:8080)
        final dio = Dio(
          BaseOptions(
            baseUrl: 'http://192.168.1.7:8081', // <--- هنا تضع الرابط والـ Port الخاص بصديقك
            headers: {
              'Authorization':
                  'Bearer YOUR_USER_TOKEN_HERE', // توكن المستخدم المسجل
              // ملاحظة هامة: لا تقم بتحديد Content-Type هنا، دع المتصفح أو Dio يحدد الـ multipart boundary تلقائياً[cite: 3]
            },
          ),
        );

        // 3. إرسال الطلب عبر POST /host-verifications[cite: 20]
        final response = await dio.post('/host-verifications', data: formData);

        if (mounted) {
          Navigator.pop(context); // إغلاق التحميل

          if (response.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إرسال طلب التوثيق بنجاح وهو قيد المراجعة!'),
                backgroundColor: Colors.green,
              ),
            );
            // الانتقال للشاشة التالية أو الرجوع للخلف
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // إغلاق التحميل

          String errorMsg = 'حدث خطأ أثناء الإرسال';
          if (e is DioException && e.response != null) {
            errorMsg = 'خطأ من السيرفر: ${e.response?.data.toString()}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('توثيق حساب المضيف'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عرض رسالة التوضيح إذا كان الطلب يحتاج تعديلات
              if (widget.clarificationMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.clarificationMessage!,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Text(
                'البيانات الشخصية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // حقل الاسم الكامل
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'الاسم بالكامل (مطابق للهوية)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'برجاء إدخال الاسم بالكامل';
                  }
                  if (value.length > 150) {
                    return 'الاسم يجب ألا يتجاوز 150 حرفاً';
                  }
                  return null;
                },
                onSaved: (value) => _model.fullName = value ?? '',
              ),
              const SizedBox(height: 12),

              // حقل رقم الهاتف
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'برجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
                onSaved: (value) => _model.phoneNumber = value ?? '',
              ),
              const SizedBox(height: 24),

              const Text(
                'رفع المستندات الرسمية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // اختيار صورة وجه البطاقة
              _ImageUploadCard(
                title: 'وجه البطاقة الشخصية (ID Front)',
                imageFile: _model.idFront,
                onTap: () => _pickImage(
                  ImageSource.gallery,
                  (file) => _model.idFront = file,
                ),
              ),
              const SizedBox(height: 12),

              // اختيار صورة ظهر البطاقة
              _ImageUploadCard(
                title: 'ظهر البطاقة الشخصية (ID Back)',
                imageFile: _model.idBack,
                onTap: () => _pickImage(
                  ImageSource.gallery,
                  (file) => _model.idBack = file,
                ),
              ),
              const SizedBox(height: 12),

              // التقاط صورة سيلفي من الكاميرا مباشرة
              _ImageUploadCard(
                title: 'صورة شخصية حية (Selfie)',
                imageFile: _model.selfiePhoto,
                icon: Icons.camera_alt,
                onTap: () => _pickImage(
                  ImageSource.camera,
                  (file) => _model.selfiePhoto = file,
                ),
              ),
              const SizedBox(height: 24),

              // زر الإرسال
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'إرسال طلب التوثيق',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// كارت مخصص لاختيار وعرض المعاينة للصور
class _ImageUploadCard extends StatelessWidget {
  final String title;
  final File? imageFile;
  final Uint8List? imageBytes; // أضفنا هذه لدعم الويب إذا احتجت لحفظ الـ bytes
  final IconData icon;
  final VoidCallback onTap;

  const _ImageUploadCard({
    required this.title,
    this.imageFile,
    this.imageBytes,
    this.icon = Icons.photo_library,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: imageFile != null ? Colors.green : Colors.grey.shade400,
            width: imageFile != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                // الحل الجذري هنا للتعامل مع الويب والهاتف:
                child: kIsWeb
                    ? Image.network(
                        imageFile!.path, // على الويب، image_picker يعطينا Blob URL يمكن فتحه بـ Image.network
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Image.file(
                        imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 36, color: Colors.grey.shade600),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
