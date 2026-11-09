# BLoC & Supabase Veri Akışı Rehberi (`state_flow.md`)

Bu doküman, `BankCubit`, `ThemeCubit` ve Supabase tabloları (`profiles`, `advance_requests`) arasındaki reaktif akışı tanımlar.

---

## 1. Başlangıç, `.env` Bağlantısı ve `SplashScreen -> LoginScreen` Akışı (`main.dart`)

1. Uygulama açılırken `await dotenv.load(fileName: ".env");` çalıştırılır.
2. `Supabase.initialize(url: url, publishableKey: anonKey)` ile bağlantı kurulur.
3. Eğer `.env` anahtarları henüz girilmemişse veya internet yoksa uygulamanın çökmemesi için `SupabaseService` içinde 4 örnek memuru (`Ahmet Yılmaz - user`, `Ayşe Demir - user`, `Mehmet Kaya - manager`, `Kemal Bey - admin`) ve 2 örnek avans talebini içeren otomatik **Fallback (Yedek) Veri Mekanizması** devreye girer.
4. `BankState` içerisindeki `isSplashVisible` ve `isAuthenticated` bayrakları sayesinde:
   - İlk açılışta resmi logolu `SplashScreen` gösterilir (`completeSplash()` ile tamamlanır).
   - Oturum kapalıyken (`isAuthenticated == false`) `LoginScreen` gösterilir; kullanıcı Kurum Sicil No (`MEB-1042`, `MUF-0001` vb.) + PIN ile, **T.C. E-Devlet Kapısı** simülasyon butonuyla veya **Hızlı Demo Oturum Seçici** listesinden tek tıkla oturum açabilir.
   - Üst bardaki veya `ProfileScreen` altındaki **Güvenli Çıkış (Logout)** butonuna basıldığında `logout()` çağrılarak tekrar `LoginScreen` ekranına dönülür.

---

## 2. Rol Değiştirme (Yöntem A, B, C) Akışı

- `BankState` içinde `activeProfile` (`ProfileModel`) tutulur.
- Kullanıcı üst bardaki veya Profil ekranındaki **"Rol Değiştir (Test)"** menüsünden:
  - **Standart Memur (`user` - Ahmet Yılmaz)** seçtiğinde: Alt barda 3 sekme (`Hesabım`, `Transfer & Avans`, `Profil`) görünür.
  - **Kurum Mutemedi (`manager` - Mehmet Kaya)** seçtiğinde: Alt barda **4. sekme (`Teftiş/Yönetim`)** belirir. Bekleyen avansları onaylayabilir ve **"Ayın 15'i Toplu Maaş Dağıt"** butonunu tetikleyebilir.
  - **Bakanlık Başmüfettişi (`admin` - Kemal Bey)** seçtiğinde: Hem ana sayfada kırmızı/vurgulu **"Teftiş Kurulu Paneli"** kartı (Yöntem B) hem de 4. sekmede **"Tanrı Modu (God Mode)"** aktif olur.

---

## 3. Tanrı Modu (God Mode), Avans Onay ve Dijital Dekont Akışı

1. **Hızlı Çip Senkronizasyonu ve Avans Başvurusu (`user`):**
   - `%100 StatelessWidget` kuralı gereği `TextEditingController` kullanılmaz; hızlı tutar (`+5.000 ₺`, `+15.000 ₺` vb.) veya gerekçe çiplerine tıklandığında `BankState.formPresetVersion` artırılarak `TextFormField(key: ValueKey(...), initialValue: ...)` bileşeninin anında senkronize olması sağlanır.
   - Memur geri ödeme planını (*Ayın 15'i Tek Sefer %0 Faiz* veya *3 Eşit Taksit*) seçip başvurduğunda (hesabı dondurulmamışsa `isFrozen == false`) `advance_requests` tablosuna `status: 'bekliyor'` olarak eklenir.
2. **Onay / Red ve Hesap Hareketleri (`manager` & `admin`):**
   - Yönetici yeşil onay butonuna bastığında talebin durumu `'onaylandi'` olur, ilgili memurun `profiles.balance` değeri talep tutarı kadar artırılır ve `BankState.transactions` listesine yeni bir `TransactionRecord` (Dijital Dekont kaydı) eklenir.
   - Yapılan her FAST para transferi, toplu maaş dağıtımı ve promosyon ödemesi de `transactions` listesine düşer; satıra tıklandığında **MemurBank Dijital İşlem Dekontu** BottomSheet'i açılır.
3. **Memur Yönetimi BottomSheet ve Segment Filtreleri (`admin`):**
   - Müfettiş 2. sekmede memurları **Tüm Personel**, **Şüpheli / Bloke** veya **Mutemet & Yöneticiler** segment çipleriyle filtreleyebilir.
   - Bir memura tıkladığında açılan BottomSheet üzerinden:
     - **Promosyon Parası Gönder:** Seçilen memurun bakiyesine anında promosyon tutarı eklenir.
     - **Maaş Yatır:** Seçilen memura maaş ödemesi geçilir.
     - **Rol / Unvan Değiştir (Müdür Yap):** Memurun `role` alanı `'manager'` veya `'user'` olarak güncellenir.
     - **Şüpheli İşlemi / Hesabı Dondur:** `is_frozen` durumu tersine çevrilir ve memur kartında donduruldu rozeti görünür.
4. **Veritabanını Sıfırla (`reset_memur_bank`):**
   - `SUPABASE_SERVICE_ROLE_KEY` kullanılarak `adminClient.rpc('reset_memur_bank')` çağrılır ve ardından `loadInitialData()` ile ekran anında tazelenir.
