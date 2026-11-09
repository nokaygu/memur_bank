---
name: memurbank-const-stateless-sliver-scaffold
description: MemurBank projesi için zorunlu const kullanımı, %100 StatelessWidget, BLoC/Cubit, CustomScrollView + PinnedHeaderSliver + SliverList.builder ve Supabase SQL şemasına birebir uyumlu modelleri üretir.
---

# MemurBank - Const, Stateless, Sliver & Supabase Scaffold

Bu yetenek, projede kod üretilirken **mümkün olan her yerde `const` kullanılmasını**, **hiçbir yerde `StatefulWidget` veya `shrinkWrap: true` kullanılmamasını**, **modellerin Supabase SQL sütunlarıyla birebir eşleşmesini** ve **tüm listelerin `CustomScrollView` + `PinnedHeaderSliver` + `SliverList.builder` ile kurulmasını** garanti altına alır.

## Temel Kurallar

1. **%100 `StatelessWidget` ve Zorunlu `const`:**
   - Tüm widget kurucuları `const` olarak tanımlanır (`const ProfileHeaderWidget({super.key});`).
   - `StatelessWidget` içinde `build` metodunda **asla `TextEditingController()` oluşturulmaz**! Tüm metin girdileri (`amount`, `reason`, `searchQuery` vb.) doğrudan `TextFormField(key: ValueKey('...-${state.formPresetVersion}'), initialValue: ..., onChanged: (val) => context.read<BankCubit>()...)` ile `BankCubit` içine aktarılır. Böylece hızlı tutar/gerekçe çiplerine basıldığında `formPresetVersion` artırılarak `TextFormField` içeriği `%100 StatelessWidget` kalarak anında güncellenir.
2. **Supabase SQL Sütun İsimlerine Sadakat:**
   - `profiles` tablosu sütunları: `id`, `full_name`, `kurum_sicil_no`, `unvan`, `balance`, `role`, `is_frozen`.
   - `advance_requests` tablosu sütunları: `id`, `user_id`, `full_name`, `amount`, `reason`, `status`, `created_at`.
3. **Kronolojik İlerleme Kaydı (`yapilanlar.md`):**
   - Tamamlanan her geliştirme adımı `yapilanlar.md` dosyasının en altına `[ADIM-XX | YYYY-AA-GG SS:DD]` etiketiyle (append-only) eklenir.

## Uygulama Şablonları

### 1. SQL ile Birebir Uyumlu Model Şablonları (`lib/models/`)

**`lib/models/profile_model.dart`:**
```dart
class ProfileModel {
  final String id;
  final String fullName;
  final String kurumSicilNo;
  final String unvan;
  final double balance;
  final String role; // 'user', 'manager', 'admin'
  final bool isFrozen;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.kurumSicilNo,
    required this.unvan,
    required this.balance,
    required this.role,
    this.isFrozen = false,
  });

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isAdminOrManager => role == 'admin' || role == 'manager';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      kurumSicilNo: json['kurum_sicil_no'] as String? ?? '',
      unvan: json['unvan'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      role: json['role'] as String? ?? 'user',
      isFrozen: json['is_frozen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'kurum_sicil_no': kurumSicilNo,
      'unvan': unvan,
      'balance': balance,
      'role': role,
      'is_frozen': isFrozen,
    };
  }
}
```

**`lib/models/advance_request_model.dart`:**
```dart
class AdvanceRequestModel {
  final String id;
  final String userId;
  final String fullName;
  final double amount;
  final String reason;
  final String status; // 'bekliyor', 'onaylandi', 'reddedildi'
  final DateTime createdAt;

  const AdvanceRequestModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory AdvanceRequestModel.fromJson(Map<String, dynamic> json) {
    return AdvanceRequestModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'bekliyor',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
```

### 2. Zorunlu Modern Sliver Ekran Şablonu (`lib/screens/home_screen.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bank_cubit.dart';
import '../stitch_ui/admin_dashboard_card.dart';
import '../stitch_ui/filter_bar_widget.dart';
import '../stitch_ui/profile_header_widget.dart';
import '../widgets/request_card_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            // 1. Üstteki normal widget'ımız (const zorunlu!)
            const SliverToBoxAdapter(
              child: ProfileHeaderWidget(),
            ),

            // Sadece Admin veya Manager ise görünen Teftiş Kartı (Yöntem B)
            if (state.activeProfile.isAdminOrManager)
              const SliverToBoxAdapter(
                child: AdminDashboardCard(),
              ),

            // 2. Kaydırınca yukarıya yapışan (Sticky) başlık - Sadece 3 satır!
            const PinnedHeaderSliver(
              child: FilterBarWidget(),
            ),

            // 3. Tıpkı ListView.builder gibi temiz sözdizimi ve gerçek Lazy Loading!
            SliverList.builder(
              itemCount: state.filteredRequests.length,
              itemBuilder: (context, index) => RequestCardWidget(
                request: state.filteredRequests[index],
              ),
            ),
          ],
        );
      },
    );
  }
}
```

### 3. Supabase Servisi ve Admin Sıfırlayıcı Şablonu (`lib/services/supabase_service.dart`)

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/advance_request_model.dart';
import '../models/profile_model.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> resetMemurBankDatabase() async {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final serviceRoleKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
    final adminClient = SupabaseClient(url, serviceRoleKey);
    await adminClient.rpc('reset_memur_bank');
  }

  Future<List<ProfileModel>> fetchProfiles() async {
    final data = await _client.from('profiles').select().order('full_name');
    return (data as List).map((e) => ProfileModel.fromJson(e)).toList();
  }

  Future<List<AdvanceRequestModel>> fetchAdvanceRequests() async {
    final data = await _client
        .from('advance_requests')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => AdvanceRequestModel.fromJson(e)).toList();
  }
}
```
