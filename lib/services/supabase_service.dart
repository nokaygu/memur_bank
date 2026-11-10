import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/advance_request_model.dart';
import '../models/profile_model.dart';

/// Supabase veritabanı (`profiles` ve `advance_requests`) ile haberleşen servis.
/// Bağlantı veya `.env` anahtarları bulunmadığında uygulamanın kesintisiz test
/// edilebilmesi için SQL şemasındaki 4 örnek memur ve 2 bekleyen avans talebiyle
/// birebir çalışan yerel Fallback (Yedek) veri mekanizması içerir.
class SupabaseService {
  bool _isSupabaseInitialized = false;
  // Varsayılan olarak false başlar; yalnızca gerçekten Fallback'e düşüldüğünde true olur!
  bool _isUsingFallback = false;
  String? _lastConnectionError;

  /// Uygulamanın şu an yerel Fallback (demo) modunda mı yoksa canlı Supabase üzerinde mi çalıştığını döner.
  bool get isUsingFallback => _isUsingFallback;

  /// Son bağlantı hatası varsa detayını döner.
  String? get lastConnectionError => _lastConnectionError;

  /// Kullanıcı `.env` içine yanlışlıkla `https://supabase.com/dashboard/project/<id>`
  /// yapıştırsa bile otomatik olarak `https://<id>.supabase.co` REST API adresine dönüştürür.
  static String normalizeSupabaseUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return '';
    final dashboardRegex = RegExp(
      r'supabase\.com/dashboard/project/([a-zA-Z0-9_-]+)',
    );
    final match = dashboardRegex.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      final projectId = match.group(1);
      return 'https://$projectId.supabase.co';
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  // SQL'deki reset_memur_bank() verileriyle birebir aynı yerel Fallback deposu
  static const List<ProfileModel> _initialFallbackProfiles = [
    ProfileModel(
      id: '11111111-1111-1111-1111-111111111111',
      fullName: 'Ahmet Yılmaz',
      kurumSicilNo: 'MEB-1042',
      password: '123',
      unvan: 'Öğretmen',
      balance: 42500.0,
      role: 'user',
      isFrozen: false,
    ),
    ProfileModel(
      id: '22222222-2222-2222-2222-222222222222',
      fullName: 'Ayşe Demir',
      kurumSicilNo: 'EGM-8831',
      password: '123',
      unvan: 'Polis Memuru',
      balance: 51000.0,
      role: 'user',
      isFrozen: false,
    ),
    ProfileModel(
      id: '33333333-3333-3333-3333-333333333333',
      fullName: 'Mehmet Kaya',
      kurumSicilNo: 'MAL-0092',
      password: '123',
      unvan: 'Kurum Mutemedi',
      balance: 64000.0,
      role: 'manager',
      isFrozen: false,
    ),
    ProfileModel(
      id: '44444444-4444-4444-4444-444444444444',
      fullName: 'Kemal Bey',
      kurumSicilNo: 'MUF-0001',
      password: '123',
      unvan: 'Bakanlık Başmüfettişi',
      balance: 95000.0,
      role: 'admin',
      isFrozen: false,
    ),
  ];

  List<ProfileModel> _fallbackProfiles = List<ProfileModel>.from(
    _initialFallbackProfiles,
  );

  List<AdvanceRequestModel> _fallbackRequests = _buildInitialRequests();

  static List<AdvanceRequestModel> _buildInitialRequests() {
    final now = DateTime.now();
    return [
      AdvanceRequestModel(
        id: 'req-1001',
        userId: '11111111-1111-1111-1111-111111111111',
        fullName: 'Ahmet Yılmaz',
        amount: 15000.0,
        reason: 'Okul Dönemi Kırtasiye/Eğitim Avansı',
        status: 'bekliyor',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AdvanceRequestModel(
        id: 'req-1002',
        userId: '22222222-2222-2222-2222-222222222222',
        fullName: 'Ayşe Demir',
        amount: 25000.0,
        reason: 'Şark Görevi Taşınma Yolluğu',
        status: 'bekliyor',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }

  void markInitialized(bool value) {
    _isSupabaseInitialized = value;
    // Başlangıçta Supabase initialize edildiyse Fallback kapalı (false) başlar;
    // edilmediyse (ör. test ortamı veya .env yok) doğrudan Fallback (true) olur.
    _isUsingFallback = !value;
  }

  bool get isRemoteEnabled {
    if (!_isSupabaseInitialized) return false;
    final url = normalizeSupabaseUrl(dotenv.maybeGet('SUPABASE_URL') ?? '');
    final anonKey = (dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '').trim();
    return url.isNotEmpty &&
        anonKey.isNotEmpty &&
        !url.contains('your-project-id');
  }

  SupabaseClient get _client => Supabase.instance.client;

  /// Admin Key (`SUPABASE_SERVICE_ROLE_KEY`) ile `reset_memur_bank` RPC fonksiyonunu tetikler.
  /// Bağlantı yoksa yerel fallback verilerini de sıfırlar.
  Future<bool> resetMemurBankDatabase() async {
    _fallbackProfiles = List<ProfileModel>.from(_initialFallbackProfiles);
    _fallbackRequests = _buildInitialRequests();

    final url = normalizeSupabaseUrl(dotenv.maybeGet('SUPABASE_URL') ?? '');
    final serviceRoleKey = (dotenv.maybeGet('SUPABASE_SERVICE_ROLE_KEY') ?? '')
        .trim();

    if (url.isNotEmpty &&
        serviceRoleKey.isNotEmpty &&
        !url.contains('your-project-id')) {
      try {
        final adminClient = SupabaseClient(url, serviceRoleKey);
        await adminClient.rpc('reset_memur_bank');
        _isUsingFallback = false;
        _lastConnectionError = null;
        return true;
      } catch (e) {
        _isUsingFallback = true;
        _lastConnectionError = e.toString();
        _isUsingFallback = true;
        return false;
      }
    }
    _isUsingFallback = true;
    return false;
  }

  Future<List<ProfileModel>> fetchProfiles() async {
    if (isRemoteEnabled) {
      try {
        final data = await _client.from('profiles').select().order('full_name');
        final list = (data as List)
            .map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _isUsingFallback = false;
        _lastConnectionError = null;
        if (list.isNotEmpty) {
          _fallbackProfiles = list;
          _isUsingFallback = false;
          return list;
        }
        return list;
      } catch (e) {
        _isUsingFallback = true;
        _lastConnectionError = e.toString();
      }
    } else {
      _isUsingFallback = true;
    }
    _isUsingFallback = true;
    return List<ProfileModel>.from(_fallbackProfiles);
  }

  Future<List<AdvanceRequestModel>> fetchAdvanceRequests() async {
    if (isRemoteEnabled && !_isUsingFallback) {
      try {
        final data = await _client
            .from('advance_requests')
            .select()
            .order('created_at', ascending: false);
        final list = (data as List)
            .map((e) => AdvanceRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _fallbackRequests = list;
        _isUsingFallback = false;
        return list;
      } catch (_) {
        // profiles tablosu bağlandıysa advance_requests hatası yüzünden ana bağlantıyı koparma
        return List<AdvanceRequestModel>.from(_fallbackRequests);
      }
    }
    _isUsingFallback = true;
    return List<AdvanceRequestModel>.from(_fallbackRequests);
  }

  Future<void> updateProfileBalance(String profileId, double newBalance) async {
    _fallbackProfiles = _fallbackProfiles.map((p) {
      if (p.id == profileId) {
        return p.copyWith(balance: newBalance);
      }
      return p;
    }).toList();

    if (isRemoteEnabled) {
      try {
        await _client
            .from('profiles')
            .update({'balance': newBalance})
            .eq('id', profileId);
        _isUsingFallback = false;
      } catch (e) {
        _isUsingFallback = true;
        _lastConnectionError = e.toString();
      }
    }
  }

  Future<void> updateProfileRoleAndTitle({
    required String profileId,
    required String role,
    required String unvan,
  }) async {
    _fallbackProfiles = _fallbackProfiles.map((p) {
      if (p.id == profileId) {
        return p.copyWith(role: role, unvan: unvan);
      }
      return p;
    }).toList();

    if (isRemoteEnabled) {
      try {
        await _client
            .from('profiles')
            .update({'role': role, 'unvan': unvan})
            .eq('id', profileId);
        _isUsingFallback = false;
      } catch (e) {
        _isUsingFallback = true;
        _lastConnectionError = e.toString();
      }
    }
  }

  Future<void> toggleFreezeStatus(String profileId, bool isFrozen) async {
    _fallbackProfiles = _fallbackProfiles.map((p) {
      if (p.id == profileId) {
        return p.copyWith(isFrozen: isFrozen);
      }
      return p;
    }).toList();

    if (isRemoteEnabled) {
      try {
        await _client
            .from('profiles')
            .update({'is_frozen': isFrozen})
            .eq('id', profileId);
        _isUsingFallback = false;
      } catch (e) {
        _isUsingFallback = true;
        _lastConnectionError = e.toString();
      }
    }
  }

  Future<void> createOfficerProfile({
    required String fullName,
    required String kurumSicilNo,
    required String password,
    required String unvan,
    required double initialBalance,
    String role = 'user',
  }) async {
    final newProfile = ProfileModel(
      id: 'memur-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      kurumSicilNo: kurumSicilNo,
      password: password,
      unvan: unvan,
      balance: initialBalance,
      role: role,
      isFrozen: false,
    );

    if (isRemoteEnabled) {
      try {
        final inserted = await _client
            .from('profiles')
            .insert({
              'full_name': fullName,
              'kurum_sicil_no': kurumSicilNo,
              'password': password,
              'unvan': unvan,
              'balance': initialBalance,
              'role': role,
              'is_frozen': false,
            })
            .select()
            .single();
        _isUsingFallback = false;
        _fallbackProfiles = [
          ..._fallbackProfiles,
          ProfileModel.fromJson(inserted),
        ];
        return;
      } catch (e) {
        _isUsingFallback = true;
        _lastConnectionError = e.toString();
      }
    }

    _fallbackProfiles = [..._fallbackProfiles, newProfile];
  }

  Future<void> createAdvanceRequest({
    required String userId,
    required String fullName,
    required double amount,
    required String reason,
  }) async {
    final localReq = AdvanceRequestModel(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      fullName: fullName,
      amount: amount,
      reason: reason,
      status: 'bekliyor',
      createdAt: DateTime.now(),
    );

    if (isRemoteEnabled) {
      try {
        final inserted = await _client
            .from('advance_requests')
            .insert({
              'user_id': userId,
              'full_name': fullName,
              'amount': amount,
              'reason': reason,
              'status': 'bekliyor',
            })
            .select()
            .single();
        _isUsingFallback = false;
        _fallbackRequests = [
          AdvanceRequestModel.fromJson(inserted),
          ..._fallbackRequests,
        ];
        return;
      } catch (e) {
        _isUsingFallback = true;
        _lastConnectionError = e.toString();
      }
    }

    _fallbackRequests = [localReq, ..._fallbackRequests];
  }

  Future<void> updateAdvanceRequestStatus({
    required String requestId,
    required String status,
  }) async {
    _fallbackRequests = _fallbackRequests.map((r) {
      if (r.id == requestId) {
        return r.copyWith(status: status);
      }
      return r;
    }).toList();

    if (isRemoteEnabled) {
      try {
        await _client
            .from('advance_requests')
            .update({'status': status})
            .eq('id', requestId);
        _isUsingFallback = false;
      } catch (e) {
        _isUsingFallback = true;
        _lastConnectionError = e.toString();
      }
    }
  }
}
