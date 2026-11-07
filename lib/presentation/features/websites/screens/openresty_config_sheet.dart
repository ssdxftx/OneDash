import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/website/website_config_file_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/sheet_title.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/error_toast.dart';

final _openRestyConfigProvider =
    FutureProvider.autoDispose<WebsiteConfigFileDto>(
      (ref) => ref
          .watch(websiteRepositoryProvider.future)
          .then((repository) => repository.getOpenRestyConfig()),
      name: 'openRestyConfigSheetProvider',
    );

Future<void> showOpenRestyConfigSheet(BuildContext context) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.96,
    builder: (sheetContext) => const _OpenRestyConfigSheet(),
  );
}

class _OpenRestyConfigSheet extends ConsumerStatefulWidget {
  const _OpenRestyConfigSheet();

  @override
  ConsumerState<_OpenRestyConfigSheet> createState() =>
      _OpenRestyConfigSheetState();
}

class _OpenRestyConfigSheetState extends ConsumerState<_OpenRestyConfigSheet> {
  final _controller = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply(String content) {
    if (_loaded) return;
    _loaded = true;
    _controller.text = content;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateOpenRestyConfig(_controller.text);
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = describeError(error, l10n));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(_openRestyConfigProvider);
    final data = config.valueOrNull;
    if (data != null) _apply(data.content);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTitle(
            title: l10n.websites_openRestyConfigFile,
            onClose: () => Navigator.of(context).pop(),
            actions: [
              IconButton(
                tooltip: l10n.action_refresh,
                onPressed: () {
                  _loaded = false;
                  ref.invalidate(_openRestyConfigProvider);
                },
                icon: const Icon(TablerIcons.refresh),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Expanded(
            child: AsyncStateView(
              value: config,
              onRetry: () => ref.invalidate(_openRestyConfigProvider),
              builder: (_) => ListView(
                padding: EdgeInsets.fromLTRB(
                  context.pagePadding,
                  AppTokens.s8,
                  context.pagePadding,
                  AppTokens.s24 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  AppTextField(
                    controller: _controller,
                    label: l10n.websites_openRestyConfigFile,
                    maxLines: 24,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppTokens.s12),
                    Text(
                      _error!,
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.appColors.danger,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTokens.s24),
                  PrimaryButton(
                    label: l10n.action_save,
                    loading: _saving,
                    onPressed: _saving ? null : _save,
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
