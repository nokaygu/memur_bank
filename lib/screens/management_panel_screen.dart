import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../constants/app_paddings.dart';
import '../stitch_ui/treasury_charts_widget.dart';
import '../theme/app_theme.dart';
import '../widgets/officer_card_widget.dart';
import '../widgets/request_card_widget.dart';

/// Sadece `manager` (Kurum Mutemedi / Şube Müdürü) ve `admin` (Bakanlık Başmüfettişi - Tanrı Modu)
/// için açılan 4. Sekme: 3 Sekmeli Teftiş / Yönetim Paneli.
/// Zorunlu `CustomScrollView` + `const SliverToBoxAdapter` + `const PinnedHeaderSliver` + `SliverList.builder` mimarisindedir.
class ManagementPanelScreen extends StatelessWidget {
  const ManagementPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();
        final tabIndex = state.managementTabIndex;
        final sortedRequests = state.sortedRequestsForManagement;

        return RefreshIndicator(
          onRefresh: cubit.loadInitialData,
          child: CustomScrollView(
            slivers: [
              // 1. Üst Başlık: Teftiş Kurulu / Mutemetlik Özeti + Ayın 15'i Toplu Maaş Dağıtım Butonu
              const SliverToBoxAdapter(child: _ManagementTopBanner()),

              // 2. Yapışkan 3 Sekmeli Bar (1. Onay Bekleyenler, 2. Memur Listesi, 3. Hazine İstatistikleri)
              const PinnedHeaderSliver(child: _ManagementSubTabsPinnedBar()),

              // 3. Sekme İçerikleri
              if (tabIndex == 0) ...[
                const SliverToBoxAdapter(child: _ApprovalQueueSummaryHeader()),
                if (sortedRequests.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: AppPaddings.allXxl,
                      child: Center(
                        child: Text(
                          'Henüz avans veya kredi başvurusu bulunmuyor.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: sortedRequests.length,
                    itemBuilder: (context, index) =>
                        RequestCardWidget(request: sortedRequests[index]),
                  ),
              ] else if (tabIndex == 1) ...[
                const SliverToBoxAdapter(child: _OfficerSearchAndCreateBar()),
                SliverList.builder(
                  itemCount: state.filteredOfficers.length,
                  itemBuilder: (context, index) =>
                      OfficerCardWidget(officer: state.filteredOfficers[index]),
                ),
              ] else ...[
                const SliverToBoxAdapter(child: TreasuryChartsWidget()),
                SliverList.builder(
                  itemCount: state.profiles.length,
                  itemBuilder: (context, index) =>
                      OfficerCardWidget(officer: state.profiles[index]),
                ),
              ],

              const SliverToBoxAdapter(child: AppPaddings.vGapXxxl),
            ],
          ),
        );
      },
    );
  }
}

class _ApprovalQueueSummaryHeader extends StatelessWidget {
  const _ApprovalQueueSummaryHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final pendingCount = state.pendingRequests.length;
        final decidedCount = state.requests.length - pendingCount;

        return Padding(
          padding: AppPaddings.sectionMargin,
          child: Container(
            padding: AppPaddings.cardPaddingCompact,
            decoration: BoxDecoration(
              color: ext.subtleCardBg,
              borderRadius: AppPaddings.radiusMd,
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.priority_high_rounded,
                  size: AppPaddings.iconSm,
                  color: ext.pendingAmber,
                ),
                AppPaddings.hGapXs,
                Expanded(
                  child: Text(
                    'Öncelikli Onay Sırası: $pendingCount Bekleyen Talep üstte • $decidedCount Karara Bağlanmış Talep altta listelenir.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ManagementTopBanner extends StatelessWidget {
  const _ManagementTopBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();
        final isAdmin = state.activeProfile.isAdmin;

        return Padding(
          padding: AppPaddings.pagePadding,
          child: Container(
            padding: AppPaddings.cardPadding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAdmin
                    ? [ext.adminCardBg, ext.headerGradientStart]
                    : [ext.headerGradientStart, ext.headerGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppPaddings.radiusLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      isAdmin
                          ? Icons.shield_outlined
                          : Icons.account_balance_wallet_outlined,
                      color: colorScheme.onPrimary,
                      size: AppPaddings.iconLg,
                    ),
                    AppPaddings.hGapSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAdmin
                                ? 'Bakanlık Başmüfettişi • Tanrı Modu (God Mode)'
                                : 'Kurum Mutemedi & Şube Müdürü Paneli',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Yetkili: ${state.activeProfile.fullName} (${state.activeProfile.kurumSicilNo})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppPaddings.vGapMd,
                FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : cubit.distributeMonthlySalaries,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    padding: AppPaddings.buttonPadding,
                  ),
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text(
                    'Ayın 15\'i Toplu Maaş Dağıtımını Tetikle (Simülasyon)',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ManagementSubTabsPinnedBar extends StatelessWidget {
  const _ManagementSubTabsPinnedBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();
        final tabIndex = state.managementTabIndex;

        return Container(
          color: colorScheme.surface,
          padding: AppPaddings.pinnedHeaderPadding,
          child: Row(
            children: [
              Expanded(
                child: _SubTabButton(
                  label: '1. Onaylar (${state.pendingRequests.length})',
                  icon: Icons.fact_check_outlined,
                  isSelected: tabIndex == 0,
                  onTap: () => cubit.setManagementTabIndex(0),
                ),
              ),
              AppPaddings.hGapXs,
              Expanded(
                child: _SubTabButton(
                  label: '2. Memurlar (${state.profiles.length})',
                  icon: Icons.manage_accounts_outlined,
                  isSelected: tabIndex == 1,
                  onTap: () => cubit.setManagementTabIndex(1),
                ),
              ),
              AppPaddings.hGapXs,
              Expanded(
                child: _SubTabButton(
                  label: '3. Hazine & MB',
                  icon: Icons.insights_outlined,
                  isSelected: tabIndex == 2,
                  onTap: () => cubit.setManagementTabIndex(2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SubTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppPaddings.radiusMd,
      child: Container(
        padding: AppPaddings.buttonPaddingCompact,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.primaryContainer,
          borderRadius: AppPaddings.radiusMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppPaddings.iconSm,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimaryContainer,
            ),
            AppPaddings.vGapXxs,
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficerSearchAndCreateBar extends StatelessWidget {
  const _OfficerSearchAndCreateBar();

  void _openAddOfficerSheet(BuildContext context) {
    final cubit = context.read<BankCubit>();
    cubit.clearFeedback();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: AppPaddings.bottomSheetRadius,
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _AddNewOfficerBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();
        final isAdmin = state.activeProfile.isAdmin;
        final frozenCount = state.profiles.where((p) => p.isFrozen).length;
        final managerCount = state.profiles
            .where((p) => p.isAdminOrManager)
            .length;

        return Padding(
          padding: AppPaddings.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Teftiş Kurulu Segment Filtre Çipleri (Stitch UI God Mode)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SegmentFilterChip(
                      label: 'Tüm Personel (${state.profiles.length})',
                      isSelected: state.officerSegmentFilter == 'all',
                      onTap: () => cubit.setOfficerSegmentFilter('all'),
                    ),
                    AppPaddings.hGapSm,
                    _SegmentFilterChip(
                      label: 'Şüpheli / Bloke ($frozenCount)',
                      isSelected: state.officerSegmentFilter == 'frozen',
                      onTap: () => cubit.setOfficerSegmentFilter('frozen'),
                    ),
                    AppPaddings.hGapSm,
                    _SegmentFilterChip(
                      label: 'Mutemet & Yöneticiler ($managerCount)',
                      isSelected: state.officerSegmentFilter == 'managers',
                      onTap: () => cubit.setOfficerSegmentFilter('managers'),
                    ),
                  ],
                ),
              ),
              AppPaddings.vGapSm,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: cubit.setOfficerSearchQuery,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Memur Adı, Sicil No veya Unvan Ara...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  if (isAdmin) ...[
                    AppPaddings.hGapSm,
                    FilledButton.icon(
                      onPressed: () => _openAddOfficerSheet(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                        padding: AppPaddings.buttonPadding,
                      ),
                      icon: const Icon(
                        Icons.person_add_alt_1,
                        size: AppPaddings.iconSm,
                      ),
                      label: const Text('Yeni Memur Ekle'),
                    ),
                  ],
                ],
              ),
              AppPaddings.vGapXs,
              Text(
                isAdmin
                    ? 'İpucu: Bir memura tıklayarak Tanrı Modu (Promosyon Gönder, Maaş Yatır, Müdür Yap, Hesabı Dondur) BottomSheet menüsünü açabilirsiniz.'
                    : 'Bilgi: Kurum Mutemedi (Manager) rolüyle memur sicil ve maaş özetlerini inceleyebilirsiniz. Tanrı Modu müdahale yetkileri Başmüfettiş (Admin) rolüne özeldir.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SegmentFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppPaddings.radiusFull,
      child: Container(
        padding: AppPaddings.chipPadding,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.primaryContainer,
          borderRadius: AppPaddings.radiusFull,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AddNewOfficerBottomSheet extends StatelessWidget {
  const _AddNewOfficerBottomSheet();

  Future<void> _submitNewOfficer(BuildContext context, BankCubit cubit) async {
    final success = await cubit.addNewOfficer();
    if (success && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();

        return SafeArea(
          child: Padding(
            padding: AppPaddings.bottomSheetPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Sisteme Yeni Kamu Personeli (Memur) Ekle',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                if (state.isErrorFeedback && state.feedbackMessage != null) ...[
                  AppPaddings.vGapXs,
                  Container(
                    padding: AppPaddings.cardPaddingCompact,
                    decoration: BoxDecoration(
                      color: ext.rejectedRed,
                      borderRadius: AppPaddings.radiusMd,
                    ),
                    child: Text(
                      state.feedbackMessage!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                AppPaddings.vGapMd,
                TextFormField(
                  key: ValueKey('new_officer_name_${state.formPresetVersion}'),
                  initialValue: state.newOfficerName,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.setNewOfficerName,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad (Zorunlu)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                AppPaddings.vGapSm,
                TextFormField(
                  key: ValueKey('new_officer_sicil_${state.formPresetVersion}'),
                  initialValue: state.newOfficerSicilNo,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.setNewOfficerSicilNo,
                  decoration: const InputDecoration(
                    labelText: 'Kurum Sicil No (Zorunlu • Örn: MEB-2090)',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                AppPaddings.vGapSm,
                TextFormField(
                  key: ValueKey(
                    'new_officer_password_${state.formPresetVersion}',
                  ),
                  initialValue: state.newOfficerPassword,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.setNewOfficerPassword,
                  decoration: const InputDecoration(
                    labelText: 'Giriş Şifresi (Zorunlu)',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                AppPaddings.vGapSm,
                TextFormField(
                  key: ValueKey('new_officer_unvan_${state.formPresetVersion}'),
                  initialValue: state.newOfficerUnvan,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.setNewOfficerUnvan,
                  decoration: const InputDecoration(
                    labelText: 'Unvan (Örn: Uzman Tabip / Mühendis)',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                ),
                AppPaddings.vGapSm,
                TextFormField(
                  key: ValueKey(
                    'new_officer_balance_${state.formPresetVersion}',
                  ),
                  initialValue: state.newOfficerBalance,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onChanged: cubit.setNewOfficerBalance,
                  onFieldSubmitted: (_) => _submitNewOfficer(context, cubit),
                  decoration: const InputDecoration(
                    labelText: 'Başlangıç Maaş Bakiyesi (₺)',
                    prefixIcon: Icon(Icons.currency_lira),
                  ),
                ),
                AppPaddings.vGapLg,
                FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => _submitNewOfficer(context, cubit),
                  style: FilledButton.styleFrom(
                    padding: AppPaddings.buttonPadding,
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Memuru Kaydet ve Hesabı Aç'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
