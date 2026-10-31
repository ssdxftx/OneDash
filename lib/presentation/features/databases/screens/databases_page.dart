import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/database/database_instance_dto.dart';
import '../../../../data/repositories_impl/database_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/filter_chips.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class _DatabasesState {
  const _DatabasesState({required this.items, required this.types});

  final List<DatabaseSearchItemDto> items;
  final List<String> types;
}

final _databasesProvider = FutureProvider.autoDispose<_DatabasesState>((
  ref,
) async {
  final repository = await ref.watch(databaseRepositoryProvider.future);
  List<DatabaseInstanceDto> instances = const [];
  try {
    instances = await repository.listInstances(
      'mysql,postgresql,redis,mongodb',
    );
  } catch (_) {
    // 忽略：下方按默认类型兜底查询。
  }
  final types = instances.isEmpty
      ? ['mysql', 'postgresql', 'redis', 'mongodb']
      : instances.map((e) => e.type).toSet().toList();
  final results = await Future.wait<List<DatabaseSearchItemDto>>(
    types.map((type) async {
      try {
        final page = await repository.searchDatabases(
          database: type,
          page: 1,
          pageSize: 100,
        );
        return page.items;
      } catch (_) {
        return <DatabaseSearchItemDto>[];
      }
    }),
  );
  return _DatabasesState(
    items: results.expand((e) => e).toList(),
    types: types,
  );
}, name: 'databasesProvider');

class DatabasesPage extends ConsumerStatefulWidget {
  const DatabasesPage({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<DatabasesPage> createState() => _DatabasesPageState();
}

class _DatabasesPageState extends ConsumerState<DatabasesPage> {
  String _type = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final databases = ref.watch(_databasesProvider);
    final state = databases.valueOrNull;
    final types = ['', ...?state?.types];
    final filtered = state == null
        ? const <DatabaseSearchItemDto>[]
        : _type.isEmpty
        ? state.items
        : state.items
              .where((e) => e.instanceName == _type || e.from == _type)
              .toList();

    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.databases_title,
        actions: [
          AppIconButton(
            icon: TablerIcons.refresh,
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(_databasesProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          AppFilterChips<String>(
            options: types,
            labelOf: (value) => value.isEmpty ? l10n.websites_all : value,
            selected: {_type},
            onChanged: (selection) {
              if (selection.isEmpty) return;
              setState(() => _type = selection.first);
            },
          ),
          Expanded(
            child: AsyncStateView(
              value: databases,
              onRetry: () => ref.invalidate(_databasesProvider),
              loading: const SkeletonList(itemCount: 8),
              isEmpty: (_) => filtered.isEmpty,
              empty: EmptyState(
                icon: TablerIcons.database,
                title: l10n.databases_empty_title,
                message: l10n.databases_empty_message,
              ),
              builder: (_) => ListView.builder(
                padding: const EdgeInsets.all(AppTokens.s16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.s12),
                    child: _DatabaseCard(
                      item: item,
                      onTap: () => context.push(
                        '/s/${widget.serverId}/more/databases/${Uri.encodeComponent(item.name)}?type=${Uri.encodeComponent(item.from)}',
                      ),
                      onLongPress: () => _showActions(item),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showActions(DatabaseSearchItemDto item) async {
    final l10n = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: AppTextStyles.titleL),
          const SizedBox(height: AppTokens.s4),
          Text(
            '${item.instanceName} · ${item.username}',
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
          SplitListGroup(
            children: [
              SplitListTile(
                leading: const Icon(TablerIcons.copy),
                title: l10n.action_copy,
                subtitle: item.name,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await Clipboard.setData(ClipboardData(text: item.name));
                  if (!context.mounted) return;
                  // ignore: use_build_context_synchronously
                  AppToast.success(context, l10n.action_copy);
                },
              ),
              SplitListTile(
                leading: const Icon(TablerIcons.trash),
                title: l10n.action_delete,
                danger: true,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await showConfirmSheet(
                    context,
                    title: l10n.action_delete,
                    message: item.name,
                    confirmLabel: l10n.action_delete,
                    requireText: item.name,
                  );
                  if (!confirmed) return;
                  try {
                    final repository = await ref.read(
                      databaseRepositoryProvider.future,
                    );
                    await repository.deleteDatabase(
                      id: item.id,
                      type: item.from,
                      database: item.name,
                      forceDelete: false,
                      deleteBackup: false,
                    );
                    if (!context.mounted) return;
                    // ignore: use_build_context_synchronously
                    AppToast.success(context, l10n.action_done);
                    ref.invalidate(_databasesProvider);
                  } catch (error) {
                    if (!context.mounted) return;
                    // ignore: use_build_context_synchronously
                    showErrorToast(context, error);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
        ],
      ),
    );
  }
}

class _DatabaseCard extends StatelessWidget {
  const _DatabaseCard({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final DatabaseSearchItemDto item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return TonalCard(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.s8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTokens.rXs),
                ),
                child: Text(
                  item.from,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.s8),
              Expanded(
                child: Text(
                  item.name,
                  style: AppTextStyles.titleM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Text(
            '${item.username} · ${item.format}',
            style: AppTextStyles.bodyS.copyWith(color: scheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
