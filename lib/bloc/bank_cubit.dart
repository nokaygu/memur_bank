import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/advance_request_model.dart';
import '../models/profile_model.dart';
import '../services/supabase_service.dart';
import 'bank_state.dart';

export 'bank_state.dart';

part 'bank_admin_actions.dart';
part 'bank_auth_actions.dart';
part 'bank_transfer_actions.dart';

/// MemurBank Ana Cubit Sınıfı (`BankCubit`).
/// Sorumluluklarına göre aksiyon metodları şu `part` dosyalarına ayrılmıştır:
/// - `bank_auth_actions.dart`: Splash, Login/Logout ve Hızlı Rol/Profil Geçiş Aksiyonları
/// - `bank_transfer_actions.dart`: Maaş Avansı Başvurusu ve FAST Para Transferi Aksiyonları
/// - `bank_admin_actions.dart`: Mutemetlik Onay/Red, Toplu Maaş ve Başmüfettiş Tanrı Modu Aksiyonları
class BankCubit extends Cubit<BankState> {
  final SupabaseService _supabaseService;
  bool _hasAnnouncedLiveConnection = false;

  BankCubit(
    this._supabaseService, {
    bool showSplash = false,
    bool startAuthenticated = true,
  }) : super(
         BankState.initial(
           showSplash: showSplash,
           isAuthenticated: startAuthenticated,
         ),
       );

  /// `part` dosyalarındaki aksiyon extension'larının `@protected emit` uyarısı olmadan
  /// güvenli şekilde yeni `BankState` yayınlamasını sağlayan kütüphane-içi yardımcı metod.
  void _emitState(BankState newState) => emit(newState);

  Future<void> loadInitialData({
    String? keepProfileId,
    bool announceConnection = false,
  }) async {
    emit(state.copyWith(isLoading: true, clearFeedback: true));
    final profiles = await _supabaseService.fetchProfiles();
    final requests = await _supabaseService.fetchAdvanceRequests();
    final usingFallback = _supabaseService.isUsingFallback;

    final targetId = keepProfileId ?? state.activeProfile.id;
    final active = profiles.firstWhere(
      (p) => p.id == targetId,
      orElse: () => profiles.first,
    );

    final recipients = profiles.where((p) => p.id != active.id).toList();
    final validRecipientId =
        recipients.any((r) => r.id == state.selectedRecipientId)
        ? state.selectedRecipientId
        : (recipients.isNotEmpty ? recipients.first.id : '');

    final safeNavIndex = (!active.isAdminOrManager && state.bottomNavIndex > 2)
        ? 0
        : state.bottomNavIndex;

    String? connectionFeedback;
    bool isError = false;
    // Splash ekranı açık değilken canlı bağlantı kurulduysa hemen SnackBar göster;
    // Splash açıkken bittiyse completeSplash() çağrıldığında LoginScreen üzerinde gösterilecek.
    if (!state.isSplashVisible) {
      if (!usingFallback &&
          (!_hasAnnouncedLiveConnection || announceConnection)) {
        _hasAnnouncedLiveConnection = true;
        connectionFeedback = '✓ Supabase Canlı Veritabanı Bağlantısı Kuruldu! Tüm işlemler bulut üzerinde senkronize ediliyor.';
      } else if (usingFallback && announceConnection) {
        connectionFeedback = 'Supabase bağlantısı kurulamadı. Yerel Fallback (Demo) modu aktif olarak devam ediyor.';
        isError = true;
      }
    }

    emit(
      state.copyWith(
        profiles: profiles,
        requests: requests,
        activeProfile: active,
        isUsingFallback: usingFallback,
        selectedRecipientId: validRecipientId,
        bottomNavIndex: safeNavIndex,
        isLoading: false,
        feedbackMessage: connectionFeedback,
        isErrorFeedback: isError,
      ),
    );
  }

  /// Fallback Banner'daki "Yeniden Bağlan" butonuyla bağlantıyı tekrar dener.
  Future<void> retrySupabaseConnection() async {
    await loadInitialData(announceConnection: true);
  }

  // Navigasyon, Filtre ve Görüntüleme Tercihleri
  // Navigasyon, Filtre ve Görüntüleme Tercihleri
  void setBottomNavIndex(int index) {
    if (!state.activeProfile.isAdminOrManager && index > 2) {
      emit(state.copyWith(bottomNavIndex: 0, clearFeedback: true));
      return;
    }
    emit(state.copyWith(bottomNavIndex: index, clearFeedback: true));
  }

  void setManagementTabIndex(int index) {
    emit(state.copyWith(managementTabIndex: index, clearFeedback: true));
  }

  void openManagementPanel({int subTabIndex = 0}) {
    if (!state.activeProfile.isAdminOrManager) return;
    emit(
      state.copyWith(
        bottomNavIndex: 3,
        managementTabIndex: subTabIndex,
        clearFeedback: true,
      ),
    );
  }

  void setSelectedFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter, clearFeedback: true));
  }

  void setOfficerSearchQuery(String query) {
    emit(state.copyWith(officerSearchQuery: query, clearFeedback: true));
  }

  void setOfficerSegmentFilter(String segment) {
    emit(state.copyWith(officerSegmentFilter: segment, clearFeedback: true));
  }

  void toggleBalanceVisibility() {
    emit(
      state.copyWith(
        isBalanceHidden: !state.isBalanceHidden,
        clearFeedback: true,
      ),
    );
  }

  void toggleKepNotifications(bool value) {
    emit(
      state.copyWith(
        kepNotificationsEnabled: value,
        feedbackMessage: value
            ? 'Hazine KEP & SMS Anlık Bildirimleri aktifleştirildi.'
            : 'KEP Bildirimleri sessize alındı.',
        isErrorFeedback: false,
      ),
    );
  }

  void toggleFastInstantConfirm(bool value) {
    emit(
      state.copyWith(
        fastInstantConfirmEnabled: value,
        feedbackMessage: value
            ? 'Memurlar arası FAST Kolay Adres transfer yetkisi açıldı.'
            : 'FAST Kolay Adres transfer yetkisi kısıtlandı.',
        isErrorFeedback: false,
      ),
    );
  }

  void notifyCopiedIban(String iban) {
    emit(
      state.copyWith(
        feedbackMessage: 'Maaş IBAN Panoya Kopyalandı: $iban',
        isErrorFeedback: false,
      ),
    );
  }

  void clearFeedback() {
    emit(state.copyWith(clearFeedback: true));
  }

  /// Yöntem C: Admin Key ile `reset_memur_bank` RPC çağrısı ve demo verileri sıfırlama.
  /// Aktif memurun UUID'si 4 varsayılan memurdan biriyse mevcut rolü korunur.
  Future<void> resetDatabaseAndReload() async {
    final currentActiveId = state.activeProfile.id;
    emit(state.copyWith(isLoading: true, clearFeedback: true));
    final remoteReset = await _supabaseService.resetMemurBankDatabase();
    await loadInitialData(keepProfileId: currentActiveId);
    emit(
      state.copyWith(
        transactions: BankState.buildDefaultTransactions(),
        feedbackMessage: remoteReset
            ? '✓ Supabase reset_memur_bank() RPC çalıştırıldı ve 4 memur + 2 avans demo verisi kuruldu!'
            : 'Demo veritabanı (4 memur + 2 bekleyen avans) yerel Fallback üzerinde sıfırlandı!',
        isErrorFeedback: false,
      ),
    );
  }
}
