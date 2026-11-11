part of 'bank_cubit.dart';

/// Maaş Avansı / Memur Kredisi Başvurusu ve Memurlar Arası Anlık FAST Para Transferi Aksiyonları.
extension BankTransferActions on BankCubit {
  static const double maxPublicAdvanceLimit = 100000.0;

  void setTransferModeTab(int tabIndex) {
    _emitState(state.copyWith(transferModeTab: tabIndex, clearFeedback: true));
  }

  void setAdvanceAmountInput(String value, {bool fromPreset = false}) {
    _emitState(
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
    _emitState(
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
    _emitState(state.copyWith(repaymentPlanIndex: index, clearFeedback: true));
  }

  void setSelectedRecipientId(String id) {
    _emitState(state.copyWith(selectedRecipientId: id, clearFeedback: true));
  }

  void setTransferAmountInput(String value, {bool fromPreset = false}) {
    _emitState(
      state.copyWith(
        transferAmountInput: value,
        formPresetVersion: fromPreset
            ? state.formPresetVersion + 1
            : state.formPresetVersion,
        clearFeedback: true,
      ),
    );
  }

  void setTransferNoteInput(String value, {bool fromPreset = false}) {
    _emitState(
      state.copyWith(
        transferNoteInput: value,
        formPresetVersion: fromPreset
            ? state.formPresetVersion + 1
            : state.formPresetVersion,
        clearFeedback: true,
      ),
    );
  }

  /// Memurlar arası para transferi (Gönderici/Alıcı bloke kontrolü, FAST yetki kontrolü, çift yönlü dekont ve form sıfırlama)
  Future<void> submitMoneyTransfer() async {
    final sender = state.activeProfile;
    if (sender.isFrozen) {
      _emitState(
        state.copyWith(
          feedbackMessage: 'Hesabınız Başmüfettişlik tarafından dondurulmuştur! Para transferi yapılamaz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    if (!state.fastInstantConfirmEnabled) {
      _emitState(
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
      _emitState(
        state.copyWith(
          feedbackMessage: 'Lütfen geçerli bir transfer tutarı giriniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }
    if (amount > sender.balance) {
      _emitState(
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
      _emitState(
        state.copyWith(
          feedbackMessage: 'Lütfen geçerli bir alıcı memur seçiniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    if (recipient.isFrozen) {
      _emitState(
        state.copyWith(
          feedbackMessage:
              'Alıcı memur (${recipient.fullName}) hesabı MASAK / Teftiş Kurulu tarafından dondurulduğu için bu hesaba transfer yapılamaz!',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    _emitState(state.copyWith(isLoading: true, clearFeedback: true));
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

    _emitState(
      state.copyWith(
        transferAmountInput: '2500',
        transferNoteInput: '',
        formPresetVersion: state.formPresetVersion + 1,
        transactions: [outgoingTx, incomingTx, ...state.transactions],
        feedbackMessage:
            '${recipient.fullName} (${recipient.kurumSicilNo}) hesabına ${ProfileModel.formatCurrency(amount)} FAST transferi tamamlandı.',
        isErrorFeedback: false,
      ),
    );
  }

  /// Maaş Avansı / Memur Kredisi Başvurusu (Üst limit kontrolü, Supabase kaydı ve otomatik form/gerekçe sıfırlama)
  Future<void> submitAdvanceRequest() async {
    final current = state.activeProfile;
    if (current.isFrozen) {
      _emitState(
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
      _emitState(
        state.copyWith(
          feedbackMessage:
              'Lütfen geçerli bir avans tutarı ve gerekçe giriniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    if (amount > maxPublicAdvanceLimit) {
      _emitState(
        state.copyWith(
          feedbackMessage:
              'Kamu Maaş Avansı / Memur Kredisi tek seferlik üst limiti ${ProfileModel.formatCurrency(maxPublicAdvanceLimit)} tutarındadır. Lütfen limit dahilinde bir tutar giriniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    _emitState(state.copyWith(isLoading: true, clearFeedback: true));
    await _supabaseService.createAdvanceRequest(
      userId: current.id,
      fullName: current.fullName,
      amount: amount,
      reason: cleanReason,
    );
    await loadInitialData(keepProfileId: current.id);

    _emitState(
      state.copyWith(
        advanceAmountInput: '15000',
        advanceReasonInput: '',
        repaymentPlanIndex: 0,
        formPresetVersion: state.formPresetVersion + 1,
        feedbackMessage:
            '${ProfileModel.formatCurrency(amount)} tutarındaki Maaş Avansı ($planLabel) talebiniz Mutemetlik onayına iletildi.',
        isErrorFeedback: false,
      ),
    );
  }
}
