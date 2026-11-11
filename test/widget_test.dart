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

  testWidgets(
    'Responsive Design & Zero RenderFlex Overflow stress test on narrow screens (320x568 & 360x800)',
    (WidgetTester tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final screenSize in const [Size(320, 568), Size(360, 800)]) {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = screenSize;

        final service = SupabaseService();
        await tester.pumpWidget(MemurBankApp(supabaseService: service));
        await tester.pumpAndSettle();

        // 1. Ana Sayfa (Hesabım) kaydırma ve kontrol
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();

        // 2. Transfer & Avans sekmesi (Her iki mod: Maaş Avansı & Para Transferi)
        await tester.tap(find.byIcon(Icons.swap_horiz_outlined));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
        await tester.pumpAndSettle();

        // 3. Profil sekmesi (RoleSwitcherBar 345.4px / 320px genişlik testi dahil)
        await tester.tap(find.byIcon(Icons.badge_outlined));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -550));
        await tester.pumpAndSettle();
        expect(
          find.text('Geliştirici Test Araçları (Yöntem C)'),
          findsOneWidget,
        );

        // 4. Admin rolüne geç ve Teftiş/Yönetim panelinin 3 alt sekmesini de dar ekranda test et
        await tester.ensureVisible(find.text('Müfettiş (admin)'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Müfettiş (admin)'));
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
        ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first))
            .clearSnackBars();
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.admin_panel_settings_outlined));
        await tester.pumpAndSettle();

        // Alt sekme 2: Memurlar
        await tester.tap(find.byIcon(Icons.manage_accounts_outlined));
        await tester.pumpAndSettle();

        // Alt sekme 3: Hazine & MB İstatistikleri
        await tester.tap(find.byIcon(Icons.insights_outlined));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      }
    },
  );
}
