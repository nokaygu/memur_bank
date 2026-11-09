# MemurBank - Kamu & Memur Dijital Bankacılık ve Teftiş Platformu

**MemurBank**, kamu çalışanları (Öğretmen, Polis Memuru), Kurum Mutemetleri / Şube Müdürleri ve Bakanlık Başmüfettişleri için geliştirilmiş; **%100 `StatelessWidget`**, **zorunlu `const`**, **`flutter_bloc` (`Cubit`)**, **modern Flutter Sliver mimarisi (`CustomScrollView` + `PinnedHeaderSliver` + `SliverList.builder`)** ve **Supabase (`reset_memur_bank` RPC + Yerel Fallback)** altyapısıyla çalışan dijital bankacılık ve teftiş uygulamasıdır.

---

## Temel Mimari Prensipler

- **%100 `StatelessWidget` & Zorunlu `const`:** Uygulamadaki tüm ekranlar ve bileşenler `StatelessWidget` olarak tasarlanmıştır (`StatefulWidget` ve `setState` kullanılmaz). `analysis_options.yaml` içinde `prefer_const_constructors: error`, `prefer_const_declarations: error` ve `prefer_const_literals_to_create_immutables: error` kuralları aktiftir.
- **Zorunlu Modern Sliver Mimarisi:** Hiçbir ekranda `shrinkWrap: true` veya iç içe klasik `ListView` kullanılmaz; tüm kaydırılabilir ekranlar `CustomScrollView` + `const SliverToBoxAdapter` + `const PinnedHeaderSliver` + `SliverList.builder` yapısını kullanır.
- **Tek Tema Merkezi (`lib/theme/`) & Sabit Boşluklar (`lib/constants/app_paddings.dart`):** `lib/theme/` dışında hiçbir dosyada renk kodu (`Color`/`Colors`) yer almaz. Halkbank / Kamu Güven Paleti (**Light Mode**) ve Merkez Bankası Gece Paleti (**Dark Mode**) `ThemeCubit` ve `MemurBankThemeExtension` ile yönetilir.

---

## Roller ve Özellikler

1. **Kurumsal Açılış (`SplashScreen`) ve Giriş (`LoginScreen`):**
   - Resmi MemurBank logosu ve Hazine KEP doğrulama ekranıyla açılış.
   - Kurum Sicil No (`MEB-1042`, `EGM-8831`, `MAL-0092`, `MUF-0001`) + PIN girişi, **T.C. E-Devlet Kapısı** simülasyonu ve tek tıkla **Hızlı Demo Oturum Seçici**.
2. **Standart Memur (`user` - Ahmet Yılmaz / Ayşe Demir):**
   - Vadesiz Kamu Maaş Bakiyesi, **Ayın 15'i Maaş Yatış Sayacı**, **T.C. Hazine E-Bordro Detayı** ve **Ortak Kamu ATM Karekod (QR)** işlemleri.
   - Memurlar arası anlık FAST para transferi, **Son Hesap Hareketleri & Dijital İşlem Dekontu** görüntüleme.
   - **Maaş Avansı / Memur Kredisi Başvurusu:** Hızlı tutar ve gerekçe çipleri, *Ayın 15'i Tek Sefer (%0 Faiz)* veya *3 Eşit Taksit* geri ödeme planı seçimi.
3. **Kurum Mutemedi / Şube Müdürü (`manager` - Mehmet Kaya):**
   - Dinamik 4. Sekme (**`Teftiş/Yönetim`** - Yöntem A) ve ana sayfa yönetim kartı (Yöntem B).
   - Bekleyen avans/kredi taleplerini onaylama (memur bakiyesini anında artırır ve dijital dekont üretir) veya reddetme.
   - **Ayın 15'i Toplu Maaş Dağıtımı** simülasyonu.
4. **Bakanlık Başmüfettişi (`admin` - Kemal Bey - Tanrı Modu / God Mode):**
   - **Onay Bekleyenler**, **Memur Listesi** (*Tüm Personel / Şüpheli & Bloke / Mutemetler* filtreleriyle) ve **Merkez Bankası / Hazine İstatistikleri** grafikleri.
   - Memura tıklandığında açılan **Tanrı Modu BottomSheet**: *Promosyon Parası Gönder (+12.500 ₺)*, *Maaş Yatır (+45.000 ₺)*, *Rol/Unvan Değiştir (Müdür Yap)*, *Şüpheli Hesabı Dondur (MASAK Bloke)* ve *Yeni Memur Ekle*.
5. **Geliştirici Test Araçları (Yöntem C):**
   - Üst barda ve Profil ekranında tek tıkla **"Rol Değiştir (Test)"** butonu ve Admin Key ile `reset_memur_bank` RPC fonksiyonunu tetikleyen **"Veritabanını Sıfırla ve Demo Verileri Kur"** butonu.

---

## Proje Dokümanları

- [project.md](project.md) — Bağlayıcı mimari kurallar, klasör yapısı ve Supabase SQL şeması
- [yapilanlar.md](yapilanlar.md) — `[ADIM-XX | ZAMAN]` etiketli kronolojik geliştirme kayıt sistemi (Append-Only Log)
- [yapilacaklar.md](yapilacaklar.md) — İnceleme sonucu tespit edilen ve tamamlanan ek özellikler listesi
- [.agents/skills/skill.md](.agents/skills/skill.md) — Const, Stateless, Sliver ve Supabase kod şablonları
- [.agents/references/solid_ve_temalar.md](.agents/references/solid_ve_temalar.md) — Light & Dark tema paletleri ve lint kuralları
- [.agents/references/state_flow.md](.agents/references/state_flow.md) — BLoC/Cubit ve Supabase veri akışı rehberi
