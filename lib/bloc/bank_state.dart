import '../models/advance_request_model.dart';
import '../models/profile_model.dart';
import '../models/transaction_record_model.dart';

export '../models/transaction_record_model.dart';

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
      transactions: buildDefaultTransactions(),
      activeProfile: defaultUser,
      isSplashVisible: showSplash,
      isAuthenticated: isAuthenticated,
      isUsingFallback: false,
    );
  }

  static List<TransactionRecord> buildDefaultTransactions() {
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
