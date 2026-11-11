part of 'bank_cubit.dart';

/// Kurumsal Açılış (Splash), Kimlik Doğrulama (Login / Logout) ve
/// Geliştirici Hızlı Rol / Profil Değiştirme (Yöntem C) Aksiyonları.
extension BankAuthActions on BankCubit {
  void completeSplash() {
    if (!state.isSplashVisible) return;
    String? splashEndFeedback;
    if (!state.isUsingFallback && !_hasAnnouncedLiveConnection) {
      _hasAnnouncedLiveConnection = true;
      splashEndFeedback = '✓ Supabase Canlı Veritabanı Bağlantısı Kuruldu! Tüm işlemler bulut üzerinde senkronize ediliyor.';
    }
    _emitState(
      state.copyWith(
        isSplashVisible: false,
        feedbackMessage: splashEndFeedback,
        clearFeedback: splashEndFeedback == null,
        isErrorFeedback: false,
      ),
    );
  }

  void setLoginSicilInput(String value) {
    _emitState(state.copyWith(loginSicilInput: value, clearFeedback: true));
  }

  void setLoginPasswordInput(String value) {
    _emitState(state.copyWith(loginPasswordInput: value, clearFeedback: true));
  }

  void toggleLoginPasswordVisibility() {
    _emitState(
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
      _emitState(
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
      _emitState(
        state.copyWith(
          feedbackMessage: 'Geçersiz Kurum Sicil No! Lütfen kayıtlı bir sicil numarası (MEB-1042, EGM-8831, MAL-0092, MUF-0001) giriniz.',
          isErrorFeedback: true,
        ),
      );
      return;
    }

    final targetProfile = state.profiles[matchingIndex];
    if (targetProfile.password != passwordInput) {
      _emitState(
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
    _emitState(
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
    _emitState(
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

  /// Yöntem C: Geliştirici Hızlı Rol Değiştirme (`user` -> `manager` -> `admin`)
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

    _emitState(
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
}
