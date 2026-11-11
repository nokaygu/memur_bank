# MemurBank — Form Sıfırlama Deneyimi (UX) & Yeni Kurumsal Logo / Launcher İkonu Planı (`yapilacaklar.md`)

> **DURUM:** Bu plandaki tüm maddeler (`1.1` – `1.5` ve `2.1` – `2.3`) eksiksiz olarak uygulanmış, `flutter analyze` (0 hata / 0 uyarı) ve `flutter test` (`All tests passed!`) ile doğrulanmıştır.

---

## 📝 BÖLÜM 1: Başvuru ve Transfer Sonrası Gerekçe / Form Sıfırlama & Akıllı UX İyileştirmeleri

### 1. Sorunun Tespiti ve Kök Nedeni (`lib/bloc/bank_transfer_actions.dart` & `advance_application_card.dart` & `peer_transfer_card.dart`)
- **Neden Gerekçe Yazısı Sıfırlanmıyor?**
  1. `submitAdvanceRequest()` çalıştığında talep Supabase/Fallback listesine ekleniyor ancak `BankState` içindeki `advanceReasonInput`, `advanceAmountInput` ve `formPresetVersion` değerleri **hiç sıfırlanmıyor**.
  2. Projede `%100 StatelessWidget` kuralı gereği `TextFormField` bileşenleri `initialValue` ve `key: ValueKey('adv-reason-${state.formPresetVersion}')` ile kontrol ediliyor. `formPresetVersion` artırılmadığı sürece `TextFormField` içindeki metin (ekran görüntüsündeki `"Kurum İçi Görevlendirme Haccccccc"` gibi) başvuru tamamlandıktan sonra bile kutunun içinde asılı kalıyor.
  3. Aynı sorun **Memurlar Arası FAST Para Transferi** (`PeerTransferCard` -> `submitMoneyTransfer()`) sekmesinde de mevcut: Transfer tamamlandığında `transferNoteInput` sıfırlanmıyor ve açıklama `TextFormField` bileşeninde `ValueKey` bulunmuyor.
  4. Ayrıca kullanıcı hızlı gerekçe şablonuna tıkladıktan sonra metni düzenlerken kutuyu tek tıkla temizleyebileceği bir `X` (`Temizle`) butonu bulunmuyor ve gönderim sonrası klavye açık kalabiliyor.
  5. İlk ekran görüntüsünde görüldüğü üzere `1.500.000,00 ₺` gibi gerçek dışı büyüklükte avans başvurusu yapılabiliyor (üst limit kontrolü eksikliği).

### 2. Yapılacak Çözümler (Sadece Sıfırlama Değil, Tam Kapsamlı UX Çözümü)
- [x] **1.1. Başvuru Tamamlandığında Otomatik Form Sıfırlama (`submitAdvanceRequest`):**
  - `lib/bloc/bank_transfer_actions.dart` içindeki `submitAdvanceRequest()` başarıyla tamamlandığında:
    - `advanceReasonInput: ''` (boş metin) olarak sıfırlandı,
    - `advanceAmountInput: '15000'` (varsayılan başlangıç tutarı) ve `repaymentPlanIndex: 0` değerlerine döndürüldü,
    - **`formPresetVersion: state.formPresetVersion + 1`** artırılarak `%100 StatelessWidget` mimarisindeki hem tutar hem de gerekçe `TextFormField` kutularının anında tertemiz olması sağlandı.
- [x] **1.2. FAST Transfer Tamamlandığında Otomatik Form Sıfırlama (`submitMoneyTransfer`):**
  - `submitMoneyTransfer()` başarıyla tamamlandığında `transferNoteInput: ''`, `transferAmountInput: '2500'` ve `formPresetVersion: state.formPresetVersion + 1` ile sıfırlandı; `PeerTransferCard` içindeki açıklama `TextFormField` bileşenine `key: ValueKey('trf-note-${state.formPresetVersion}')` eklendi.
- [x] **1.3. Gerekçe ve Açıklama Kutularına Tek Tıkla Temizle (`suffixIcon: X`) Butonu Eklenmesi:**
  - `AdvanceApplicationCard` (Başvuru Gerekçesi) ve `PeerTransferCard` (Transfer Açıklaması) içindeki `TextFormField` bileşenlerinin sağ tarafına (`suffixIcon`), metin dolu olduğunda görünen bir **`Icons.cancel_outlined` (Temizle)** ikonu eklendi. Kullanıcı şablonu seçtikten sonra değiştirmek isterse tek dokunuşla kutuyu sıfırlayabiliyor.
- [x] **1.4. Hızlı Gerekçe Çiplerinde Seçimi Kaldırma (Toggle) ve Gönderim Sonrası Klavye Kapatma:**
  - Zaten seçili olan bir hızlı gerekçe şablonuna tekrar tıklandığında metin temizlenecek şekilde güncellendi; başvuru veya transfer butonuna basıldığında `FocusManager.instance.primaryFocus?.unfocus()` ile ekran klavyesi otomatik kapatılarak altta oluşan yeni talep/dekont kartının hemen görünmesi sağlandı.
- [x] **1.5. Gerçekçi Kamu Maaş Avansı Üst Limit Kontrolü:**
  - Ekran görüntüsündeki `1.500.000,00 ₺` gibi mantıksız avans tutarlarını engellemek için kamu bankacılığı kuralı olarak maksimum avans/kredi üst sınırı (`100.000 ₺`) kontrolü eklendi ve aşım durumunda bilgilendirici uyarı gösterilmesi sağlandı.

---

## 🎨 BÖLÜM 2: Sol Üstteki `"nurBar"` İkon Sorunu ve Emülatör Ana Ekran (Launcher) Logosunun Yenilenmesi

### 1. Sorunun Tespiti ve Kök Nedeni (`assets/images/memurbank_logo.png` & `mipmap-*/ic_launcher.png`)
- **Neden Sol Üstte `"nurBar / BANKACILI"` Yazıyor ve Emülatörde İkon Kötü Görünüyor?**
  1. Mevcut `assets/images/memurbank_logo.png` dosyası `1:1` kare bir uygulama ikonu değil, **yatay ve çok geniş bir banner (`~4:1` en/boy oranında)**! Sol ucunda küçük bir ikon, ortasında ise `"MemurBank / KAMU BANKACILIĞI"` yazısı yer alıyor.
  2. **Sol Üst AppBar Sorunu:** `MainShellScreen` AppBar'da (`36x36`), `SplashScreen` 3D madalyonunda ve `LoginScreen`'de bu yatay banner `BoxFit.cover` ile kare kutuya yerleştirildiğinde, Flutter resmin tam **ortasını** kırpıyor. Yatay banner'ın tam ortasında da `"nurBar / BANKACILI"` harfleri bulunduğu için sol üstte kesik bir `"nurBar"` yazısı görünüyor!
  3. **Emülatör Launcher İkonu Sorunu:** 3. ekran görüntüsünde görüldüğü üzere, aynı yatay banner Android `mipmap-*/ic_launcher.png` içine sıkıştırıldığı için yuvarlak Android ikon çerçevesinin ortasında beyaz boşluklu, yatay kesilmiş ve okunaksız bir görüntü oluşturuyor.

### 2. Yapılacak Çözümler (Paylaşılan Mavi Geometrik Kamu Bankası Ambleminin Uygulanması)
- [x] **2.1. Yeni `1:1` Tam Kare Kurumsal Mavi Geometrik Amblemin (`assets/images/memurbank_logo.png`) Yerleştirilmesi:**
  - Kullanıcının paylaştığı 2. görseldeki (kraliyet mavisi degrade zemin üzerinde beyaz simetrik geometrik hatlara sahip modern kamu bankası amblemi) yüksek çözünürlüklü `1:1` tam kare (`512x512`) formatta `assets/images/memurbank_logo.png` olarak kaydedildi.
- [x] **2.2. Uygulama İçi Tüm Logo Noktalarının (`AppBar`, `SplashScreen`, `LoginScreen`) Düzenlenmesi:**
  - `MainShellScreen` sol üst `AppBar` içinde (`FilterQuality.high` ve zarif çerçeve ile), `LoginScreen` üst başlık kartında ve `SplashScreen` 3D KEP doğrulama madalyonunda yeni `1:1` kare logo kullanıldı; böylece sol üstteki `"nurBar"` kırpılma hatası tamamen ortadan kaldırıldı.
- [x] **2.3. Android Emülatör Ana Ekran (Launcher) İkonunun Adaptive & Tam Dolgulu Olarak Yenilenmesi:**
  - Android `mipmap-mdpi` (`48x48`), `mipmap-hdpi` (`72x72`), `mipmap-xhdpi` (`96x96`), `mipmap-xxhdpi` (`144x144`) ve `mipmap-xxxhdpi` (`192x192`) klasörlerindeki `ic_launcher.png` ve `ic_launcher_foreground.png` dosyaları yeni `1:1` kare mavi amblemden tam dolgulu olarak üretildi.
  - Android 8+ (API 26+) emülatörlerde yuvarlak/squircle ikon maskelemesinde kenarlarda beyaz boşluk kalmaması için `android/app/src/main/res/values/colors.xml` (`#0048BA`), `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` ve `ic_launcher_round.xml` (Adaptive Icon) yapılandırıldı.
  - Aynı zamanda iOS (`AppIcon.appiconset`), macOS (`AppIcon.appiconset`) ve Web (`favicon.png`, `Icon-192.png`, `Icon-512.png`, `Icon-maskable-*`) ikonları da bu yeni kare amblemle birebir senkronize edildi.
