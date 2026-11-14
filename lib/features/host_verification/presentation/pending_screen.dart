import 'package:flutter/material.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.hourglass_top_rounded,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'طلبك قيد المراجعة',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'تم إرسال مستنداتك بنجاح، ويقوم فريق العمل بمراجعتها الآن. سنقوم بإشعاراتك فور إتمام التوثيق.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                // TODO: إعادة فحص الحالة أو العودة للشاشة الرئيسية
              },
              child: const Text('تحديث الحالة'),
            ),
          ],
        ),
      ),
    );
  }
}
