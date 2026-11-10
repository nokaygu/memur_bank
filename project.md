# MemurBank - Kamu & Memur Dijital Bankacılık ve Teftiş Platformu

Bu doküman, Flutter projesinde geliştirme yapacak olan Ajan (Antigravity), yapay zeka asistanları ve yazılım geliştiriciler için bağlayıcı bir kılavuzdur. Projede üretilen her kod satırı buradaki kurallara **UYMAK ZORUNDADIR**.

---

## 1. BİRİNCİ DERECE KIRMIZI ÇİZGİLER (İHLAL EDİLEMEZ)

1. **BLoC MİMARİSİ, %100 `StatelessWidget` VE KESİN `const` ZORUNLULUĞU:**
   - Durum yönetimi için `flutter_bloc` (`Bloc` / `Cubit`) kullanılacaktır.
   - Uygulamadaki **TÜM ekranlar (`screens/`) ve bileşenler (`widgets/`, `stitch_ui/`) %100 `StatelessWidget` OLACAKTIR**. `StatefulWidget` ve `setState` kullanımı **KESİNLİKLE YASAKTIR**.
   - **`const` KULLANIMI ZORUNLUDUR:** Tüm `StatelessWidget` kurucu metodları (`const MyWidget({super.key});`), sabit bileşenler, `SliverToBoxAdapter`, `PinnedHeaderSliver` ve `AppPaddings` değerlerinde `const` kullanımı **ZORUNLUDUR**. `analysis_options.yaml` içinde `prefer_const_constructors`, `prefer_const_declarations` ve `prefer_const_literals_to_create_immutables` kuralları aktif olacaktır.

2. **MODERN SLIVER LİSTE ZORUNLULUĞU (`shrinkWrap` VE KLASİK `ListView` YASAKTIR):**
   - Projede `shrinkWrap: true`, iç içe `ListView` veya klasik `SingleChildScrollView` + `Column` içinde liste kullanımı **KESİNLİKLE YASAKTIR**.
   - Kaydırılabilir tüm ekranlarda yalnızca aşağıdaki modern Flutter Sliver mimarisi (`CustomScrollView`, `const SliverToBoxAdapter`, `const PinnedHeaderSliver`, `SliverList.builder`) kullanılacaktır:

```dart
// ✅ ZORUNLU MODERN VE DOĞRU ÇÖZÜM
CustomScrollView(
  slivers: [
    // 1. Üstteki normal widget'ımız
    const SliverToBoxAdapter(
      child: ProfileHeaderWidget(),
    ),

    // 2. Kaydırınca yukarıya yapışan (Sticky) başlık - Sadece 3 satır!
    const PinnedHeaderSliver(
      child: FilterBarWidget(),
    ),

    // 3. Tıpkı ListView.builder gibi temiz sözdizimi ve gerçek Lazy Loading!
    SliverList.builder(
      itemCount: 1000,
      itemBuilder: (context, index) => ProductCard(index: index),
    ),
  ],
)
```

3. **TEK TEMA KLASÖRÜ DIŞINDA RENK YASAĞI + DARK MODE DESTEĞİ:**
   - `lib/theme/` klasörü dışındaki **HİÇBİR `.dart` dosyasında** `Color(0x...)` veya `Colors.xxx` kullanılmayacaktır.
   - Halkbank / Kamu Bankası konseptine uygun **Aydınlık (Light)** ve **Koyu (Dark)** tema desteği `ThemeCubit` ile yönetilecek; tüm renkler yalnızca `Theme.of(context).colorScheme` ve `MemurBankThemeExtension` üzerinden alınacaktır.

4. **DIŞARIDAN PADDING VE BOYUT KURALI (`lib/constants/app_paddings.dart`):**
   - Ekranların ve widget'ların içinde rastgele `EdgeInsets.all(16)` veya `SizedBox(height: 12)` gibi sabit değerler yazılmayacaktır.
   - Tüm boşluklar, köşe yuvarlaklıkları ve aralıklar `lib/constants/app_paddings.dart` dosyasından `static const` olarak çağrılacaktır.

5. **`stitch_ui` KLASÖRÜNÜN VE RESMİ LOGONUN KULLANIMI:**
   - Proje ana dizininde bulunan `stitch_ui` klasörü incelenecek ve yeniden kullanılabilir modern Stitch UI bankacılık bileşenleri `lib/stitch_ui/` altında `const StatelessWidget` olarak konumlandırılacaktır.
   - `stitch_ui/memurbank_resmi_logo/screen.png` resmi logosu hem uygulama içi (`SplashScreen`, `LoginScreen`, `MainShellScreen`) hem de Android, iOS ve Web platformlarında uygulama ikonu (Launcher Icon) olarak kullanılır.

6. **SADECE GEREKLİ BAĞIMLILIKLAR (`pubspec.yaml`):**
   - `supabase_flutter` (Supabase `profiles` ve `advance_requests` tabloları + `reset_memur_bank` RPC çağrısı)
   - `flutter_dotenv` (`.env` dosyasından `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` okuma)
   - `flutter_bloc` (State yönetimi)

7. **KRONOLOJİK İLERLEME TAKİBİ (`yapilanlar.md` & `yapilacaklar.md`):**
   - Yapılacak geliştirmeler `yapilacaklar.md` üzerinde planlanır; tamamlanan her çalışma `yapilanlar.md` dosyasının **en altına** `[ADIM-XX | YYYY-AA-GG SS:DD]` zaman/adım etiketiyle (append-only) eklenir.

---

## 2. Supabase Veritabanı Şeması ve `reset_memur_bank()` Fonksiyonu (Birebir Uyum Şartı)

Supabase tarafında çalışan ve Flutter içindeki **"Veritabanını Sıfırla ve Demo Verileri Kur"** butonuyla (`adminClient.rpc('reset_memur_bank')`) tetiklenen gerçek SQL yapısı aşağıdadır. Dart modelleri (`ProfileModel` ve `AdvanceRequestModel`) bu sütun isimleriyle **birebir aynı** olmak zorundadır:

```sql
CREATE OR REPLACE FUNCTION reset_memur_bank()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  DROP TABLE IF EXISTS advance_requests CASCADE;
  DROP TABLE IF EXISTS profiles CASCADE;

  CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    kurum_sicil_no TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    unvan TEXT NOT NULL,
    balance NUMERIC NOT NULL DEFAULT 0,
    role TEXT NOT NULL DEFAULT 'user', -- 'user', 'manager', 'admin'
    is_frozen BOOLEAN NOT NULL DEFAULT false
  );

  CREATE TABLE advance_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    reason TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'bekliyor', -- 'bekliyor', 'onaylandi', 'reddedildi'
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
  );

  ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
  ALTER TABLE advance_requests DISABLE ROW LEVEL SECURITY;

  GRANT ALL ON TABLE profiles TO anon, authenticated, service_role;
  GRANT ALL ON TABLE advance_requests TO anon, authenticated, service_role;

  INSERT INTO profiles (id, full_name, kurum_sicil_no, password, unvan, balance, role, is_frozen) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Ahmet Yılmaz', 'MEB-1042', '123', 'Öğretmen', 42500, 'user', false),
  ('22222222-2222-2222-2222-222222222222', 'Ayşe Demir', 'EGM-8831', '123', 'Polis Memuru', 51000, 'user', false),
  ('33333333-3333-3333-3333-333333333333', 'Mehmet Kaya', 'MAL-0092', '123', 'Kurum Mutemedi', 64000, 'manager', false),
  ('44444444-4444-4444-4444-444444444444', 'Kemal Bey', 'MUF-0001', '123', 'Bakanlık Başmüfettişi', 95000, 'admin', false);

  INSERT INTO advance_requests (user_id, full_name, amount, reason, status) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Ahmet Yılmaz', 15000, 'Okul Dönemi Kırtasiye/Eğitim Avansı', 'bekliyor'),
  ('22222222-2222-2222-2222-222222222222', 'Ayşe Demir', 25000, 'Şark Görevi Taşınma Yolluğu', 'bekliyor');

  NOTIFY pgrst, 'reload schema';
END;
$$;

SELECT reset_memur_bank();
```

---

## 3. Klasör Yapısı (Katman Bazlı Klasik Yapı + `stitch_ui`)

```text
.env                                     # SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY
yapilanlar.md                            # Kronolojik [ADIM-XX | ZAMAN] etiketli ilerleme kayıt sistemi
yapilacaklar.md                          # Planlanan ve tamamlanan ek geliştirmeler listesi
stitch_ui/                               # Ana dizindeki mevcut Stitch UI tasarım referans klasörü ve resmi logo
lib/
├── constants/
│   ├── app_paddings.dart                # Tüm static const padding, margin, radius, boyut ve SizedBox sabitleri
│   └── app_strings.dart                 # Sabit metinler, unvan ve kurum tanımları
├── theme/
│   ├── app_colors.dart                  # SADECE BU KLASÖRDE RENK KODU OLUR (Halkbank Mavisi, Hazine Altını, Teftiş Kırmızısı)
│   └── app_theme.dart                   # Light & Dark ThemeData ve MemurBankThemeExtension
├── models/
│   ├── profile_model.dart               # id, full_name, kurum_sicil_no, password, unvan, balance, role, is_frozen + IBAN & E-Bordro hesaplayıcılar
│   └── advance_request_model.dart       # id, user_id, full_name, amount, reason, status, created_at
├── services/
│   └── supabase_service.dart            # profiles ve advance_requests CRUD + Admin Key ile reset_memur_bank RPC + Fallback & Bağlantı Durumu
├── bloc/
│   ├── theme_cubit.dart                 # Light / Dark mod yönetimi
│   └── bank_cubit.dart                  # Splash/Auth, şifre doğrulama, Fallback/Canlı Supabase durumu, transfer, avans ve Tanrı Modu
├── stitch_ui/
│   ├── profile_header_widget.dart       # Bakiye, Sicil No, Unvan, Ayın 15'i Maaş Sayacı, E-Bordro & ATM Karekod BottomSheet'leri
│   ├── admin_dashboard_card.dart        # Yöntem B: Sadece Admin/Manager'ın ana sayfada gördüğü Teftiş Kurulu Kartı
│   ├── filter_bar_widget.dart           # PinnedHeaderSliver içinde kullanılan yapışkan filtre/sekme başlığı
│   └── treasury_charts_widget.dart      # Merkez Bankası / Hazine istatistik grafikleri (Toplam mevduat & dağıtılan kredi)
├── widgets/
│   ├── request_card_widget.dart         # Avans/kredi satırı (Onayla/Reddet) + TransactionItemWidget & Dijital Dekont BottomSheet
│   ├── officer_card_widget.dart         # Memur satırı ve tıklandığında açılan Tanrı Modu BottomSheet'i
│   └── role_switcher_bar.dart           # FallbackModeStickyBanner + Yöntem C: Geliştirici Hızlı Rol Değiştirme ve DB Sıfırlama
├── screens/
│   ├── splash_screen.dart               # Kurumsal 3D Açılış Ekranı (3B Madalyon Dönüşü & Otomatik Login Geçişi)
│   ├── login_screen.dart                # Kurum Sicil No + Şifre Girişi ve Hızlı Demo Oturum Seçici
│   ├── main_shell_screen.dart           # Splash/Login yönlendirici + Fallback Banner + Yöntem A: Role göre 3 veya 4 sekmeli BottomNavigationBar
│   ├── home_screen.dart                 # Ana Sayfa (Bakiye, Maaş Sayacı, Yöntem B Kartı, PinnedHeader, Talepler ve Hesap Hareketleri)
│   ├── transfer_screen.dart             # Para Transferi + "Maaş Avansı / Kredi" Başvurusu (Tek Sefer / 3 Taksit Geri Ödeme Planı)
│   ├── profile_screen.dart              # Dijital Memur Kimliği, IBAN Kopyala, KEP/FAST Ayarları, Dark Mode, Rol Değiştir, DB Sıfırla, Logout
│   └── management_panel_screen.dart     # Sadece 'manager' ve 'admin' için açılan 3 Sekmeli Teftiş / Yönetim Paneli
└── main.dart                            # dotenv.load(), Supabase.initialize() ve MultiBlocProvider kurulumu
```

---

## 4. MemurBank 3 Temel Rol, Giriş Akışı ve Yetki Matrisi

### 0. Kurumsal 3D Açılış (`SplashScreen`), Giriş (`LoginScreen`) ve Fallback/Supabase Gösterimi
- Uygulama açılışında resmi MemurBank logosu 3D perspektifli madalyon ve çift yörünge halkası animasyonuyla (`SplashScreen`) karşılar ve otomatik olarak `LoginScreen` ekranına geçer.
- Uygulama yerel Fallback modunda çalışıyorsa ekranın en üstünde kalıcı **`FallbackModeStickyBanner`** görünür; canlı Supabase bağlantısı kurulduğunda yeşil onay SnackBar'ı gösterilir.
- `LoginScreen` ekranında Kurum Sicil No (`MEB-1042`, `EGM-8831`, `MAL-0092`, `MUF-0001`) + Giriş Şifresi (`123`) ile doğrulama yapılarak giriş yapılabilir veya `SliverList.builder` içindeki **Hızlı Demo Oturum Seçici** kartlarından tek tıkla istenen role giriş yapılabilir.

### 1. Standart Memur (`role == 'user'` - Ahmet Yılmaz / Öğretmen, Ayşe Demir / Polis Memuru)
- **Alt Menü:** 3 Sekme görür (`Hesabım`, `Transfer & Avans`, `Profil`).
- **Özellikler:**
  - Kendi bakiyesini (`balance`), sicil numarasını (`kurum_sicil_no`), unvanını, **Ayın 15'i Maaş Yatış Tarihi Sayacını**, **T.C. Hazine E-Bordro Detayını** ve **Ortak Kamu ATM Karekod (QR)** penceresini görür.
  - Başka bir memura anlık FAST para transferi yapabilir; yapılan işlemler **Son Hesap Hareketleri & Dijital Dekontlar** listesine düşer.
  - **"Maaş Avansı / Memur Kredisi" Başvurusu:** Tutar (`amount`), geri ödeme planı (*Ayın 15'i Tek Sefer %0 Faiz* veya *3 Eşit Taksit*) ve sebep (`reason`) girerek `advance_requests` tablosuna talep ekler (Hesabı dondurulmuşsa `is_frozen == true` işlem engellenir).

### 2. Kurum Mutemedi / Şube Müdürü (`role == 'manager'` - Mehmet Kaya)
- **Alt Menü:** 4. gizli sekme belirir (**`Teftiş/Yönetim`**).
- **Yetkileri:**
  - Bekleyen (`status == 'bekliyor'`) avans/kredi başvurularını görür; **Yeşil (Onayla)** butonuna basınca memurun `balance` değerini artırıp talebi `'onaylandi'` yapar ve dijital dekont üretir, **Kırmızı (Reddet)** butonuna basınca `'reddedildi'` yapar.
  - **Ayın 15'i Toplu Maaş Dağıtımı Butonu:** Tek tıkla tüm aktif memurlara maaşlarını dağıtır.

### 3. Bakanlık Başmüfettişi / Merkez Bankası Yöneticisi (`role == 'admin'` - Kemal Bey)
- **Tanrı Modu (God Mode):**
  - Ana sayfada Bakiye kartının hemen altında parlak kırmızı **"Teftiş Kurulu Paneli (Bekleyen X kredi onayı var)"** kartını (Yöntem B) ve altta 4. sekmeyi (Yöntem A) görür.
  - **Yönetim Ekranındaki 3 Sekme:**
    1. **Onay Bekleyenler:** Tüm avans/kredi taleplerini onaylama veya reddetme.
    2. **Memur Listesi (Segment Filtreleme / Arama / Düzenleme):** *Tüm Personel*, *Şüpheli / Bloke* ve *Mutemet & Yöneticiler* filtreleriyle tüm memurlar `SliverList.builder` ile listelenir. Bir memura tıklandığında açılan **BottomSheet** içinde:
       - **"Promosyon Parası Gönder"** (Havadan para ekleme)
       - **"Maaş Yatır"**
       - **"Rol / Unvan Değiştir (Müdür Yap)"** (`role` değerini `'manager'` yapma veya unvan güncelleme)
       - **"Şüpheli İşlemi / Hesabı Dondur"** (`is_frozen` durumunu değiştirme)
       - Üst bar üzerinden sisteme **Yeni Memur Ekleme** (Ad Soyad, Sicil No, Giriş Şifresi, Unvan ve Başlangıç Bakiyesi ile).
    3. **Merkez Bankası / Hazine İstatistikleri:** Bankadaki toplam para hacmi (mevduat), dağıtılan krediler ve unvan bazlı dağılım grafikleri.
