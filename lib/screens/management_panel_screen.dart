import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../constants/app_paddings.dart';
import '../widgets/common/request_card_widget.dart';
import '../widgets/management/management_header_widgets.dart';
import '../widgets/management/officer_card_widget.dart';
import '../widgets/management/treasury_charts_widget.dart';

/// Sadece `manager` (Kurum Mutemedi / Şube Müdürü) ve `admin` (Bakanlık Başmüfettişi - Tanrı Modu)
/// için açılan 4. Sekme: 3 Sekmeli Teftiş / Yönetim Paneli (`ManagementPanelScreen`).
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
              const SliverToBoxAdapter(child: ManagementTopBanner()),

              // 2. Yapışkan 3 Sekmeli Bar (1. Onay Bekleyenler, 2. Memur Listesi, 3. Hazine İstatistikleri)
              const PinnedHeaderSliver(child: ManagementSubTabsPinnedBar()),

              // 3. Sekme İçerikleri
              if (tabIndex == 0) ...[
                const SliverToBoxAdapter(child: ApprovalQueueSummaryHeader()),
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
                const SliverToBoxAdapter(child: OfficerSearchAndCreateBar()),
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
