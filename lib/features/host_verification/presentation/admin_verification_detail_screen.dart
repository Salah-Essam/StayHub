import 'package:flutter/material.dart';

class AdminVerificationDetailScreen extends StatefulWidget {
  final String verificationId; // الـ ID الخاص بطلب التوثيق

  const AdminVerificationDetailScreen({
    super.key,
    required this.verificationId,
  });

  @override
  State<AdminVerificationDetailScreen> createState() =>
      _AdminVerificationDetailScreenState();
}

class _AdminVerificationDetailScreenState
    extends State<AdminVerificationDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchVerificationDetails();
  }

  // 1. استدعاء بيانات الطلب: GET /admin/host-verifications/{id}
  Future<void> _fetchVerificationDetails() async {
    setState(() => _isLoading = true);

    // TODO: قم بنقل هذا الاستدعاء لمكتبة Dio مع ترويسة Authorization: Bearer <admin_jwt>
    await Future.delayed(const Duration(seconds: 1)); // محاكاة الشبكة

    // نموذج البيانات القادمة من السيرفر تماماً كما في الـ Contract
    setState(() {
      _data = {
        "id": widget.verificationId,
        "userId": "0e48939a-9d79-42d2-9a72-e0f12c961111",
        "fullName": "أحمد محمد",
        "phoneNumber": "+201012345678",
        "status": "PENDING",
        "documents": {
          "idFrontUrl": "https://via.placeholder.com/600x400?text=ID+Front",
          "idBackUrl": "https://via.placeholder.com/600x400?text=ID+Back",
          "selfiePhotoUrl":
              "https://via.placeholder.com/600x400?text=Selfie+Photo",
        },
        "latestFaceMatch": {"similarity": 0.94, "result": "MATCH"},
        "submittedAt": "2026-10-25T14:30:00Z",
      };
      _isLoading = false;
    });
  }

  // 2. إرسال قرار المشرف: PATCH /admin/host-verifications/{id}/decision
  Future<void> _makeDecision(
    String decision, {
    String? reason,
    List<String>? corrections,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // TODO: استدعاء الـ API بإرسال الـ Body المناسب
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context); // إغلاق مؤشر التحميل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم اتخاذ القرار بنجاح: $decision'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // العودة لقائمة الطلبات
    }
  }

  // نافذة إدخال سبب الرفض أو طلب التوضيح
  void _showReasonDialog(String decisionType) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          decisionType == 'REJECTED' ? 'سبب الرفض' : 'تفاصيل التوضيح المطلوب',
        ),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'اكتب الملاحظات هنا...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _makeDecision(
                  decisionType,
                  reason: reasonController.text.trim(),
                  corrections: decisionType == 'NEEDS_CLARIFICATION'
                      ? ['ID_FRONT']
                      : null,
                );
              }
            },
            child: const Text('إرسال القرار'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل طلب التوثيق'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بيانات المضيف الأساسية
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _data!['fullName'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(_data!['phoneNumber'] ?? ''),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.badge,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text('الحالة: ${_data!['status']}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // نتيجة مطابقة الوجه (AI Face Match)
                  if (_data!['latestFaceMatch'] != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.face_retouching_natural,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'مطابقة الوجه التلقائية: ${_data!['latestFaceMatch']['result']} (${((_data!['latestFaceMatch']['similarity'] ?? 0) * 100).toInt()}%)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text(
                    'المستندات المرفقة للمراجعة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // عرض صور المستندات القادمة من روابط الـ API
                  _DocumentImageCard(
                    title: 'وجه البطاقة (ID Front)',
                    imageUrl: _data!['documents']['idFrontUrl'],
                  ),
                  const SizedBox(height: 12),
                  _DocumentImageCard(
                    title: 'ظهر البطاقة (ID Back)',
                    imageUrl: _data!['documents']['idBackUrl'],
                  ),
                  const SizedBox(height: 12),
                  _DocumentImageCard(
                    title: 'الصورة الشخصية (Selfie)',
                    imageUrl: _data!['documents']['selfiePhotoUrl'],
                  ),
                  const SizedBox(height: 32),

                  // أزرار اتخاذ القرار للمشرف
                  Row(
                    children: [
                      // زر القبول
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _makeDecision('APPROVED'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('موافقة'),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // زر طلب التوضيح
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _showReasonDialog('NEEDS_CLARIFICATION'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('طلب توضيح'),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // زر الرفض
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showReasonDialog('REJECTED'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('رفض'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

// كارت لعرض رابط الصورة القادم من الـ API
class _DocumentImageCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const _DocumentImageCard({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 150,
              color: Colors.grey.shade200,
              child: const Center(child: Text('تعذر تحميل الصورة')),
            ),
          ),
        ),
      ],
    );
  }
}
