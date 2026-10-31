import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/metric_card.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/status_dot.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  int _tab = 0;
  Set<String> _chips = {'all'};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(title: l10n.gallery_title),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          const SectionHeader(title: 'Cards'),
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TonalCard', style: AppTextStyles.titleM),
                const SizedBox(height: AppTokens.s8),
                Text(
                  'surfaceContainerLow · r18 · no shadow',
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          const SectionHeader(title: 'Split list'),
          SplitListGroup(
            children: [
              const SplitListTile(
                leading: Icon(TablerIcons.folder),
                title: 'Folder',
                subtitle: '12 items',
                trailing: Icon(TablerIcons.chevron_right),
              ),
              const SplitListTile(
                leading: Icon(TablerIcons.file_text),
                title: 'README.md',
                subtitle: '4.2 KB · 2026-10-30',
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: 'Delete',
                danger: true,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          const SectionHeader(title: 'Buttons'),
          const PrimaryButton(label: 'Primary', icon: TablerIcons.check),
          const SizedBox(height: AppTokens.s12),
          const SecondaryButton(label: 'Secondary', icon: TablerIcons.edit),
          const SizedBox(height: AppTokens.s12),
          const DangerButton(label: 'Danger', icon: TablerIcons.trash),
          const SizedBox(height: AppTokens.s24),
          const SectionHeader(title: 'Inputs'),
          const AppTextField(label: 'Name', hint: 'My server'),
          const SizedBox(height: AppTokens.s24),
          const SectionHeader(title: 'Chips'),
          AppFilterChips<String>(
            options: const ['all', 'running', 'stopped'],
            labelOf: (value) => value,
            selected: _chips,
            multiSelect: true,
            onChanged: (value) => setState(() => _chips = value),
          ),
          const SizedBox(height: AppTokens.s16),
          SegmentedTabs(
            labels: const ['One', 'Two', 'Three'],
            selectedIndex: _tab,
            scrollable: false,
            onChanged: (value) => setState(() => _tab = value),
          ),
          const SizedBox(height: AppTokens.s24),
          const SectionHeader(title: 'Status'),
          const Row(
            children: [
              StatusDot(status: 'running'),
              SizedBox(width: AppTokens.s12),
              StatusDot(status: 'stopped'),
              SizedBox(width: AppTokens.s12),
              StatusDot(status: 'error'),
              SizedBox(width: AppTokens.s12),
              StatusDot(status: 'pending'),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          const SectionHeader(title: 'Metrics'),
          const Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'CPU',
                  value: '42.5',
                  unit: '%',
                  caption: '8 cores',
                  status: 'running',
                ),
              ),
              SizedBox(width: AppTokens.s12),
              MetricRing(value: 68, label: 'Memory', size: 72),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          const SectionHeader(title: 'Skeleton'),
          const SkeletonShimmer(child: SkeletonCard(height: 96)),
          const SizedBox(height: AppTokens.s24),
          const SectionHeader(title: 'Empty'),
          EmptyState(
            icon: TablerIcons.inbox,
            title: 'Nothing here',
            message: 'Create an item to get started.',
            actionLabel: 'Create',
            onAction: () {},
          ),
        ],
      ),
    );
  }
}
