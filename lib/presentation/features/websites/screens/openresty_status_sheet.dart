import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/website/openresty_status_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/sheet_title.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/states/async_state_view.dart';

final _openRestyStatusProvider = FutureProvider.autoDispose<OpenRestyStatusDto>(
  (ref) => ref
      .watch(websiteRepositoryProvider.future)
      .then((repository) => repository.getOpenRestyStatus()),
  name: 'openRestyStatusSheetProvider',
);

Future<void> showOpenRestyStatusSheet(BuildContext context) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.88,
    builder: (sheetContext) => const _OpenRestyStatusSheet(),
  );
}

class _OpenRestyStatusSheet extends ConsumerWidget {
  const _OpenRestyStatusSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(_openRestyStatusProvider);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTitle(
            title: l10n.websites_openRestyStatus,
            onClose: () => Navigator.of(context).pop(),
            actions: [
              IconButton(
                tooltip: l10n.action_refresh,
                onPressed: () => ref.invalidate(_openRestyStatusProvider),
                icon: const Icon(TablerIcons.refresh),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Expanded(
            child: AsyncStateView(
              value: status,
              onRetry: () => ref.invalidate(_openRestyStatusProvider),
              builder: (data) => ListView(
                padding: EdgeInsets.fromLTRB(
                  context.pagePadding,
                  AppTokens.s8,
                  context.pagePadding,
                  AppTokens.s24 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  SplitListGroup(
                    children: [
                      SplitListTile(
                        title: l10n.websites_openRestyActive,
                        value: '${data.active}',
                      ),
                      SplitListTile(
                        title: l10n.websites_openRestyAcceptsHandled,
                        value: '${data.accepts} / ${data.handled}',
                      ),
                      SplitListTile(
                        title: l10n.websites_openRestyRequests,
                        value: '${data.requests}',
                      ),
                      SplitListTile(
                        title: l10n.websites_openRestyReading,
                        value: '${data.reading}',
                      ),
                      SplitListTile(
                        title: l10n.websites_openRestyWriting,
                        value: '${data.writing}',
                      ),
                      SplitListTile(
                        title: l10n.websites_openRestyWaiting,
                        value: '${data.waiting}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
