import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memur_bank/main.dart';
import 'package:memur_bank/services/supabase_service.dart';

void main() {
  testWidgets(
    'MemurBank 3D Splash Auto-Transition -> Login Validation -> MainShell test',
    (WidgetTester tester) async {
      final service = SupabaseService();
      await tester.pumpWidget(
        MemurBankApp(
          supabaseService: service,
          showSplash: true,
          startAuthenticated: false,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // 1. SplashScreen (Senaryo 3: 3D KEP Güvenlik Doğrulaması) görünür olmalı, manuel buton olmamalı
      expect(find.text('3D KEP Güvenlik Doğrulaması'), findsOneWidget);
      expect(find.text('Kamu Bankacılığı Girişine İlerle'), findsNothing);

      // 2. 3D Animasyon bitince otomatik olarak LoginScreen'e geçmeli
      await tester.pumpAndSettle();
      expect(find.text('MemurBank Kurumsal Giriş'), findsOneWidget);
      expect(find.text('T.C. E-Devlet Kapısı ile Giriş Yap'), findsNothing);

      // 3. Geçersiz Sicil No girildiğinde hata vermeli, içeri almamalı
      await tester.enterText(find.byType(TextFormField).first, 'HATALI-0000');
      await tester.tap(find.text('Sicil No ile Güvenli Giriş Yap'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Geçersiz Kurum Sicil No!'), findsOneWidget);
      expect(find.text('MemurBank Kurumsal Giriş'), findsOneWidget);

      // 4. Geçerli Sicil No (MAL-0092 - Mehmet Kaya) ile giriş yapılabilmeli
      await tester.enterText(find.byType(TextFormField).first, 'MAL-0092');
      await tester.tap(find.text('Sicil No ile Güvenli Giriş Yap'));
      await tester.pumpAndSettle();
      expect(find.text('Rol Değiştir (Test)'), findsOneWidget);
      expect(find.text('Teftiş/Yönetim'), findsOneWidget);
    },
  );

  testWidgets('MemurBank smoke test - 3 roles, tabs, and fallback data', (
    WidgetTester tester,
  ) async {
    final service = SupabaseService();
    await tester.pumpWidget(MemurBankApp(supabaseService: service));
    await tester.pumpAndSettle();

    // 1. User (Ahmet Yılmaz) başlangıç kontrolü
    expect(find.text('MemurBank'), findsOneWidget);
    expect(find.text('Rol Değiştir (Test)'), findsOneWidget);
    expect(find.text('Ahmet Yılmaz'), findsWidgets);

    // 2. Rol Değiştir -> Manager (Mehmet Kaya)
    await tester.tap(find.text('Rol Değiştir (Test)').first);
    await tester.pumpAndSettle();
    expect(find.text('Teftiş/Yönetim'), findsOneWidget);

    // 3. Rol Değiştir -> Admin (Kemal Bey - God Mode)
    await tester.tap(find.text('Rol Değiştir (Test)').first);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(find.text('TANRI MODU (GOD MODE)'), findsOneWidget);

    // 4. 4. Sekmeye (Teftiş/Yönetim) geç
    await tester.tap(find.text('Teftiş/Yönetim'));
    await tester.pumpAndSettle();
    expect(find.text('3. Hazine & MB'), findsOneWidget);
  });
}
