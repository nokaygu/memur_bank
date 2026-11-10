# MemurBank — Kapsamlı Proje Denetimi ("Şeytanın Avukatı" Hata Tespiti) & Arayüz/Erişilebilirlik Geliştirme Planı (`yapilacaklar.md`)

> **Durum:** Tüm görevler (`1.1` - `11.1`) sırasıyla tamamlanmıştır (`[x]`).

---

## 🔴 BÖLÜM 1: Tespit Edilen Hatalar, Mantık Açıkları ve Tutarsızlıklar (Öncelikli Sorunlar)

### 1. `HomeScreen`'de Yorum Satırına Kaymış `if` Koşulu Yüzünden `AdminDashboardCard`'ın Herkese Görünmesi (Kritik UI Hatası)
- **Konum:** [`lib/screens/home_screen.dart` (Satır 33-34)](file:///home/berat/Projects/memur_bank/lib/screens/home_screen.dart#L33-L34)
- [x] **1.1.** `lib/screens/home_screen.dart` içindeki yorum satırı düzeltilerek `if (state.activeProfile.isAdminOrManager)` koşulu gerçek kod satırına alındı ve `AdminDashboardCard` içine de güvenlik kontrolü eklendi; artık yalnızca `manager` ve `admin` rollerinde görünüyor.

---

### 2. Kurum Mutemedi (`manager`) Rolünün Başmüfettiş "Tanrı Modu (God Mode)" Yetkilerine Erişebilmesi (Yetki Sızıntısı)
- **Konum:** [`lib/widgets/officer_card_widget.dart`](file:///home/berat/Projects/memur_bank/lib/widgets/officer_card_widget.dart) ve [`lib/bloc/bank_cubit.dart`](file:///home/berat/Projects/memur_bank/lib/bloc/bank_cubit.dart)
- [x] **2.1.** Tanrı Modu BottomSheet aksiyonları (`Promosyon Gönder`, `Maaş Yatır`, `Rol Değiştir`, `Hesabı Dondur`, `Yeni Memur Ekle`) ve `BankCubit` içindeki God Mode metodları yalnızca `state.activeProfile.isAdmin` için aktif hale getirildi; `manager` (Mutemet) memur kartına tıkladığında salt-okunur **Kurum Mutemetliği Sicil & Maaş Özeti** görüyor.

---

### 3. Başmüfettişin (`admin`) Kendi Rolünü Düşürüp Sistemdeki Tek Admin'i Yok Edebilmesi (Self-Lockout / Kendi Ayağına Sıkma)
- **Konum:** [`lib/bloc/bank_cubit.dart`](file:///home/berat/Projects/memur_bank/lib/bloc/bank_cubit.dart) ve [`lib/widgets/officer_card_widget.dart`](file:///home/berat/Projects/memur_bank/lib/widgets/officer_card_widget.dart)
- [x] **3.1.** Başmüfettişin kendi hesabı (`officer.id == state.activeProfile.id`) veya `admin` rolündeki bir profil üzerinde rol düşürme ve hesap dondurma işlemi yapması hem `BankCubit` seviyesinde hem de BottomSheet butonlarında engellendi.

---

### 4. "Yeni Memur Ekle" Penceresinin Hatalı Girişte Bile Kapanması ve Mükerrer Sicil No Açığı
- **Konum:** [`lib/screens/management_panel_screen.dart`](file:///home/berat/Projects/memur_bank/lib/screens/management_panel_screen.dart) ve [`lib/bloc/bank_cubit.dart`](file:///home/berat/Projects/memur_bank/lib/bloc/bank_cubit.dart)
- [x] **4.1.** `addNewOfficer()` metodu `Future<bool>` dönecek şekilde güncellendi; boş alan veya mükerrer `kurum_sicil_no` girildiğinde pencere kapanmadan içeride uyarı gösteriliyor ve yalnızca kayıt başarılı olduğunda BottomSheet kapanıyor.

---

### 5. Para Transferinde Dondurulmuş (`isFrozen`) Alıcıya Transfer, Eksik Alıcı Dekontu ve İşlevsiz FAST Şalteri
- **Konum:** [`lib/bloc/bank_cubit.dart`](file:///home/berat/Projects/memur_bank/lib/bloc/bank_cubit.dart) ve [`lib/screens/transfer_screen.dart`](file:///home/berat/Projects/memur_bank/lib/screens/transfer_screen.dart)
- [x] **5.1.** Alıcı memur `isFrozen` ise transfer engellendi ve alıcı listesinde kırmızı `"BLOKE HESAP"` uyarısı gösterildi; `fastInstantConfirmEnabled == false` ise transfer engellenip bilgi bandı gösterildi; transfer başarılı olduğunda hem gönderici (`-`) hem alıcı (`+`) için çift yönlü `TransactionRecord` dekontu oluşturuldu.

---

### 6. Hesap Hareketlerinde (`activeUserTransactions`) Başka Memurun Dekontlarının Görünmesi
- **Konum:** [`lib/bloc/bank_cubit.dart`](file:///home/berat/Projects/memur_bank/lib/bloc/bank_cubit.dart) ve [`lib/screens/home_screen.dart`](file:///home/berat/Projects/memur_bank/lib/screens/home_screen.dart)
- [x] **6.1.** Varsayılan hesap hareketleri 4 memurun (`Ahmet Yılmaz`, `Ayşe Demir`, `Mehmet Kaya`, `Kemal Bey`) kendi kimlikleriyle oluşturuldu ve `activeUserTransactions` bir memurun işlemi yoksa başkasının dekontlarını sızdırmayacak şekilde düzeltildi (`HomeScreen`'de boş durum mesajı eklendi).

---

### 7. Ana Sayfa Filtre Çubuğundaki (`FilterBarWidget`) Sayı Tutarsızlığı
- **Konum:** [`lib/stitch_ui/filter_bar_widget.dart`](file:///home/berat/Projects/memur_bank/lib/stitch_ui/filter_bar_widget.dart)
- [x] **7.1.** `FilterBarWidget` üzerindeki çip sayaçları (`Tümü`, `Bekleyenler`, `Onaylananlar`, `Reddedilenler`) `state.roleScopedRequests` kullanılarak aktif kullanıcının rol kapsamındaki gerçek kayıt sayılarını gösterecek şekilde güncellendi.

---

### 8. Proje Klasöründe Kalan 2 Adet Boş (0 Byte) Ölü Dosya
- **Konum:** `lib/screens/main_shell.dart` ve `lib/screens/transfer_advance_screen.dart`
- [x] **8.1.** Kullanılmayan 0 byte'lık `lib/screens/main_shell.dart` ve `lib/screens/transfer_advance_screen.dart` dosyaları silindi.

---

## 🎨 BÖLÜM 2: Daha Erişilebilir, Anlaşılır ve Şık Bir Arayüz İçin Geliştirme / Güzelleştirme Önerileri

### 9. Tutarlı Para Birimi Formatlama (`42.500,00 ₺`)
- [x] **9.1.** [`ProfileModel.formatCurrency()`](file:///home/berat/Projects/memur_bank/lib/models/profile_model.dart#L23-L39) merkezi formatlayıcısı eklendi ve tüm ekranlarda/BottomSheet pencerelerinde tutarların binlik noktalı (`42.500 ₺` / `42.500,00 ₺`) gösterilmesi sağlandı.

### 10. Üst Barda / Giriş Ekranında Net Bağlantı Durumu Rozeti ve Klavye Erişilebilirliği
- [x] **10.1.** Tüm form alanlarına (`LoginScreen`, `TransferScreen`, `AddNewOfficerBottomSheet`) klavye erişilebilirlik aksiyonları (`textInputAction`, `onFieldSubmitted`) ve `LoginScreen` AppBar / `ProfileScreen` kimlik kartına canlı bağlantı durum rozeti ([`ConnectionStatusBadge`](file:///home/berat/Projects/memur_bank/lib/widgets/role_switcher_bar.dart#L11-L60)) eklendi.

### 11. `ManagementPanelScreen` "1. Onaylar" Sekmesinde Bekleyen / Geçmiş Ayrımı ve Kritik İşlem Onay Diyaloğu
- [x] **11.1.** [`RoleSwitcherBar`](file:///home/berat/Projects/memur_bank/lib/widgets/role_switcher_bar.dart#L131-L176) içindeki `"Veritabanını Sıfırla ve Demo Verileri Kur"` butonu için onay diyaloğu (`AlertDialog`) eklendi ve Yönetim Paneli 1. sekmesinde bekleyen talepler (`sortedRequestsForManagement`) öncelikli olarak en üstte sıralandı.
