part of 'bank_cubit.dart';

/// Kurum Mutemedi (`manager`) ve Bakanlık Başmüfettişi (`admin` - Tanrı Modu)
/// Yönetim / Teftiş Paneli Aksiyonları.
extension BankAdminActions on BankCubit {
  void setNewOfficerName(String value) {
    _emitState(state.copyWith(newOfficerName: value, clearFeedback: true));
  }

  void setNewOfficerSicilNo(String value) {
    _emitState(state.copyWith(newOfficerSicilNo: value, clearFeedback: true));
  }

  void setNewOfficerPassword(String value) {
    _emitState(state.copyWith(newOfficerPassword: value, clearFeedback: true));
  }

  void setNewOfficerUnvan(String value) {
    _emitState(state.copyWith(newOfficerUnvan: value, clearFeedback: true));
  }

  void setNewOfficerBalance(String value) {
    _emitState(state.copyWith(newOfficerBalance: value, clearFeedback: true));
  }

  /// Manager / Admin: Bekleyen avans/kredi talebini Onayla (Bakiye artar) veya Reddet
  Future<void> processAdvanceRequest({
    required AdvanceRequestModel request,
    required bool approve,
  }) async {
    if (!state.activeProfile.isAdminOrManager) return;

    _emitState(state.copyWith(isLoading: true, clearFeedback: true));
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
    _emitState(
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

    _emitState(state.copyWith(isLoading: true, clearFeedback: true));
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
    _emitState(
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
      _emitState(
        state.copyWith(
          feedbackMessage: 'Yetki Hatası: Tanrı Modu para aktarım işlemleri yalnızca Bakanlık Başmüfettişi (Admin) yetkisiyle yapılabilir.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    _emitState(state.copyWith(isLoading: true, clearFeedback: true));
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

    _emitState(
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
      _emitState(
        state.copyWith(
          feedbackMessage: 'Yetki Hatası: Rol ve unvan atama yetkisi yalnızca Bakanlık Başmüfettişi (Admin) rolüne aittir.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    if (officer.id == state.activeProfile.id || officer.isAdmin) {
      _emitState(
        state.copyWith(
          feedbackMessage: 'Güvenlik Kuralı: Bakanlık Başmüfettişi (Admin) hesabının rolü düşürülemez!',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    _emitState(state.copyWith(isLoading: true, clearFeedback: true));
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

    _emitState(
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
      _emitState(
        state.copyWith(
          feedbackMessage: 'Yetki Hatası: MASAK / Teftiş hesap dondurma yetkisi yalnızca Bakanlık Başmüfettişi (Admin) rolüne aittir.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    if (officer.id == state.activeProfile.id || officer.isAdmin) {
      _emitState(
        state.copyWith(
          feedbackMessage: 'Güvenlik Kuralı: Bakanlık Başmüfettişi kendi hesabını veya başka bir Başmüfettişi donduramaz!',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    _emitState(state.copyWith(isLoading: true, clearFeedback: true));
    final nextFrozen = !officer.isFrozen;
    await _supabaseService.toggleFreezeStatus(officer.id, nextFrozen);
    await loadInitialData(keepProfileId: state.activeProfile.id);

    _emitState(
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
      _emitState(
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
      _emitState(
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
      _emitState(
        state.copyWith(
          feedbackMessage:
              'Bu Kurum Sicil Numarası ($sicil) sistemde zaten kayıtlı! Lütfen benzersiz bir sicil numarası giriniz.',
          isErrorFeedback: true,
        ),
      );
      return false;
    }

    _emitState(state.copyWith(isLoading: true, clearFeedback: true));
    await _supabaseService.createOfficerProfile(
      fullName: name,
      kurumSicilNo: sicil,
      password: password,
      unvan: unvan.isEmpty ? 'Memur' : unvan,
      initialBalance: balance,
    );
    await loadInitialData(keepProfileId: state.activeProfile.id);

    _emitState(
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
}
