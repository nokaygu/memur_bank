import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../constants/app_paddings.dart';
import '../widgets/common/request_card_widget.dart';
import '../widgets/transfer/advance_application_card.dart';
import '../widgets/transfer/peer_transfer_card.dart';
import '../widgets/transfer/transfer_header_widgets.dart';

/// Memurlar Arası Para Transferi ve "Maaş Avansı / Memur Kredisi" Başvuru Ekranı (`TransferScreen`).
/// Zorunlu `CustomScrollView` + `const SliverToBoxAdapter` + `const PinnedHeaderSliver` + `SliverList.builder` mimarisiyle kurulmuştur.
class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();

        return RefreshIndicator(
          onRefresh: cubit.loadInitialData,
          child: CustomScrollView(
            slivers: [
              // 1. Üst Başlık ve Bakiye Özet Kartı
              const SliverToBoxAdapter(child: TransferHeroBanner()),

              // 2. Yapışkan Sekme Seçici (Maaş Avansı Başvurusu vs Para Transferi)
              const PinnedHeaderSliver(child: TransferModePinnedHeader()),

              // 3. Aktif Forma Göre İçerik Kartı
              const SliverToBoxAdapter(child: _TransferOrAdvanceFormSection()),

              // 4. Alt Liste: Son Başvurular (SliverList.builder ile)
              SliverList.builder(
                itemCount: state.filteredRequests.length,
                itemBuilder: (context, index) =>
                    RequestCardWidget(request: state.filteredRequests[index]),
              ),

              const SliverToBoxAdapter(child: AppPaddings.vGapXxxl),
            ],
          ),
        );
      },
    );
  }
}

class _TransferOrAdvanceFormSection extends StatelessWidget {
  const _TransferOrAdvanceFormSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        if (state.transferModeTab == 0) {
          return const AdvanceApplicationCard();
        }
        return const PeerTransferCard();
      },
    );
  }
}
