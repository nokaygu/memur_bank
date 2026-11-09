# MemurBank - Taranan Sorunlar, İyileştirmeler ve Senaryolar (`yapilacaklar.md`)

> **DURUM:** Tüm maddeler ve seçilen **Senaryo 3 (Zengin 3D Perspektifli Madalyon & Çift Yörünge Halkası Animasyonu)** başarıyla kodlanmış, `flutter analyze` ve `flutter test` ile doğrulanmıştır.

---

## 1. Splash Ekranı (`SplashScreen`) Düzenlemesi ve 3 Animasyon Senaryosu

### Tespit Edilen Sorun:
- Mevcut `lib/screens/splash_screen.dart` içinde **"Kamu Bankacılığı Girişine İlerle"** adında bir buton bulunmaktaydı. Bir Splash (Açılış) ekranında kullanıcının butona basmasını beklemek UX açısından hatalıdır; Splash ekranı animasyonunu tamamlayıp **otomatik olarak** `LoginScreen` ekranına geçmelidir.

### Yapılan İşlem:
- [x] Splash ekranındaki manuel buton tamamen kaldırıldı.
- [x] `%100 StatelessWidget` kuralını bozmadan (`StatefulWidget` kullanmadan, `TweenAnimationBuilder<double>` ve `onEnd: cubit.completeSplash` ile 2.4 saniyede) otomatik `LoginScreen` geçişi sağlandı.

### Seçilen Flutter Splash Animasyon Senaryosu:

- [ ] **SENARYO 1 — Elastik Logo Büyümesi (Zoom-Bounce) + Kademeli Altın Yükleme Çubuğu:**
  - `stitch_ui/memurbank_resmi_logo/screen.png` resmi logosu `Curves.easeOutBack` eğrisiyle küçükten büyüğe (`0.5 -> 1.0` ölçek) yaylanarak ve netleşerek (`Opacity 0 -> 1`) ekranın ortasına oturur.
  - Altındaki *"MemurBank"* başlığı hafifçe belirir ve Hazine Altını rengindeki ince progress bar `%0`'dan `%100`'e akıcı şekilde dolarak otomatik `LoginScreen` ekranına geçer.

- [ ] **SENARYO 2 — Nefes Alan Güvenlik Halkaları (Pulse / Ripple Efekti) + Yukarı Kayan Başlık:**
  - MemurBank logosunun arkasında dışa doğru genişleyip sönümlenen çift katmanlı kurumsal ışık halkası (radar/dalga efekti) çalışır.
  - *"MemurBank - Kamu & Memur Dijital Bankacılık"* metni aşağıdan yukarıya doğru (`Slide + Fade`) kayarak yerine oturur ve animasyon biter bitmez otomatik `LoginScreen` ekranına geçer.

- [x] **SENARYO 3 (SEÇİLDİ VE UYGULANDI) — Zengin 3D Rozet/Madalyon Dönüşü + Çift Eksenli 3B Yörünge Halkaları + Canlı Sistem Kontrol Adımları:**
  - MemurBank resmi logosu `Matrix4.identity()..setEntry(3, 2, 0.0022)..rotateY(...)..rotateX(...)` 3 boyutlu perspektif matrisiyle 360° Y-ekseni madalyon dönüşü, X-ekseni eğimi, dinamik altın parlama gölgesi ve etrafında zıt yönlerde 3B uzayda dönen çift güvenlik yörünge halkasıyla sahneye gelir.
  - Alt kısımda canlı yüzde sayacı (`%0 -> %100`) ve sırasıyla *"Supabase & KEP Güvenlik Tüneli Doğrulanıyor..."* -> *"Hazine Kamu Maaş & Avans Protokolleri Yüklendi"* -> *"Kamu Personeli Profilleri Hazır"* adımları onaylanarak animasyon bitiminde otomatik olarak `LoginScreen` ekranına geçer.

---

## 2. Giriş Ekranı (`LoginScreen`) ve Supabase Default Verileriyle Birebir Uyum

### Tespit Edilen Sorunlar:
1. **E-Devlet Butonu Fazlalığı:** `lib/screens/login_screen.dart` içinde bulunan **"T.C. E-Devlet Kapısı ile Giriş Yap"** butonu ve `BankCubit.loginWithEDevlet()` metodu istenmemekteydi.
2. **Hatalı Sicil No ile Giriş Bug'ı (`loginWithCredentials`):** Mevcut kodda `orElse: () => state.profiles.first` yazıldığı için kullanıcı sicil numarası alanına rastgele/geçersiz bir metin yazsa bile sistem hata vermeyip `Ahmet Yılmaz` olarak giriş yapmaktaydı.
3. **Supabase Şemasında Olmayan PIN Alanı:** Supabase `profiles` tablosunda (`id`, `full_name`, `kurum_sicil_no`, `unvan`, `balance`, `role`, `is_frozen`) şifre/PIN sütunu bulunmamaktaydı.

### Yapılan İşlemler:
- [x] `LoginScreen` içindeki **"T.C. E-Devlet Kapısı ile Giriş Yap"** butonu, PIN alanı ve `BankCubit.loginWithEDevlet()` fonksiyonu tamamen silindi.
- [x] `loginWithCredentials()` metodu yalnızca Supabase `profiles` tablosundaki gerçek memurlarla (`MEB-1042` Ahmet Yılmaz, `EGM-8831` Ayşe Demir, `MAL-0092` Mehmet Kaya, `MUF-0001` Kemal Bey veya sonradan eklenen memurların `kurum_sicil_no` / `full_name` değerleriyle) eşleştiğinde giriş yapacak şekilde düzeltildi; eşleşme yoksa kırmızı SnackBar ile *"Geçersiz Kurum Sicil No! Lütfen kayıtlı bir sicil numarası (Örn: MEB-1042, EGM-8831, MAL-0092, MUF-0001) giriniz."* hatası veriyor.
- [x] Giriş ekranındaki hızlı demo seçim kartları Supabase'deki 4 varsayılan memuru (`Ahmet Yılmaz - Öğretmen - 42.500 ₺`, `Ayşe Demir - Polis Memuru - 51.000 ₺`, `Mehmet Kaya - Kurum Mutemedi - 64.000 ₺`, `Kemal Bey - Bakanlık Başmüfettişi - 95.000 ₺`) bakiyeleriyle birlikte net olarak gösteriyor.

---

## 3. Kod Tabanında Taranarak Bulunan Diğer Sorunlar ve İyileştirmeler

- [x] **3.1. Veritabanı Sıfırlama (`reset_memur_bank`) Sonrası Aktif Rolün Korunması:**
  - **Çözüm:** `BankCubit.resetDatabaseAndReload()` çalıştırıldığında `keepProfileId: currentActiveId` korunarak, kullanıcı `Kemal Bey (admin)` veya `Mehmet Kaya (manager)` ise sıfırlama sonrasında da kendi rolünde kalması sağlandı.

- [x] **3.2. Dondurulmuş Hesap (`is_frozen == true`) Uyarısının Ana Sayfada (`HomeScreen`) Gösterilmesi:**
  - **Çözüm:** `ProfileHeaderWidget` içinde `profile.isFrozen == true` olduğunda dikkat çekici kırmızı *"MASAK / TEFTİŞ KURULU TEDBİRİ: Hesabınız Başmüfettişlik tarafından dondurulmuştur."* uyarı kutusu eklendi.

- [x] **3.3. Yeni Memur Ekleme (`_AddNewOfficerBottomSheet`) Form Temizliği ve Varsayılan Değerler:**
  - **Çözüm:** Yeni memur ekleme formundaki alanlar `TextFormField(initialValue: ...)` ve `ValueKey` ile senkronize edildi; memur eklendikten sonra form alanları temizleniyor.

- [x] **3.4. Geri Ödeme Planı Notunun Supabase `advance_requests.reason` Sütununu Kirletmemesi:**
  - **Çözüm:** Supabase `advance_requests` tablosundaki `reason` sütunu temiz ve SQL şemasındaki örneklerle (`Okul Dönemi Kırtasiye/Eğitim Avansı`, `Şark Görevi Taşınma Yolluğu`) birebir aynı formatta tutuldu; geri ödeme planı bilgisi onay bildirim mesajında gösterildi.
