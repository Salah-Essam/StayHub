import 'package:flutter/material.dart';
import 'package:stayhub/features/host_verification/presentation/host_verification_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // دالة محاكاة فحص حالة المضيف والتحويل الذكي (Switch to Hosting)
  void _handleSwitchToHosting(BuildContext context) async {
    // 1. إظهار مؤشر تحميل مؤقت
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.teal)),
    );

    // محاكاة استدعاء الـ API: GET /host-verifications/me/status
    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      Navigator.pop(context); // إغلاق التحميل

      // افتراضياً سنفترض هنا أن المستخدم لم يرسل المستندات بعد (NOT_SUBMITTED)
      // يمكنك لاحقاً ربطها بالنتيجة الحقيقية القادمة من الـ API
      String verificationStatus = 'NOT_SUBMITTED';

      if (verificationStatus == 'APPROVED') {
        // الانتقال لوحة تحكم المضيف
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أهلاً بك في لوحة تحكم المضيف!')),
        );
      } else if (verificationStatus == 'NOT_SUBMITTED') {
        // الانتقال لنموذج توثيق الهوية (KYC Form)
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const HostVerificationFormScreen()));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HostVerificationFormScreen()),
        );
      } else if (verificationStatus == 'PENDING') {
        // الانتقال لشاشة الانتظار
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('طلبك قيد المراجعة حالياً')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StayHub'),
        centerTitle: false,
        actions: [
          // زر التحول إلى وضع المضيف (Switch to Hosting)
          TextButton.icon(
            onPressed: () => _handleSwitchToHosting(context),
            icon: const Icon(Icons.storefront, color: Colors.teal),
            label: const Text(
              'ارفع عقارك',
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شريط البحث الوهمي
            TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن وجهتك، إقامة، أو شاطئ...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'العقارات المتاحة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // قائمة العقارات (كمثال تجريبي للمسافر)
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'شقة راقية بإطلالة مميزة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'القاهرة، مصر • 1,200 ج.م / ليلة',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
