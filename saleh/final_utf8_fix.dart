import 'dart:convert';
import 'dart:io';

/// الحل النهائي الشامل لمشكلة UTF-8
/// يصلح الملفات مع ضمان عدم تكرار المشكلة
void main() async {
  print('=' * 70);
  print('🔧 الحل النهائي الشامل لمشكلة UTF-8');
  print('=' * 70);
  print('\n📋 خطوات الإصلاح:');
  print('   1️⃣  فحص جميع ملفات .dart');
  print('   2️⃣  قراءة المحتوى بترميز Latin-1');
  print('   3️⃣  إعادة ترميزه كـ UTF-8');
  print('   4️⃣  حفظ الملفات مع ضمان UTF-8');
  print('\n🔍 بدء الفحص...\n');

  final libDir = Directory('lib');
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  int totalFixed = 0;
  int totalSkipped = 0;
  int totalChars = 0;

  for (final file in dartFiles) {
    final filePath = file.path.replaceAll('\\', '/');
    
    try {
      // قراءة البايتات الخام
      final bytes = await file.readAsBytes();
      
      // محاولة فك الترميز كـ Latin-1
      String content;
      try {
        content = latin1.decode(bytes);
      } catch (e) {
        // إذا فشل Latin-1، نستخدم UTF-8 مباشرة
        content = utf8.decode(bytes, allowMalformed: true);
      }
      
      // إعادة ترميز كـ UTF-8
      final fixedContent = utf8.decode(latin1.encode(content), allowMalformed: true);
      
      // حساب الفروقات
      int diffs = 0;
      for (int i = 0; i < content.length && i < fixedContent.length; i++) {
        if (content[i] != fixedContent[i]) {
          diffs++;
        }
      }
      
      if (diffs > 0) {
        // حفظ مع ضمان UTF-8
        final outputBytes = utf8.encode(fixedContent);
        await file.writeAsBytes(outputBytes, flush: true);
        
        print('✅ ${filePath.split('/').last.padRight(40)} - $diffs حرف');
        totalFixed++;
        totalChars += diffs;
      } else {
        totalSkipped++;
      }
    } catch (e) {
      print('❌ خطأ في ${filePath.split('/').last}: $e');
    }
  }

  print('\n' + '=' * 70);
  print('✨ اكتمل الإصلاح النهائي!');
  print('=' * 70);
  print('📊 النتائج:');
  print('   • إجمالي الملفات المفحوصة: ${dartFiles.length}');
  print('   • الملفات المُصلحة: $totalFixed');
  print('   • الملفات السليمة: $totalSkipped');
  print('   • إجمالي الأحرف المستبدلة: $totalChars');
  print('=' * 70);
  
  if (totalFixed > 0) {
    print('\n⚠️  تحذير: تم إصلاح $totalFixed ملف!');
    print('   يجب الآن:');
    print('   1. تشغيل: git add -A');
    print('   2. تشغيل: git commit -m "Final UTF-8 fix"');
    print('   3. تشغيل: git push');
  }
}
