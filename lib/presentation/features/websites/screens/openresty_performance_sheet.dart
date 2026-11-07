import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/website/openresty_performance_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/sheet_title.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/async_state_view.dart';
import '../../../common/states/error_toast.dart';

final _openRestyPerformanceProvider =
    FutureProvider.autoDispose<List<OpenRestyPerformanceItemDto>>(
      (ref) => ref
          .watch(websiteRepositoryProvider.future)
          .then((repository) => repository.getOpenRestyPerformance()),
      name: 'openRestyPerformanceSheetProvider',
    );

Future<void> showOpenRestyPerformanceSheet(BuildContext context) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.88,
    builder: (sheetContext) => const _OpenRestyPerformanceSheet(),
  );
}

String _stripUnit(String raw) => raw.replaceAll(RegExp(r'[a-zA-Z]'), '');

String _withUnit(String raw, String unit) =>
    raw.trim().isEmpty ? '' : '${_stripUnit(raw)}$unit';

String _valueOf(
  List<OpenRestyPerformanceItemDto> items,
  String name,
  String fallback,
) {
  for (final item in items) {
    if (item.name == name) {
      return item.params.isEmpty ? fallback : item.params.first;
    }
  }
  return fallback;
}

class _OpenRestyPerformanceSheet extends ConsumerStatefulWidget {
  const _OpenRestyPerformanceSheet();

  @override
  ConsumerState<_OpenRestyPerformanceSheet> createState() =>
      _OpenRestyPerformanceSheetState();
}

class _OpenRestyPerformanceSheetState
    extends ConsumerState<_OpenRestyPerformanceSheet> {
  final _serverNamesHash = TextEditingController();
  final _clientHeaderBuffer = TextEditingController();
  final _maxBody = TextEditingController();
  final _keepalive = TextEditingController();
  final _gzipMinLength = TextEditingController();
  final _gzipLevel = TextEditingController();
  bool _gzip = true;
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _serverNamesHash.dispose();
    _clientHeaderBuffer.dispose();
    _maxBody.dispose();
    _keepalive.dispose();
    _gzipMinLength.dispose();
    _gzipLevel.dispose();
    super.dispose();
  }

  void _apply(List<OpenRestyPerformanceItemDto> items) {
    if (_loaded) return;
    _loaded = true;
    _serverNamesHash.text = _stripUnit(
      _valueOf(items, 'server_names_hash_bucket_size', ''),
    );
    _clientHeaderBuffer.text = _stripUnit(
      _valueOf(items, 'client_header_buffer_size', ''),
    );
    _maxBody.text = _stripUnit(_valueOf(items, 'client_max_body_size', ''));
    _keepalive.text = _stripUnit(_valueOf(items, 'keepalive_timeout', ''));
    _gzipMinLength.text = _stripUnit(_valueOf(items, 'gzip_min_length', ''));
    _gzipLevel.text = _stripUnit(_valueOf(items, 'gzip_comp_level', ''));
    _gzip = _valueOf(items, 'gzip', 'on').toLowerCase() != 'off';
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateOpenRestyPerformance({
        'server_names_hash_bucket_size': _serverNamesHash.text.trim(),
        'client_header_buffer_size': _withUnit(_clientHeaderBuffer.text, 'k'),
        'client_max_body_size': _withUnit(_maxBody.text, 'm'),
        'keepalive_timeout': _keepalive.text.trim(),
        'gzip': _gzip ? 'on' : 'off',
        'gzip_min_length': _withUnit(_gzipMinLength.text, 'k'),
        'gzip_comp_level': _gzipLevel.text.trim(),
      });
      if (!mounted) return;
      AppToast.success(context, l10n.action_saved);
      ref.invalidate(_openRestyPerformanceProvider);
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
    final items = ref.watch(_openRestyPerformanceProvider);
    final data = items.valueOrNull;
    if (data != null) _apply(data);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetTitle(
            title: l10n.websites_openRestyPerformanceTitle,
            onClose: () => Navigator.of(context).pop(),
            actions: [
              IconButton(
                tooltip: l10n.action_refresh,
                onPressed: () {
                  _loaded = false;
                  ref.invalidate(_openRestyPerformanceProvider);
                },
                icon: const Icon(TablerIcons.refresh),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Expanded(
            child: AsyncStateView(
              value: items,
              onRetry: () => ref.invalidate(_openRestyPerformanceProvider),
              builder: (_) => ListView(
                padding: EdgeInsets.fromLTRB(
                  context.pagePadding,
                  AppTokens.s8,
                  context.pagePadding,
                  AppTokens.s24 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  TonalCard(
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _serverNamesHash,
                          label: l10n.websites_serverNamesHash,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppTokens.s12),
                        AppTextField(
                          controller: _clientHeaderBuffer,
                          label: l10n.websites_clientHeaderBuffer,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppTokens.s12),
                        AppTextField(
                          controller: _maxBody,
                          label: l10n.websites_maxBodySize,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppTokens.s12),
                        AppTextField(
                          controller: _keepalive,
                          label: l10n.websites_keepaliveTimeout,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTokens.s16),
                  TonalCard(
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.websites_gzip),
                          value: _gzip,
                          onChanged: (value) => setState(() => _gzip = value),
                        ),
                        AppTextField(
                          controller: _gzipMinLength,
                          label: l10n.websites_gzipMinLength,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppTokens.s12),
                        AppTextField(
                          controller: _gzipLevel,
                          label: l10n.websites_gzipCompLevel,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
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
