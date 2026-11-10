# MemurBank - Kronolojik Geliştirme ve İlerleme Kayıt Sistemi (`yapilanlar.md`)

> **KAYIT KURALI (APPEND-ONLY LOG SİSTEMİ):**
> Bu dosya kronolojik ve adım etiketli (`[ADIM-XX | YYYY-AA-GG SS:DD]`) bir ilerleme günlüğüdür. Projede yeni bir özellik, hata düzeltmesi veya iyileştirme yapıldığında üstteki geçmiş kayıtlar silinmez; **her yeni çalışma dosyanın en altına yeni bir `[ADIM-XX | ZAMAN]` başlığı ve `- [x]` liste elemanlarıyla eklenir.**

---

## [ADIM-01 | 2026-11-09 21:34] — Çekirdek Mimari, 3 Rol, Sliver Yapısı ve Supabase Kurulumu

### 1.1. Ön Hazırlık ve Konfigürasyon
- [x] Kök dizindeki `project.md`, `.agents/skills/skill.md`, `.agents/references/solid_ve_temalar.md`, `.agents/references/state_flow.md` ve `stitch_ui/` tasarım dosyalarının incelenmesi
- [x] `pubspec.yaml` dosyasına `flutter_bloc`, `supabase_flutter`, `flutter_dotenv` paketlerinin ve `.env` ile `stitch_ui/memurbank_resmi_logo/screen.png` asset tanımlamalarının eklenmesi
- [x] Kök dizinde `.env` ve `.env.example` dosyalarının (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`) oluşturulması ve `.gitignore` içine `.env` eklenmesi
- [x] `analysis_options.yaml` içinde zorunlu `const` ve sıkı lint kurallarının (`prefer_const_constructors: error`, `prefer_const_declarations: error`, `prefer_const_literals_to_create_immutables: error`, `deprecated_member_use: error`) yapılandırılması

### 1.2. Sabitler ve Tema Katmanı (`lib/constants/` & `lib/theme/`)
- [x] `lib/constants/app_paddings.dart` dosyasının oluşturulması (Tüm `static const` padding, margin, radius, boyut ve `SizedBox` boşluk sabitleri)
- [x] `lib/constants/app_strings.dart` dosyasının oluşturulması (Sabit metinler, unvan ve kurum tanımları)
- [x] `lib/theme/app_colors.dart` dosyasının oluşturulması (Sadece bu klasörde renk kodu kullanımı: Halkbank/Kamu Mavisi, Hazine Altını, Teftiş Kırmızısı, Light & Dark renk paletleri)
- [x] `lib/theme/app_theme.dart` dosyasının oluşturulması (`Light` & `Dark` `ThemeData` ve `MemurBankThemeExtension`)

### 1.3. Veri Modelleri ve Servis Katmanı (`lib/models/` & `lib/services/`)
- [x] `lib/models/profile_model.dart` dosyasının SQL şemasıyla birebir uyumlu oluşturulması (`id`, `full_name`, `kurum_sicil_no`, `unvan`, `balance`, `role`, `is_frozen`)
- [x] `lib/models/advance_request_model.dart` dosyasının SQL şemasıyla birebir uyumlu oluşturulması (`id`, `user_id`, `full_name`, `amount`, `reason`, `status`, `created_at`)
- [x] `lib/services/supabase_service.dart` dosyasının oluşturulması (`profiles` ve `advance_requests` CRUD + Admin Key ile `reset_memur_bank` RPC + 4 örnek memur ve 2 bekleyen avans talebiyle yerel Fallback desteği)

### 1.4. Durum Yönetimi, Stitch UI, Ortak Bileşenler ve Ekranlar
- [x] `lib/bloc/theme_cubit.dart` ve `lib/bloc/bank_cubit.dart` dosyalarının oluşturulması
- [x] `lib/stitch_ui/profile_header_widget.dart`, `admin_dashboard_card.dart`, `filter_bar_widget.dart` ve `treasury_charts_widget.dart` bileşenlerinin `%100 const StatelessWidget` olarak oluşturulması
- [x] `lib/widgets/request_card_widget.dart`, `officer_card_widget.dart` (Tanrı Modu BottomSheet ile) ve `role_switcher_bar.dart` bileşenlerinin oluşturulması
- [x] `lib/screens/main_shell_screen.dart`, `home_screen.dart`, `transfer_screen.dart`, `profile_screen.dart`, `management_panel_screen.dart` ve `lib/main.dart` dosyalarının `CustomScrollView` + `const SliverToBoxAdapter` + `const PinnedHeaderSliver` + `SliverList.builder` mimarisiyle oluşturulması
- [x] `flutter analyze` ve `flutter test` ile 0 hata / 0 uyarı doğrulaması

---

## [ADIM-02 | 2026-11-09 22:08] — Proje İncelemesi ve Eksik Özellik Analizi (`yapilacaklar.md`)

- [x] Mevcut kod tabanı, `stitch_ui/` tasarımları ve platform klasörleri (`android/`, `ios/`, `web/`) taranarak eksik özelliklerin (`SplashScreen`, `LoginScreen`, `Logout`, Uygulama İkonu, E-Bordro, IBAN Kopyala, Dijital Dekont, ATM Karekod, Geri Ödeme Planı, `TextFormField` çip senkronizasyonu) tespit edilmesi
- [x] Tespit edilen tüm maddelerin kök dizindeki `yapilacaklar.md` dosyasında 5 ana kategori altında yapılandırılması

---

## [ADIM-03 | 2026-11-09 22:13] — `yapilacaklar.md` Kapsamındaki Tüm Özelliklerin Kodlanması ve Doğrulanması

- [x] **[AUTH & SPLASH]** `lib/screens/splash_screen.dart` dosyasının oluşturulması (`stitch_ui/memurbank_resmi_logo/screen.png` resmi logosu ve Hazine KEP güvenlik doğrulama göstergesi ile)
- [x] **[AUTH & LOGIN]** `lib/screens/login_screen.dart` dosyasının `CustomScrollView` + `PinnedHeaderSliver` + `SliverList.builder` mimarisiyle oluşturulması (Kurum Sicil No + PIN girişi, *"T.C. E-Devlet Kapısı ile Giriş Yap"* butonu ve 4 demo memur için tek tıkla hızlı oturum açma kartları)
- [x] **[AUTH & LOGOUT]** `MainShellScreen` üst barına ve `ProfileScreen` ekranına *"Güvenli Çıkış (Oturumu Kapat)"* aksiyonunun eklenmesi
- [x] **[APP ICON & MANIFEST]** `stitch_ui/memurbank_resmi_logo/screen.png` resmi logosunun tüm Android (`mipmap-mdpi` .. `mipmap-xxxhdpi`), iOS (`AppIcon.appiconset`) ve Web (`favicon.png`, `Icon-192.png`, `Icon-512.png`, `Icon-maskable-*`) ikon boyutlarına dönüştürülerek uygulanması; `AndroidManifest.xml`, `web/manifest.json` ve `web/index.html` uygulama adının `MemurBank` olarak güncellenmesi
- [x] **[E-BORDRO & ATM QR & KAMPANYA]** `ProfileHeaderWidget` içerisine T.C. Hazine E-Bordro Detay BottomSheet'i (`_PayrollDetailBottomSheet`), Ortak Kamu ATM Karekod BottomSheet'i (`_AtmQrBottomSheet`) ve Memura Özel %0 Faizli 15.000 ₺ Avans kampanya kartının eklenmesi
- [x] **[HESAP HAREKETLERİ & DEKONT]** `BankCubit` içine `TransactionRecord` modelinin ve `RequestCardWidget` yanına `TransactionItemWidget` + **MemurBank Dijital İşlem Dekontu** BottomSheet'inin (`_DigitalReceiptBottomSheet`) eklenmesi
- [x] **[PROFİL & IBAN & GÜVENLİK]** `ProfileScreen` içine Resmi Kamu Maaş IBAN Kopyala kartı ile Hazine KEP Bildirimleri ve FAST Kolay Adres güvenlik anahtarlarının eklenmesi
- [x] **[FORM SENKRONİZASYONU & GERİ ÖDEME PLANI]** `TransferScreen` içinde hızlı tutar/gerekçe çiplerinin `ValueKey` + `formPresetVersion` ile `TextFormField` iç metnini anında güncellemesi; *"Ayın 15'i Tek Sefer (%0 Faiz)"* ve *"3 Eşit Taksitle Mahsup"* geri ödeme planı seçiminin ve dinamik Finansal Başvuru Özeti kartının eklenmesi
- [x] **[TEFTİŞ FİLTRELERİ & YENİLEME]** `ManagementPanelScreen` Memur Listesi sekmesine *"Tüm Personel"*, *"Şüpheli / Bloke"* ve *"Mutemet & Yöneticiler"* segment filtre çiplerinin ve tüm ana listelere `RefreshIndicator` desteğinin eklenmesi
- [x] **[TEST & ANALİZ]** `test/widget_test.dart` içerisine `Splash -> Login -> MainShell` ve `3 Rol / 4 Sekme / Tanrı Modu` testlerinin eklenmesi; `flutter analyze` (0 hata / 0 uyarı) ve `flutter test` (`All tests passed!`) doğrulamalarının tamamlanması

---

## [ADIM-04 | 2026-11-09 22:25] — Dokümantasyon Güncellemesi ve Kronolojik Log Standardizasyonu

- [x] Dart kodlarına dokunulmadan tüm `.md` dokümanlarının (`project.md`, `.agents/skills/skill.md`, `.agents/references/state_flow.md`, `README.md`, `yapilanlar.md`) son eklenen ekranlar ve özelliklerle senkronize edilmesi
- [x] `yapilanlar.md` dosyasının her yeni geliştirmede en alta `[ADIM-XX | YYYY-AA-GG SS:DD]` etiketiyle ekleme yapılacak (append-only) kronolojik kayıt sistemine dönüştürülmesi

---

## [ADIM-05 | 2026-11-09 22:47] — 3D Perspektifli Splash Animasyonu (Senaryo 3), E-Devlet Butonunun Kaldırılması ve Supabase Sicil No Doğrulaması

- [x] **[3D SPLASH & OTOMATİK GEÇİŞ]** `lib/screens/splash_screen.dart` içerisindeki manuel *"Kamu Bankacılığı Girişine İlerle"* butonu kaldırıldı; `%100 StatelessWidget` kuralına uygun olarak `TweenAnimationBuilder<double>` ve `Matrix4.identity()..setEntry(3, 2, 0.0022)..rotateY(...)..rotateX(...)` ile 360° 3D madalyon dönüşü, zıt yönlü çift 3B yörünge halkası, canlı yüzde sayacı (`%0 -> %100`), 3 aşamalı KEP/Supabase kontrol listesi ve `onEnd: cubit.completeSplash` ile otomatik `LoginScreen` geçişi kodlandı
- [x] **[LOGIN & E-DEVLET KALDIRIMI]** `lib/screens/login_screen.dart` ve `lib/bloc/bank_cubit.dart` içerisinden *"T.C. E-Devlet Kapısı ile Giriş Yap"* butonu, `loginWithEDevlet()` metodu ve Supabase `profiles` şemasında yer almayan PIN alanı kaldırıldı; hızlı demo seçim kartlarına memurların güncel bakiyeleri (`42.500 ₺`, `51.000 ₺`, `64.000 ₺`, `95.000 ₺`) eklendi
- [x] **[SİCİL NO DOĞRULAMA BUG FIX]** `BankCubit.loginWithCredentials()` metodunda geçersiz sicil numarası girildiğinde `Ahmet Yılmaz` olarak giriş yapmasına yol açan `orElse: () => state.profiles.first` hatası giderildi; yalnızca kayıtlı `kurum_sicil_no` (`MEB-1042`, `EGM-8831`, `MAL-0092`, `MUF-0001` vb.) veya `full_name` eşleştiğinde giriş yapılması, aksi halde kırmızı SnackBar ile hata gösterilmesi sağlandı
- [x] **[RESET KORUMASI, BLOKE UYARISI & TEMİZ FORM]** `resetDatabaseAndReload()` sırasında aktif memur UUID'sinin korunması (`keepProfileId: currentActiveId`), `ProfileHeaderWidget` üzerinde dondurulmuş hesaplar (`is_frozen == true`) için kırmızı MASAK/Teftiş Kurulu uyarı bandı gösterilmesi, `_AddNewOfficerBottomSheet` form alanlarının `TextFormField` ile senkronize edilip sıfırlanması ve `advance_requests.reason` sütununun SQL şemasıyla birebir temiz tutulması sağlandı
- [x] **[TEST & ANALİZ]** `test/widget_test.dart` yeni 3D otomatik Splash geçişi ve Sicil No doğrulama senaryolarıyla güncellendi; `flutter analyze` (0 hata / 0 uyarı) ve `flutter test` (`All tests passed!`) doğrulandı

---

## [ADIM-06 | 2026-11-10 21:55] — Zorunlu `password` SQL Şeması, Şifre Doğrulama ve Kalıcı Fallback / Canlı Supabase Bildirim Sistemi

- [x] **[SQL & PROFILE MODEL]** `reset_memur_bank()` SQL fonksiyonu `password TEXT NOT NULL` ve `kurum_sicil_no TEXT NOT NULL UNIQUE` kısıtlarıyla tek ve kesin yapıya kavuşturuldu; `lib/models/profile_model.dart` içerisine varsayılan değeri olmayan zorunlu `required this.password` alanı eklendi
- [x] **[SUPABASE SERVICE & BAĞLANTI DURUMU]** `lib/services/supabase_service.dart` içerisindeki 4 varsayılan memura `password: '123'`, `createOfficerProfile` metoduna `required String password` ve canlı/yerel bağlantı durumunu izleyen `isUsingFallback` özelliği eklendi
- [x] **[KALICI FALLBACK BANNER & CANLI SUPABASE SNACKBAR]** `lib/widgets/role_switcher_bar.dart` içerisine `FallbackModeStickyBanner` bileşeni eklendi; uygulama yerel Fallback modunda çalışırken `LoginScreen` ve `MainShellScreen` en üstünde (AppBar altında) kalıcı *"⚠️ YEREL FALLBACK (DEMO) MODU AKTİF"* uyarı bandı ve *"Yeniden Bağlan"* (`retrySupabaseConnection`) aksiyonu gösterilmesi, canlı Supabase bağlantısı sağlandığında ise yeşil onay SnackBar'ı ile bildirim verilmesi kodlandı
- [x] **[SİCİL NO + ŞİFRE DOĞRULAMA & TANRI MODU]** `LoginScreen` üzerine şifre gizle/göster (`isLoginPasswordObscured`) destekli **Giriş Şifresi** alanı ve `_AddNewOfficerBottomSheet` içerisine zorunlu yeni memur şifresi alanı eklendi; `loginWithCredentials()` metodunun hem Sicil No hem de `password` eşleşmesini doğrulaması sağlandı
- [x] **[DOKÜMANTASYON, TEST & ANALİZ]** `project.md`, `.agents/skills/skill.md` ve `test/widget_test.dart` güncellendi; `flutter analyze` (0 hata / 0 uyarı) ve `flutter test` (`All tests passed!`) doğrulandı

---

## [ADIM-07 | 2026-11-10 22:06] — Android, iOS ve macOS Platform İzinleri, Entitlements ve İkon Bütünlüğü

- [x] **[ANDROID PERMISSIONS]** `android/app/src/main/AndroidManifest.xml` içerisine Release ve tüm çalışma modlarında Supabase HTTPS bağlantısının kesintisiz sağlanması için `<uses-permission android:name="android.permission.INTERNET" />` ve `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />` izinleri eklendi
- [x] **[MACOS ENTITLEMENTS & İKON]** `macos/Runner/DebugProfile.entitlements` ve `macos/Runner/Release.entitlements` dosyalarına App Sandbox dış ağ erişimi için `<key>com.apple.security.network.client</key><true/>` yetkisi eklendi; `macos/Runner/Configs/AppInfo.xcconfig` içinde `PRODUCT_NAME = MemurBank` yapıldı ve `macos/Runner/Assets.xcassets/AppIcon.appiconset/` içindeki tüm macOS ikonları (`16px` .. `1024px`) resmi MemurBank logosuyla güncellendi
- [x] **[IOS INFO.PLIST]** `ios/Runner/Info.plist` içerisinde `CFBundleDisplayName` ve `CFBundleName` değerleri `MemurBank` olarak birleştirildi; `NSCameraUsageDescription` ve `NSLocalNetworkUsageDescription` izin açıklamaları eklendi

<!--
YENİ ADIM EKLERKEN KULLANILACAK ŞABLON (Dosyanın en altına ekleyiniz):

## [ADIM-08 | YYYY-AA-GG SS:DD] — <Yapılan İşlemin Kısa Başlığı>
- [x] <Yapılan değişiklik veya eklenen özellik 1>
- [x] <Yapılan değişiklik veya eklenen özellik 2>
-->

[ADIM-08 | 2026-11-10 22:19]
- Ne yapıldı:
  1. `.env` dosyasındaki `SUPABASE_URL` değeri web dashboard adresinden (`https://supabase.com/dashboard/project/bgivxmjhhrwlpxnoxwrb`) gerçek Supabase REST API uç noktasına (`https://bgivxmjhhrwlpxnoxwrb.supabase.co`) güncellendi.
  2. `lib/services/supabase_service.dart` içerisine `SupabaseService.normalizeSupabaseUrl()` yardımcı metodu eklendi ve `lib/main.dart` içerisinde kullanıldı; böylece `.env` içine yanlışlıkla dashboard URL'si girilse bile proje ID'si ayıklanarak otomatik olarak `https://<proje_id>.supabase.co` adresine dönüştürülmesi sağlandı.
  3. `SupabaseService` (`_isUsingFallback = false`) ve `BankState` (`this.isUsingFallback = false`) içerisindeki varsayılan fallback durumu `false` olarak değiştirildi. Böylece `FallbackModeStickyBanner` varsayılan olarak gizli tutuldu ve yalnızca gerçek bir bağlantı/sorgu hatası yaşanıp yerel fallback verilerine düşüldüğünde (`isUsingFallback == true`) gösterilmesi sağlandı.
  4. `fetchAdvanceRequests()` metodundaki olası bir tablo/sorgu hatasının, başarılı olan `fetchProfiles()` bağlantısının `_isUsingFallback = false` durumunu ezmemesi sağlandı.
  5. `BankCubit.completeSplash()` güncellenerek, 3 saniyelik `SplashScreen` tamamlanıp `LoginScreen` ekranına geçildiği anda canlı Supabase bağlantısı aktifse (`!state.isUsingFallback`) yeşil onay `SnackBar`'ının (`"✓ Supabase Canlı Veritabanı Bağlantısı Kuruldu!..."`) doğrudan `LoginScreen`'de gösterilmesi sağlandı.
  6. `yapilacaklar.md` içerisindeki tüm maddeler (`1.1`, `1.2`, `2.1`, `2.2`, `3.1`) `[x]` olarak işaretlendi.
- Neden yapıldı:
  Kullanıcının Login sayfasında dahi "Yerel Fallback Modu Aktif" uyarısı almasının kök nedenini (`.env` içindeki Dashboard URL'si ve `isUsingFallback` varsayılan değerinin `true` olması) kalıcı olarak çözmek ve `FallbackModeStickyBanner`'ın yalnızca gerçek fallback durumunda görünmesini sağlamak için yapıldı.

[ADIM-09 | 2026-11-10 22:40]
- Ne yapıldı:
  1. `lib/screens/home_screen.dart` içerisinde yorum satırına kaymış olan `if (state.activeProfile.isAdminOrManager)` koşulu gerçek kod satırına alındı ve `lib/stitch_ui/admin_dashboard_card.dart` içine de güvenlik kontrolü eklendi; böylece standart memur (`user`) rolünde Teftiş/Mutemetlik kartının görünmesi engellendi.
  2. `lib/bloc/bank_cubit.dart` ve `lib/widgets/officer_card_widget.dart` güncellenerek Tanrı Modu (God Mode) yetkileri yalnızca `admin` (Başmüfettiş) rolüne sınırlandırıldı; `manager` (Kurum Mutemedi) memur kartına tıkladığında salt-okunur "Kurum Mutemetliği Sicil & Maaş Özeti" penceresi gösterildi.
  3. Başmüfettişin (`admin`) kendi hesabının veya başka bir `admin` hesabının rolünü düşürmesi / dondurması (Self-Lockout) hem Cubit hem UI seviyesinde engellendi.
  4. `BankCubit.addNewOfficer()` metodu `Future<bool>` dönecek şekilde güncellendi, mükerrer `kurum_sicil_no` kontrolü eklendi ve `_AddNewOfficerBottomSheet`'in yalnızca doğrulama başarılıysa kapanması sağlandı.
  5. `BankCubit.submitMoneyTransfer()` içerisine alıcı memur bloke (`recipient.isFrozen`) kontrolü, `fastInstantConfirmEnabled` şalter kontrolü ve hem gönderici (`-`) hem alıcı (`+`) için çift yönlü `TransactionRecord` dekont üretimi eklendi.
  6. `_buildDefaultTransactions()` içine 4 varsayılan memurun tamamı için kendi maaş/işlem dekontları eklendi ve `activeUserTransactions` getter'ının başka memurun dekontlarını sızdırması önlendi.
  7. `lib/stitch_ui/filter_bar_widget.dart` üzerindeki filtre çip sayaçları `state.roleScopedRequests` ile aktif kullanıcının yetki kapsamına göre birebir doğru sayıları gösterecek şekilde düzeltildi.
  8. Kullanılmayan 0 byte'lık `lib/screens/main_shell.dart` ve `lib/screens/transfer_advance_screen.dart` dosyaları silindi.
  9. `ProfileModel.formatCurrency()` merkezi para formatlayıcısı eklendi; tüm ekranlarda klavye `textInputAction` / `onFieldSubmitted` desteği, `ConnectionStatusBadge` (`Canlı Bulut` / `Yerel Demo`), Yönetim Paneli 1. sekmesinde bekleyen talepleri üstte gösteren sıralama (`sortedRequestsForManagement`) ve Veritabanı Sıfırlama butonu için onay diyaloğu (`AlertDialog`) devreye alındı.
- Neden yapıldı:
  Kapsamlı proje denetiminde ("Şeytanın Avukatı" incelemesi) tespit edilen tüm mantıksal/yetki açıklarını kapatmak ve kullanıcı arayüzünü daha erişilebilir, tutarlı ve anlaşılır hale getirmek için yapıldı.
