import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../constants/app_paddings.dart';
import '../stitch_ui/admin_dashboard_card.dart';
import '../stitch_ui/filter_bar_widget.dart';
import '../stitch_ui/profile_header_widget.dart';
import '../widgets/request_card_widget.dart';

/// Ana Sayfa: Zorunlu Modern Sliver Mimarisi
/// (`CustomScrollView` + `const SliverToBoxAdapter` + `const PinnedHeaderSliver` + `SliverList.builder`).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();
        final txList = state.activeUserTransactions;

        return RefreshIndicator(
          onRefresh: cubit.loadInitialData,
          child: CustomScrollView(
            slivers: [
              // 1. Üstteki Bakiye, Sicil No, Unvan ve Ayın 15'i Maaş Yatış Sayacı (const zorunlu!)
              const SliverToBoxAdapter(child: ProfileHeaderWidget()),

              // Yöntem B: Sadece Admin veya Manager ise görünen Teftiş Kurulu Kartıif (state.activeProfile.isAdminOrManager)
              const SliverToBoxAdapter(child: AdminDashboardCard()),

              // 2. Kaydırınca yukarıya yapışan (Sticky) başlık - const PinnedHeaderSliver!
              const PinnedHeaderSliver(child: FilterBarWidget()),

              // 3. Gerçek Lazy Loading SliverList.builder (Avans / Kredi Talepleri)!
              if (state.filteredRequests.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppPaddings.allXxl,
                    child: Center(
                      child: Text(
                        'Seçili filtreye uygun avans veya kredi talebi bulunamadı.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: state.filteredRequests.length,
                  itemBuilder: (context, index) =>
                      RequestCardWidget(request: state.filteredRequests[index]),
                ),

              // 4. Son Hesap Hareketleri & Dijital Dekontlar Başlığı ve SliverList.builder
              const SliverToBoxAdapter(child: _RecentTransactionsHeader()),

              SliverList.builder(
                itemCount: txList.length,
                itemBuilder: (context, index) =>
                    TransactionItemWidget(transaction: txList[index]),
              ),

              const SliverToBoxAdapter(child: AppPaddings.vGapXxxl),
            ],
          ),
        );
      },
    );
  }
}

class _RecentTransactionsHeader extends StatelessWidget {
  const _RecentTransactionsHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: AppPaddings.sectionMargin,
      child: Row(
        children: [
          Icon(
            Icons.history_rounded,
            size: AppPaddings.iconMd,
            color: colorScheme.primary,
          ),
          AppPaddings.hGapSm,
          Text(
            'Son Hesap Hareketleri & Dijital Dekontlar',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
