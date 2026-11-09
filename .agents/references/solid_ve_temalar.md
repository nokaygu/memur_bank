# MemurBank Tema Sistemi (Light & Dark), `const` Lint Kuralları ve SOLID Rehberi

Bu doküman, `lib/theme/` klasörünün yapısını, Halkbank/Kamu konseptli Aydınlık ve Koyu tema renklerini ve sıkı `const` lint kurallarını tanımlar.

---

## 1. Tek Renk Merkezi (`lib/theme/app_colors.dart` & `app_theme.dart`)

Uygulamanın hiçbir yerinde `lib/theme/` dışından renk kodu çağrılamaz. Hem **Aydınlık (Light)** hem **Koyu (Dark)** mod desteklenir:

### Aydınlık Tema (Kamu & Halkbank Güven Paleti)
- **`primary`:** `Color(0xFF005BAA)` (Kamu / Halkbank Kurumsal Mavisi)
- **`onPrimary`:** `Color(0xFFFFFFFF)`
- **`primaryContainer`:** `Color(0xFFDBEAFE)` (Açık Kurumsal Mavi Yüzey)
- **`onPrimaryContainer`:** `Color(0xFF0A2540)`
- **`secondary`:** `Color(0xFFD97706)` (Hazine / Maaş Altın Sarısı)
- **`onSecondary`:** `Color(0xFFFFFFFF)`
- **`surface`:** `Color(0xFFF8FAFC)` (Ferah Bankacılık Beyazı)
- **`onSurface`:** `Color(0xFF0F172A)` (Koyu Lacivert/Antrasit Metin)
- **`error` / Teftiş Uyarısı:** `Color(0xFFDC2626)` (Bakanlık Teftiş Kırmızısı)

### Koyu Tema (Merkez Bankası Gece Paleti)
- **`primary`:** `Color(0xFF38BDF8)` (Parlak Siber Kamu Mavisi)
- **`onPrimary`:** `Color(0xFF082F49)`
- **`primaryContainer`:** `Color(0xFF1E293B)` (Koyu Lacivert Kart Yüzeyi)
- **`onPrimaryContainer`:** `Color(0xFFF1F5F9)`
- **`secondary`:** `Color(0xFFFBBF24)` (Parlak Hazine Altını)
- **`surface`:** `Color(0xFF0B0F19)` (Derin Gece Laciverti)
- **`onSurface`:** `Color(0xFFF8FAFC)`
- **`error` / Teftiş Uyarısı:** `Color(0xFFF87171)`

### `MemurBankThemeExtension` Özel Alanları
- `adminCardBg`: Teftiş Kurulu / God Mode kartı arka plan rengi.
- `onAdminCard`: Teftiş Kurulu kartı metin rengi.
- `approvedGreen`: Avans onaylandı / maaş yattı yeşili.
- `pendingAmber`: Bekleyen talep kehribar rengi.
- `rejectedRed`: Reddedilen talep / dondurulmuş hesap kırmızısı.

---

## 2. Zorunlu `const` ve `analysis_options.yaml` Kuralları

Projede `const` kullanımı zorunludur ve `analysis_options.yaml` içinde aşağıdaki kurallar aktif olmalıdır:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    prefer_const_constructors: error
    prefer_const_declarations: error
    prefer_const_literals_to_create_immutables: error
    deprecated_member_use: error

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - avoid_print
    - use_key_in_widget_constructors
```
