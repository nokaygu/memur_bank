import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';

/// `PinnedHeaderSliver` içinde kullanılan yapışkan (Sticky) filtre ve başlık çubuğu.
class FilterBarWidget extends StatelessWidget {
  const FilterBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();
        final isInspector = state.activeProfile.isAdminOrManager;
        final scoped = state.roleScopedRequests;
        final pendingCount = scoped.where((r) => r.isPending).length;
        final approvedCount = scoped.where((r) => r.isApproved).length;
        final rejectedCount = scoped.where((r) => r.isRejected).length;

        return Container(
          color: colorScheme.surface,
          padding: AppPaddings.pinnedHeaderPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: AppPaddings.iconMd,
                          color: colorScheme.primary,
                        ),
                        AppPaddings.hGapSm,
                        Expanded(
                          child: Text(
                            isInspector
                                ? 'Tüm Kamu Avans & Kredi Talepleri'
                                : 'Avans & Kredi Başvuru Geçmişim',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppPaddings.hGapSm,
                  Container(
                    padding: AppPaddings.badgePadding,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: AppPaddings.radiusFull,
                    ),
                    child: Text(
                      '${state.filteredRequests.length} Kayıt',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              AppPaddings.vGapSm,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChipButton(
                      label: 'Tümü (${scoped.length})',
                      isSelected: state.selectedFilter == 'all',
                      onTap: () => cubit.setSelectedFilter('all'),
                    ),
                    AppPaddings.hGapSm,
                    _FilterChipButton(
                      label: 'Bekleyenler ($pendingCount)',
                      isSelected: state.selectedFilter == 'bekliyor',
                      onTap: () => cubit.setSelectedFilter('bekliyor'),
                    ),
                    AppPaddings.hGapSm,
                    _FilterChipButton(
                      label: 'Onaylananlar ($approvedCount)',
                      isSelected: state.selectedFilter == 'onaylandi',
                      onTap: () => cubit.setSelectedFilter('onaylandi'),
                    ),
                    AppPaddings.hGapSm,
                    _FilterChipButton(
                      label: 'Reddedilenler ($rejectedCount)',
                      isSelected: state.selectedFilter == 'reddedildi',
                      onTap: () => cubit.setSelectedFilter('reddedildi'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipButton({
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
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
