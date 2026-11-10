import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memur_bank/main.dart';
import 'package:memur_bank/services/supabase_service.dart';

void main() {
  testWidgets(
    'MemurBank 3D Splash -> Fallback Banner -> Sicil No + Password Auth -> MainShell test',
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

      // 1. SplashScreen (Senaryo 3: 3D KEP Güvenlik Doğrulaması) görünür olmalı
      expect(find.text('3D KEP Güvenlik Doğrulaması'), findsOneWidget);

      // 2. 3D Animasyon bitince otomatik olarak LoginScreen'e geçmeli ve Fallback Banner görünmeli
      await tester.pumpAndSettle();
      expect(find.text('MemurBank Kurumsal Giriş'), findsOneWidget);
      expect(
        find.textContaining('YEREL FALLBACK (DEMO) MODU AKTİF'),
        findsOneWidget,
      );

      // 3. Boş veya geçersiz Sicil No girildiğinde hata vermeli
      await tester.enterText(find.byType(TextFormField).first, 'HATALI-0000');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Sicil No ve Şifre ile Giriş Yap'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Geçersiz Kurum Sicil No!'), findsOneWidget);

      // 4. Doğru Sicil No (MAL-0092) + YANLIŞ Şifre ('999') girildiğinde reddetmeli
      await tester.enterText(find.byType(TextFormField).first, 'MAL-0092');
      await tester.enterText(find.byType(TextFormField).at(1), '999');
      await tester.tap(find.text('Sicil No ve Şifre ile Giriş Yap'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Hatalı Giriş Şifresi!'), findsOneWidget);
      expect(find.text('MemurBank Kurumsal Giriş'), findsOneWidget);

      // 5. Doğru Sicil No (MAL-0092) + DOĞRU Şifre ('123') ile giriş yapılabilmeli
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Sicil No ve Şifre ile Giriş Yap'));
      await tester.pumpAndSettle();
      expect(find.text('Rol Değiştir (Test)'), findsOneWidget);
      expect(find.text('Teftiş/Yönetim'), findsOneWidget);
      expect(
        find.textContaining('YEREL FALLBACK (DEMO) MODU AKTİF'),
        findsOneWidget,
      );
    },
  );

  testWidgets('MemurBank smoke test - 3 roles, tabs, and fallback data', (
    WidgetTester tester,
  ) async {
    final service = SupabaseService();
    await tester.pumpWidget(MemurBankApp(supabaseService: service));
    await tester.pumpAndSettle();

    // 1. User (Ahmet Yılmaz) başlangıç kontrolü ve üstte Fallback Banner kontrolü
    expect(find.text('MemurBank'), findsOneWidget);
    expect(
      find.textContaining('YEREL FALLBACK (DEMO) MODU AKTİF'),
      findsOneWidget,
    );
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
