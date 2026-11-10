import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/advance_request_model.dart';
import '../models/profile_model.dart';
import '../services/supabase_service.dart';

/// Hesap Hareketleri & Dijital Dekont kaydı modeli.
class TransactionRecord {
  final String id;
  final String userId;
  final String title;
  final String subtitle;
  final String category;
  final String referenceCode;
  final double amount;
  final bool isIncoming;
  final DateTime createdAt;

  const TransactionRecord({
    required this.id,
    required this.userId,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.referenceCode,
    required this.amount,
    required this.isIncoming,
    required this.createdAt,
  });
}

class BankState {
  final List<ProfileModel> profiles;
  final List<AdvanceRequestModel> requests;
  final List<TransactionRecord> transactions;
  final ProfileModel activeProfile;

  // Açılış (Splash), Kimlik Doğrulama (Authentication) ve Supabase/Fallback Durumu
  final bool isSplashVisible;
  final bool isAuthenticated;
  final bool isUsingFallback;
  final String loginSicilInput;
  final String loginPasswordInput;
  final bool isLoginPasswordObscured;

  // Navigasyon ve Filtreler
  final int bottomNavIndex;
  final int managementTabIndex; // 0: Onay Bekleyenler, 1: Memur Listesi, 2: Hazine İstatistikleri
  final String selectedFilter; // 'all', 'bekliyor', 'onaylandi', 'reddedildi'
  final String officerSearchQuery;
  final String officerSegmentFilter; // 'all', 'frozen', 'managers'
  final bool isBalanceHidden;
  final bool isLoading;
  final String? feedbackMessage;
  final bool isErrorFeedback;

  // Transfer & Avans Form Alanları (%100 StatelessWidget için Cubit üzerinde tutulur)
  final int transferModeTab; // 0: Maaş Avansı / Memur Kredisi, 1: Memurlar Arası Para Transferi
  final String advanceAmountInput;
  final String advanceReasonInput;
  final int
  repaymentPlanIndex; // 0: Ayın 15'i Tek Sefer (%0 Faiz), 1: 3 Eşit Taksit
  final String selectedRecipientId;
  final String transferAmountInput;
  final String transferNoteInput;
  final int
  formPresetVersion; // Hızlı çip seçiminde TextFormField senkronizasyonu için

  // Profil Güvenlik & Bildirim Tercihleri
  final bool kepNotificationsEnabled;
  final bool fastInstantConfirmEnabled;

  // Yeni Memur Ekleme Form Alanları (Tanrı Modu)
  final String newOfficerName;
  final String newOfficerSicilNo;
  final String newOfficerPassword;
  final String newOfficerUnvan;
  final String newOfficerBalance;

  const BankState({
    required this.profiles,
    required this.requests,
    required this.transactions,
    required this.activeProfile,
    this.isSplashVisible = false,
    this.isAuthenticated = true,
    // Varsayılan olarak false başlar; yalnızca gerçekten Fallback'e düşüldüğünde true olur!
    this.isUsingFallback = false,
    this.loginSicilInput = '',
    this.loginPasswordInput = '',
    this.isLoginPasswordObscured = true,
    this.bottomNavIndex = 0,
    this.managementTabIndex = 0,
    this.selectedFilter = 'all',
    this.officerSearchQuery = '',
    this.officerSegmentFilter = 'all',
    this.isBalanceHidden = false,
    this.isLoading = false,
    this.feedbackMessage,
    this.isErrorFeedback = false,
    this.transferModeTab = 0,
    this.advanceAmountInput = '15000',
    this.advanceReasonInput = 'Okul Dönemi Kırtasiye/Eğitim Avansı',
    this.repaymentPlanIndex = 0,
    this.selectedRecipientId = '22222222-2222-2222-2222-222222222222',
    this.transferAmountInput = '2500',
    this.transferNoteInput = 'Ortak Lojman Aidat / Kira Payı',
    this.formPresetVersion = 0,
    this.kepNotificationsEnabled = true,
    this.fastInstantConfirmEnabled = true,
    this.newOfficerName = '',
    this.newOfficerSicilNo = '',
    this.newOfficerPassword = '',
    this.newOfficerUnvan = '',
    this.newOfficerBalance = '',
  });

  factory BankState.initial({
    bool showSplash = false,
    bool isAuthenticated = true,
  }) {
    const defaultUser = ProfileModel(
      id: '11111111-1111-1111-1111-111111111111',
      fullName: 'Ahmet Yılmaz',
      kurumSicilNo: 'MEB-1042',
      password: '123',
      unvan: 'Öğretmen',
      balance: 42500.0,
      role: 'user',
      isFrozen: false,
    );
    return BankState(
      profiles: const [defaultUser],
      requests: const [],
      transactions: _buildDefaultTransactions(),
      activeProfile: defaultUser,
      isSplashVisible: showSplash,
      isAuthenticated: isAuthenticated,
      isUsingFallback: false,
    );
  }

  static List<TransactionRecord> _buildDefaultTransactions() {
    final now = DateTime.now();
    return [
      // Ahmet Yılmaz (11111111-...)
      TransactionRecord(
        id: 'tx-101',
        userId: '11111111-1111-1111-1111-111111111111',
        title: 'Hazine Kamu Maaş Ödemesi',
        subtitle: 'T.C. Millî Eğitim Bakanlığı • Bordro: 2026/10',
        category: 'Maaş Yatışı',
        referenceCode: 'MB-KEP-908412',
        amount: 42500.0,
        isIncoming: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TransactionRecord(
        id: 'tx-102',
        userId: '11111111-1111-1111-1111-111111111111',
        title: 'Kurum Maaş Promosyonu (2. Taksit)',
        subtitle: 'MEB 2026 Protokolü • Teşvik Ödemesi',
        category: 'Promosyon',
        referenceCode: 'MB-PRM-441029',
        amount: 8000.0,
        isIncoming: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      TransactionRecord(
        id: 'tx-103',
        userId: '11111111-1111-1111-1111-111111111111',
        title: 'FAST Gönderim: Ayşe Demir',
        subtitle: 'EGM-8831 • Ortak Lojman Aidatı',
        category: 'FAST Transfer',
        referenceCode: 'FAST-773190',
        amount: 1250.0,
        isIncoming: false,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      // Ayşe Demir (22222222-...)
      TransactionRecord(
        id: 'tx-201',
        userId: '22222222-2222-2222-2222-222222222222',
        title: 'Hazine Kamu Maaş Ödemesi',
        subtitle: 'T.C. İçişleri Bakanlığı (EGM) • Bordro: 2026/10',
        category: 'Maaş Yatışı',
        referenceCode: 'MB-KEP-908550',
        amount: 51000.0,
        isIncoming: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TransactionRecord(
        id: 'tx-202',
        userId: '22222222-2222-2222-2222-222222222222',
        title: 'FAST Gelen Transfer: Ahmet Yılmaz',
        subtitle: 'MEB-1042 • Ortak Lojman Aidatı',
        category: 'FAST Transfer',
        referenceCode: 'FAST-773190',
        amount: 1250.0,
        isIncoming: true,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      // Mehmet Kaya (33333333-...)
      TransactionRecord(
        id: 'tx-301',
        userId: '33333333-3333-3333-3333-333333333333',
        title: 'Hazine Kamu Maaş Ödemesi',
        subtitle: 'T.C. Hazine ve Maliye Bakanlığı • Bordro: 2026/10',
        category: 'Maaş Yatışı',
        referenceCode: 'MB-KEP-908610',
        amount: 64000.0,
        isIncoming: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      // Kemal Bey (44444444-...)
      TransactionRecord(
        id: 'tx-401',
        userId: '44444444-4444-4444-4444-444444444444',
        title: 'Hazine Başmüfettişlik Maaş & Kıdem Ödemesi',
        subtitle: 'T.C. Hazine Teftiş Kurulu Başkanlığı • Bordro: 2026/10',
        category: 'Maaş Yatışı',
        referenceCode: 'MB-KEP-908700',
        amount: 95000.0,
        isIncoming: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  /// Aktif kullanıcının rol kapsamına giren tüm avans/kredi talepleri
  List<AdvanceRequestModel> get roleScopedRequests =>
      activeProfile.isAdminOrManager
      ? requests
      : requests.where((r) => r.userId == activeProfile.id).toList();

  /// Ana ekranda seçili filtreye ve aktif role göre gösterilecek avans/kredi talepleri
  List<AdvanceRequestModel> get filteredRequests {
    final roleScoped = roleScopedRequests;
    if (selectedFilter == 'all') {
      return roleScoped;
    }
    return roleScoped.where((r) => r.status == selectedFilter).toList();
  }

  /// Yönetim Paneli 1. Sekmesinde bekleyen talepleri en üstte gösteren sıralı liste
  List<AdvanceRequestModel> get sortedRequestsForManagement {
    final pending = requests.where((r) => r.isPending).toList();
    final decided = requests.where((r) => !r.isPending).toList();
    return [...pending, ...decided];
  }

  /// Aktif kullanıcı veya yönetici için hesap hareketleri listesi (Başka memurun dekontunu sızdırmaz)
  List<TransactionRecord> get activeUserTransactions {
    if (activeProfile.isAdminOrManager) {
      return transactions;
    }
    return transactions.where((t) => t.userId == activeProfile.id).toList();
  }

  /// Bekleyen talep listesi (`status == 'bekliyor'`)
  List<AdvanceRequestModel> get pendingRequests =>
      requests.where((r) => r.isPending).toList();

  /// Arama sorgusu ve segment filtresine göre memur listesi
  List<ProfileModel> get filteredOfficers {
    final query = officerSearchQuery.trim().toLowerCase();
    return profiles.where((p) {
      if (officerSegmentFilter == 'frozen' && !p.isFrozen) {
        return false;
      }
      if (officerSegmentFilter == 'managers' && !p.isAdminOrManager) {
        return false;
      }
      if (query.isEmpty) return true;
      return p.fullName.toLowerCase().contains(query) ||
          p.kurumSicilNo.toLowerCase().contains(query) ||
          p.unvan.toLowerCase().contains(query) ||
          p.role.toLowerCase().contains(query);
    }).toList();
  }

  /// Aktif memur dışındaki transfer alıcı adayları
  List<ProfileModel> get transferRecipients =>
      profiles.where((p) => p.id != activeProfile.id).toList();

  /// Bankadaki toplam mevduat hacmi
  double get totalDepositVolume =>
      profiles.fold(0.0, (sum, item) => sum + item.balance);

  /// Onaylanan toplam kredi/avans hacmi
  double get totalApprovedCreditVolume => requests
      .where((r) => r.isApproved)
      .fold(0.0, (sum, item) => sum + item.amount);

  /// Bekleyen toplam kredi/avans hacmi
  double get totalPendingCreditVolume => requests
      .where((r) => r.isPending)
      .fold(0.0, (sum, item) => sum + item.amount);

  /// Seçili avans tutarının sayısal karşılığı
  double get parsedAdvanceAmount =>
      double.tryParse(advanceAmountInput.replaceAll(',', '.').trim()) ?? 0.0;

  /// Aylık taksit tutarı (Tek sefer ise tamamı, 3 taksit ise 1/3)
  double get monthlyInstallmentAmount => repaymentPlanIndex == 0
      ? parsedAdvanceAmount
      : (parsedAdvanceAmount / 3.0);

  /// Ayın 15'i maaş yatış tarihine kalan gün hesabı
  int get daysUntilSalaryDay {
    final now = DateTime.now();
    final currentMonth15 = DateTime(now.year, now.month, 15);
    if (now.day == 15) return 0;
    if (now.day < 15) {
      return currentMonth15
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;
    }
    final nextMonth = now.month == 12
        ? DateTime(now.year + 1, 1, 15)
        : DateTime(now.year, now.month + 1, 15);
    return nextMonth.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  double get salaryCycleProgress {
    final remaining = daysUntilSalaryDay;
    final progress = (30 - remaining) / 30.0;
    return progress.clamp(0.1, 1.0);
  }

  BankState copyWith({
    List<ProfileModel>? profiles,
    List<AdvanceRequestModel>? requests,
    List<TransactionRecord>? transactions,
    ProfileModel? activeProfile,
    bool? isSplashVisible,
    bool? isAuthenticated,
    bool? isUsingFallback,
    String? loginSicilInput,
    String? loginPasswordInput,
    bool? isLoginPasswordObscured,
    int? bottomNavIndex,
    int? managementTabIndex,
    String? selectedFilter,
    String? officerSearchQuery,
    String? officerSegmentFilter,
    bool? isBalanceHidden,
    bool? isLoading,
    String? feedbackMessage,
    bool clearFeedback = false,
    bool? isErrorFeedback,
    int? transferModeTab,
    String? advanceAmountInput,
    String? advanceReasonInput,
    int? repaymentPlanIndex,
    String? selectedRecipientId,
    String? transferAmountInput,
    String? transferNoteInput,
    int? formPresetVersion,
    bool? kepNotificationsEnabled,
    bool? fastInstantConfirmEnabled,
    String? newOfficerName,
    String? newOfficerSicilNo,
    String? newOfficerPassword,
    String? newOfficerUnvan,
    String? newOfficerBalance,
  }) {
    return BankState(
      profiles: profiles ?? this.profiles,
      requests: requests ?? this.requests,
      transactions: transactions ?? this.transactions,
      activeProfile: activeProfile ?? this.activeProfile,
      isSplashVisible: isSplashVisible ?? this.isSplashVisible,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isUsingFallback: isUsingFallback ?? this.isUsingFallback,
      loginSicilInput: loginSicilInput ?? this.loginSicilInput,
      loginPasswordInput: loginPasswordInput ?? this.loginPasswordInput,
      isLoginPasswordObscured:
          isLoginPasswordObscured ?? this.isLoginPasswordObscured,
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
      managementTabIndex: managementTabIndex ?? this.managementTabIndex,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      officerSearchQuery: officerSearchQuery ?? this.officerSearchQuery,
      officerSegmentFilter: officerSegmentFilter ?? this.officerSegmentFilter,
      isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
      isLoading: isLoading ?? this.isLoading,
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      isErrorFeedback: isErrorFeedback ?? this.isErrorFeedback,
      transferModeTab: transferModeTab ?? this.transferModeTab,
      advanceAmountInput: advanceAmountInput ?? this.advanceAmountInput,
      advanceReasonInput: advanceReasonInput ?? this.advanceReasonInput,
      repaymentPlanIndex: repaymentPlanIndex ?? this.repaymentPlanIndex,
      selectedRecipientId: selectedRecipientId ?? this.selectedRecipientId,
      transferAmountInput: transferAmountInput ?? this.transferAmountInput,
      transferNoteInput: transferNoteInput ?? this.transferNoteInput,
      formPresetVersion: formPresetVersion ?? this.formPresetVersion,
      kepNotificationsEnabled:
          kepNotificationsEnabled ?? this.kepNotificationsEnabled,
      fastInstantConfirmEnabled:
          fastInstantConfirmEnabled ?? this.fastInstantConfirmEnabled,
      newOfficerName: newOfficerName ?? this.newOfficerName,
      newOfficerSicilNo: newOfficerSicilNo ?? this.newOfficerSicilNo,
      newOfficerPassword: newOfficerPassword ?? this.newOfficerPassword,
      newOfficerUnvan: newOfficerUnvan ?? this.newOfficerUnvan,
      newOfficerBalance: newOfficerBalance ?? this.newOfficerBalance,
    );
  }
}

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

  // Splash & Kimlik Doğrulama (Authentication) Metodları
  void completeSplash() {
    if (!state.isSplashVisible) return;
    String? splashEndFeedback;
    if (!state.isUsingFallback && !_hasAnnouncedLiveConnection) {
      _hasAnnouncedLiveConnection = true;
      splashEndFeedback = '✓ Supabase Canlı Veritabanı Bağlantısı Kuruldu! Tüm işlemler bulut üzerinde senkronize ediliyor.';
    }
    emit(
      state.copyWith(
        isSplashVisible: false,
        feedbackMessage: splashEndFeedback,
        clearFeedback: splashEndFeedback == null,
        isErrorFeedback: false,
      ),
    );
  }

  void setLoginSicilInput(String value) {
    emit(state.copyWith(loginSicilInput: value, clearFeedback: true));
  }

  void setLoginPasswordInput(String value) {
    emit(state.copyWith(loginPasswordInput: value, clearFeedback: true));
  }

  void toggleLoginPasswordVisibility() {
    emit(
      state.copyWith(
        isLoginPasswordObscured: !state.isLoginPasswordObscured,
        clearFeedback: true,
      ),
    );
  }

  /// Kurum Sicil No ve Giriş Şifresi (`password`) ile Supabase `profiles` tablosundaki gerçek memuru doğrular.
  void loginWithCredentials() {
    final sicilQuery = state.loginSicilInput.trim().toLowerCase();
    final passwordInput = state.loginPasswordInput.trim();

    if (sicilQuery.isEmpty || passwordInput.isEmpty) {
      emit(
        state.copyWith(
          feedbackMessage:
              'Lütfen Kurum Sicil No ve Giriş Şifrenizi eksiksiz giriniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    final matchingIndex = state.profiles.indexWhere(
      (p) =>
          p.kurumSicilNo.toLowerCase() == sicilQuery ||
          p.fullName.toLowerCase() == sicilQuery,
    );

    if (matchingIndex == -1) {
      emit(
        state.copyWith(
          feedbackMessage: 'Geçersiz Kurum Sicil No! Lütfen kayıtlı bir sicil numarası (MEB-1042, EGM-8831, MAL-0092, MUF-0001) giriniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    final targetProfile = state.profiles[matchingIndex];
    if (targetProfile.password != passwordInput) {
      emit(
        state.copyWith(
          feedbackMessage:
              'Hatalı Giriş Şifresi! Lütfen şifrenizi kontrol ediniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    loginAsProfile(targetProfile);
  }

  void loginAsProfile(ProfileModel profile) {
    final recipients = state.profiles.where((p) => p.id != profile.id).toList();
    emit(
      state.copyWith(
        isSplashVisible: false,
        isAuthenticated: true,
        activeProfile: profile,
        loginSicilInput: profile.kurumSicilNo,
        loginPasswordInput: '',
        bottomNavIndex: 0,
        selectedRecipientId: recipients.isNotEmpty ? recipients.first.id : '',
        feedbackMessage:
            'Kurumsal Oturum Açıldı: ${profile.fullName} (${profile.unvan})',
        isErrorFeedback: false,
      ),
    );
  }

  void logout() {
    emit(
      state.copyWith(
        isAuthenticated: false,
        bottomNavIndex: 0,
        loginSicilInput: '',
        loginPasswordInput: '',
        formPresetVersion: state.formPresetVersion + 1,
        feedbackMessage:
            '${state.activeProfile.fullName} oturumu güvenli şekilde kapatıldı.',
        isErrorFeedback: false,
      ),
    );
  }

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

  // Form Güncelleyiciler
  void setTransferModeTab(int tabIndex) {
    emit(state.copyWith(transferModeTab: tabIndex, clearFeedback: true));
  }

  void setAdvanceAmountInput(String value, {bool fromPreset = false}) {
    emit(
      state.copyWith(
        advanceAmountInput: value,
        formPresetVersion: fromPreset
            ? state.formPresetVersion + 1
            : state.formPresetVersion,
        clearFeedback: true,
      ),
    );
  }

  void setAdvanceReasonInput(String value, {bool fromPreset = false}) {
    emit(
      state.copyWith(
        advanceReasonInput: value,
        formPresetVersion: fromPreset
            ? state.formPresetVersion + 1
            : state.formPresetVersion,
        clearFeedback: true,
      ),
    );
  }

  void setRepaymentPlanIndex(int index) {
    emit(state.copyWith(repaymentPlanIndex: index, clearFeedback: true));
  }

  void setSelectedRecipientId(String id) {
    emit(state.copyWith(selectedRecipientId: id, clearFeedback: true));
  }

  void setTransferAmountInput(String value, {bool fromPreset = false}) {
    emit(
      state.copyWith(
        transferAmountInput: value,
        formPresetVersion: fromPreset
            ? state.formPresetVersion + 1
            : state.formPresetVersion,
        clearFeedback: true,
      ),
    );
  }

  void setTransferNoteInput(String value) {
    emit(state.copyWith(transferNoteInput: value, clearFeedback: true));
  }

  void setNewOfficerName(String value) {
    emit(state.copyWith(newOfficerName: value, clearFeedback: true));
  }

  void setNewOfficerSicilNo(String value) {
    emit(state.copyWith(newOfficerSicilNo: value, clearFeedback: true));
  }

  void setNewOfficerPassword(String value) {
    emit(state.copyWith(newOfficerPassword: value, clearFeedback: true));
  }

  void setNewOfficerUnvan(String value) {
    emit(state.copyWith(newOfficerUnvan: value, clearFeedback: true));
  }

  void setNewOfficerBalance(String value) {
    emit(state.copyWith(newOfficerBalance: value, clearFeedback: true));
  }

  /// Yöntem C: Geliştirici Hızlı Rol Değiştirme (user -> manager -> admin)
  void cycleTestRole() {
    final currentRole = state.activeProfile.role;
    final nextRole = currentRole == 'user'
        ? 'manager'
        : (currentRole == 'manager' ? 'admin' : 'user');
    switchRoleTo(nextRole);
  }

  void switchRoleTo(String targetRole) {
    final matching = state.profiles.firstWhere(
      (p) => p.role == targetRole,
      orElse: () => state.profiles.first,
    );
    switchProfileById(matching.id);
  }

  void switchProfileById(String profileId) {
    final target = state.profiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => state.activeProfile,
    );
    final recipients = state.profiles.where((p) => p.id != target.id).toList();
    final safeNavIndex = (!target.isAdminOrManager && state.bottomNavIndex > 2)
        ? 0
        : state.bottomNavIndex;

    emit(
      state.copyWith(
        isAuthenticated: true,
        activeProfile: target,
        selectedRecipientId: recipients.isNotEmpty ? recipients.first.id : '',
        bottomNavIndex: safeNavIndex,
        feedbackMessage:
            'Aktif Rol Değiştirildi: ${target.fullName} (${target.unvan} • ${target.role.toUpperCase()})',
        isErrorFeedback: false,
      ),
    );
  }

  /// Memurlar arası para transferi (Gönderici/Alıcı bloke kontrolü, FAST yetki kontrolü ve çift yönlü dekont)
  Future<void> submitMoneyTransfer() async {
    final sender = state.activeProfile;
    if (sender.isFrozen) {
      emit(
        state.copyWith(
          feedbackMessage: 'Hesabınız Başmüfettişlik tarafından dondurulmuştur! Para transferi yapılamaz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    if (!state.fastInstantConfirmEnabled) {
      emit(
        state.copyWith(
          feedbackMessage: 'FAST Kolay Adres transfer yetkiniz kapalıdır! Lütfen Profil sekmesinden FAST transfer yetkisini aktifleştiriniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    final amount =
        double.tryParse(
          state.transferAmountInput.replaceAll(',', '.').trim(),
        ) ??
        0.0;
    if (amount <= 0) {
      emit(
        state.copyWith(
          feedbackMessage: 'Lütfen geçerli bir transfer tutarı giriniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }
    if (amount > sender.balance) {
      emit(
        state.copyWith(
          feedbackMessage:
              'Yetersiz bakiye! Transfer tutarı mevcut bakiyenizi aşıyor.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    final recipient = state.profiles.firstWhere(
      (p) => p.id == state.selectedRecipientId,
      orElse: () => sender,
    );
    if (recipient.id == sender.id) {
      emit(
        state.copyWith(
          feedbackMessage: 'Lütfen geçerli bir alıcı memur seçiniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    if (recipient.isFrozen) {
      emit(
        state.copyWith(
          feedbackMessage:
              'Alıcı memur (${recipient.fullName}) hesabı MASAK / Teftiş Kurulu tarafından dondurulduğu için bu hesaba transfer yapılamaz!',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, clearFeedback: true));
    await _supabaseService.updateProfileBalance(
      sender.id,
      sender.balance - amount,
    );
    await _supabaseService.updateProfileBalance(
      recipient.id,
      recipient.balance + amount,
    );

    final now = DateTime.now();
    final refCode =
        'FAST-${now.millisecondsSinceEpoch.toString().substring(7)}';
    final note = state.transferNoteInput.trim().isEmpty
        ? 'Kamu Personeli FAST Transferi'
        : state.transferNoteInput.trim();

    final outgoingTx = TransactionRecord(
      id: 'tx-out-${now.millisecondsSinceEpoch}',
      userId: sender.id,
      title: 'FAST Gönderim: ${recipient.fullName}',
      subtitle: '${recipient.kurumSicilNo} • $note',
      category: 'FAST Transfer',
      referenceCode: refCode,
      amount: amount,
      isIncoming: false,
      createdAt: now,
    );

    final incomingTx = TransactionRecord(
      id: 'tx-in-${now.millisecondsSinceEpoch}',
      userId: recipient.id,
      title: 'FAST Gelen Transfer: ${sender.fullName}',
      subtitle: '${sender.kurumSicilNo} • $note',
      category: 'FAST Transfer',
      referenceCode: refCode,
      amount: amount,
      isIncoming: true,
      createdAt: now,
    );

    await loadInitialData(keepProfileId: sender.id);

    emit(
      state.copyWith(
        transactions: [outgoingTx, incomingTx, ...state.transactions],
        feedbackMessage:
            '${recipient.fullName} (${recipient.kurumSicilNo}) hesabına ${ProfileModel.formatCurrency(amount)} FAST transferi tamamlandı.',
        isErrorFeedback: false,
      ),
    );
  }

  /// Maaş Avansı / Memur Kredisi Başvurusu (Supabase `advance_requests.reason` sütununu temiz tutar)
  Future<void> submitAdvanceRequest() async {
    final current = state.activeProfile;
    if (current.isFrozen) {
      emit(
        state.copyWith(
          feedbackMessage: 'Hesabınız Teftiş Kurulu tarafından dondurulduğu için avans başvurusu engellendi!',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    final amount =
        double.tryParse(state.advanceAmountInput.replaceAll(',', '.').trim()) ??
        0.0;
    final cleanReason = state.advanceReasonInput.trim();
    final planLabel = state.repaymentPlanIndex == 0
        ? 'Ayın 15\'i Tek Sefer (%0 Faiz)'
        : '3 Eşit Taksitle Mahsup';

    if (amount <= 0 || cleanReason.isEmpty) {
      emit(
        state.copyWith(
          feedbackMessage:
              'Lütfen geçerli bir avans tutarı ve gerekçe giriniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, clearFeedback: true));
    await _supabaseService.createAdvanceRequest(
      userId: current.id,
      fullName: current.fullName,
      amount: amount,
      reason: cleanReason,
    );
    await loadInitialData(keepProfileId: current.id);

    emit(
      state.copyWith(
        feedbackMessage:
            '${ProfileModel.formatCurrency(amount)} tutarındaki Maaş Avansı ($planLabel) talebiniz Mutemetlik onayına iletildi.',
        isErrorFeedback: false,
      ),
    );
  }

  /// Manager / Admin: Bekleyen avans/kredi talebini Onayla (Bakiye artar) veya Reddet
  Future<void> processAdvanceRequest({
    required AdvanceRequestModel request,
    required bool approve,
  }) async {
    if (!state.activeProfile.isAdminOrManager) return;

    emit(state.copyWith(isLoading: true, clearFeedback: true));
    final newStatus = approve ? 'onaylandi' : 'reddedildi';
    await _supabaseService.updateAdvanceRequestStatus(
      requestId: request.id,
      status: newStatus,
    );

    List<TransactionRecord> updatedTx = state.transactions;
    if (approve) {
      final officerIndex = state.profiles.indexWhere(
        (p) => p.id == request.userId,
      );
      if (officerIndex != -1) {
        final officer = state.profiles[officerIndex];
        await _supabaseService.updateProfileBalance(
          officer.id,
          officer.balance + request.amount,
        );
      }
      final now = DateTime.now();
      updatedTx = [
        TransactionRecord(
          id: 'tx-${now.millisecondsSinceEpoch}',
          userId: request.userId,
          title: 'Onaylanan Maaş Avansı: ${request.fullName}',
          subtitle: request.reason,
          category: 'Maaş Avansı',
          referenceCode:
              'AVN-${now.millisecondsSinceEpoch.toString().substring(7)}',
          amount: request.amount,
          isIncoming: true,
          createdAt: now,
        ),
        ...state.transactions,
      ];
    }

    await loadInitialData(keepProfileId: state.activeProfile.id);
    emit(
      state.copyWith(
        transactions: updatedTx,
        feedbackMessage: approve
            ? '${request.fullName} talebi ONAYLANDI (+${ProfileModel.formatCurrency(request.amount)} bakiyesine eklendi).'
            : '${request.fullName} talebi REDDEDİLDİ.',
        isErrorFeedback: !approve,
      ),
    );
  }

  /// Manager / Admin: Ayın 15'i Toplu Maaş Dağıtımı Simülasyonu
  Future<void> distributeMonthlySalaries() async {
    if (!state.activeProfile.isAdminOrManager) return;

    emit(state.copyWith(isLoading: true, clearFeedback: true));
    int paidCount = 0;
    double totalDistributed = 0.0;
    for (final officer in state.profiles) {
      if (!officer.isFrozen) {
        final salaryAmount = officer.estimatedNetSalary;
        await _supabaseService.updateProfileBalance(
          officer.id,
          officer.balance + salaryAmount,
        );
        paidCount++;
        totalDistributed += salaryAmount;
      }
    }

    final now = DateTime.now();
    final batchTx = TransactionRecord(
      id: 'tx-${now.millisecondsSinceEpoch}',
      userId: state.activeProfile.id,
      title: 'Ayın 15\'i Toplu Kamu Maaş Dağıtımı ($paidCount Memur)',
      subtitle: 'Hazine ve Maliye Bakanlığı KEP Bordro Transferi',
      category: 'Toplu Maaş',
      referenceCode:
          'HZ-MAAS-${now.millisecondsSinceEpoch.toString().substring(7)}',
      amount: totalDistributed,
      isIncoming: true,
      createdAt: now,
    );

    await loadInitialData(keepProfileId: state.activeProfile.id);
    emit(
      state.copyWith(
        transactions: [batchTx, ...state.transactions],
        feedbackMessage:
            'Ayın 15\'i Toplu Maaş Dağıtımı tamamlandı! $paidCount aktif kamu personeline maaşları yatırıldı.',
        isErrorFeedback: false,
      ),
    );
  }

  /// Admin (Tanrı Modu): Seçili memura Promosyon Parası Gönder veya Maaş Yatır
  Future<void> sendFundsToOfficer({
    required ProfileModel officer,
    required double amount,
    required String label,
  }) async {
    if (!state.activeProfile.isAdmin) {
      emit(
        state.copyWith(
          feedbackMessage: 'Yetki Hatası: Tanrı Modu para aktarım işlemleri yalnızca Bakanlık Başmüfettişi (Admin) yetkisiyle yapılabilir.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, clearFeedback: true));
    await _supabaseService.updateProfileBalance(
      officer.id,
      officer.balance + amount,
    );

    final now = DateTime.now();
    final newTx = TransactionRecord(
      id: 'tx-${now.millisecondsSinceEpoch}',
      userId: officer.id,
      title: '$label: ${officer.fullName}',
      subtitle: '${officer.kurumSicilNo} • Başmüfettişlik Tanrı Modu Aktarımı',
      category: 'Kamu Teşvik',
      referenceCode:
          'GOD-${now.millisecondsSinceEpoch.toString().substring(7)}',
      amount: amount,
      isIncoming: true,
      createdAt: now,
    );

    await loadInitialData(keepProfileId: state.activeProfile.id);

    emit(
      state.copyWith(
        transactions: [newTx, ...state.transactions],
        feedbackMessage:
            '${officer.fullName} hesabına +${ProfileModel.formatCurrency(amount)} $label yatırıldı.',
        isErrorFeedback: false,
      ),
    );
  }

  /// Admin (Tanrı Modu): Memurun Rol/Unvanını değiştir (Müdür Yap / Memur Yap)
  Future<void> toggleOfficerManagerRole(ProfileModel officer) async {
    if (!state.activeProfile.isAdmin) {
      emit(
        state.copyWith(
          feedbackMessage: 'Yetki Hatası: Rol ve unvan atama yetkisi yalnızca Bakanlık Başmüfettişi (Admin) rolüne aittir.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    if (officer.id == state.activeProfile.id || officer.isAdmin) {
      emit(
        state.copyWith(
          feedbackMessage: 'Güvenlik Kuralı: Bakanlık Başmüfettişi (Admin) hesabının rolü düşürülemez!',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, clearFeedback: true));
    final makeManager = officer.role == 'user';
    final newRole = makeManager ? 'manager' : 'user';
    final newUnvan = makeManager
        ? 'Şube Müdürü / Mutemet'
        : 'Kamu Personeli (Memur)';

    await _supabaseService.updateProfileRoleAndTitle(
      profileId: officer.id,
      role: newRole,
      unvan: newUnvan,
    );
    await loadInitialData(keepProfileId: state.activeProfile.id);

    emit(
      state.copyWith(
        feedbackMessage:
            '${officer.fullName} yetkisi "$newUnvan (${newRole.toUpperCase()})" olarak güncellendi.',
        isErrorFeedback: false,
      ),
    );
  }

  /// Admin (Tanrı Modu): Şüpheli Hesabı Dondur / Bloke Kaldır
  Future<void> toggleOfficerFreeze(ProfileModel officer) async {
    if (!state.activeProfile.isAdmin) {
      emit(
        state.copyWith(
          feedbackMessage: 'Yetki Hatası: MASAK / Teftiş hesap dondurma yetkisi yalnızca Bakanlık Başmüfettişi (Admin) rolüne aittir.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    if (officer.id == state.activeProfile.id || officer.isAdmin) {
      emit(
        state.copyWith(
          feedbackMessage: 'Güvenlik Kuralı: Bakanlık Başmüfettişi kendi hesabını veya başka bir Başmüfettişi donduramaz!',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, clearFeedback: true));
    final nextFrozen = !officer.isFrozen;
    await _supabaseService.toggleFreezeStatus(officer.id, nextFrozen);
    await loadInitialData(keepProfileId: state.activeProfile.id);

    emit(
      state.copyWith(
        feedbackMessage: nextFrozen
            ? 'MASAK / Teftiş Tedbiri: ${officer.fullName} hesabı DONDURULDU!'
            : '${officer.fullName} üzerindeki hesap blokesi kaldırıldı.',
        isErrorFeedback: nextFrozen,
      ),
    );
  }

  /// Admin (Tanrı Modu): Sisteme Yeni Memur Ekle ve Formu Temizle (Doğrulama sonucu bool döner)
  Future<bool> addNewOfficer() async {
    if (!state.activeProfile.isAdmin) {
      emit(
        state.copyWith(
          feedbackMessage: 'Yetki Hatası: Yeni kamu personeli tanımlama yetkisi yalnızca Bakanlık Başmüfettişi (Admin) rolüne aittir.',
          isErrorFeedback: true,
        ),
      );
      return false;
    }

    final name = state.newOfficerName.trim();
    final sicil = state.newOfficerSicilNo.trim();
    final password = state.newOfficerPassword.trim();
    final unvan = state.newOfficerUnvan.trim();
    final balance =
        double.tryParse(state.newOfficerBalance.replaceAll(',', '.').trim()) ??
        0.0;

    if (name.isEmpty || sicil.isEmpty || password.isEmpty) {
      emit(
        state.copyWith(
          feedbackMessage: 'Yeni memur için Ad Soyad, Kurum Sicil No ve Giriş Şifresi zorunludur.',
          isErrorFeedback: true,
        ),
      );
      return false;
    }

    final duplicateExists = state.profiles.any(
      (p) => p.kurumSicilNo.toLowerCase() == sicil.toLowerCase(),
    );
    if (duplicateExists) {
      emit(
        state.copyWith(
          feedbackMessage:
              'Bu Kurum Sicil Numarası ($sicil) sistemde zaten kayıtlı! Lütfen benzersiz bir sicil numarası giriniz.',
          isErrorFeedback: true,
        ),
      );
      return false;
    }

    emit(state.copyWith(isLoading: true, clearFeedback: true));
    await _supabaseService.createOfficerProfile(
      fullName: name,
      kurumSicilNo: sicil,
      password: password,
      unvan: unvan.isEmpty ? 'Memur' : unvan,
      initialBalance: balance,
    );
    await loadInitialData(keepProfileId: state.activeProfile.id);

    emit(
      state.copyWith(
        newOfficerName: '',
        newOfficerSicilNo: '',
        newOfficerPassword: '',
        newOfficerUnvan: '',
        newOfficerBalance: '',
        formPresetVersion: state.formPresetVersion + 1,
        feedbackMessage:
            'Yeni kamu personeli "$name ($sicil)" sisteme başarıyla kaydedildi.',
        isErrorFeedback: false,
      ),
    );
    return true;
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
        transactions: BankState._buildDefaultTransactions(),
        feedbackMessage: remoteReset
            ? '✓ Supabase reset_memur_bank() RPC çalıştırıldı ve 4 memur + 2 avans demo verisi kuruldu!'
            : 'Demo veritabanı (4 memur + 2 bekleyen avans) yerel Fallback üzerinde sıfırlandı!',
        isErrorFeedback: false,
      ),
    );
  }
}
