import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/file/file_ai_search_dto.dart';
import '../../../../data/repositories_impl/file_repository_impl.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/split_list_group.dart';
import '../../../common/components/tonal_card.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class FileAiSearchPage extends ConsumerStatefulWidget {
  const FileAiSearchPage({
    super.key,
    required this.serverId,
    required this.initialPath,
  });

  final int serverId;
  final String initialPath;

  @override
  ConsumerState<FileAiSearchPage> createState() => _FileAiSearchPageState();
}

class _FileAiSearchPageState extends ConsumerState<FileAiSearchPage> {
  final _query = TextEditingController();
  FileAiSearchResultDto? _result;
  bool _searching = false;
  bool _containSub = true;
  bool _matchCase = false;
  bool _wholeWord = false;
  bool _useRegex = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _query.text.trim();
    if (query.isEmpty) return;
    setState(() => _searching = true);
    try {
      final repository = await ref.read(fileRepositoryProvider.future);
      final result = await repository.aiSearch(
        path: widget.initialPath,
        query: query,
        containSub: _containSub,
        matchCase: _matchCase,
        wholeWord: _wholeWord,
        useRegex: _useRegex,
      );
      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.files_aiSearch)),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.pagePadding),
        children: [
          Text(
            widget.initialPath,
            style: AppTextStyles.bodyS.copyWith(
              color: context.scheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: AppTokens.s12),
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _query,
                  label: l10n.files_aiQuery,
                  hint: l10n.files_aiQueryHint,
                  autofocus: true,
                  onSubmitted: (_) => _search(),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.files_aiContainSub),
                  value: _containSub,
                  onChanged: (value) => setState(() => _containSub = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.files_aiMatchCase),
                  value: _matchCase,
                  onChanged: (value) => setState(() => _matchCase = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.files_aiWholeWord),
                  value: _wholeWord,
                  onChanged: (value) => setState(() => _wholeWord = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.files_aiUseRegex),
                  value: _useRegex,
                  onChanged: (value) => setState(() => _useRegex = value),
                ),
                const SizedBox(height: AppTokens.s8),
                PrimaryButton(
                  label: l10n.action_search,
                  icon: TablerIcons.search,
                  loading: _searching,
                  onPressed: _search,
                ),
              ],
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: AppTokens.s24),
            if (!result.isAi) ...[
              Text(
                l10n.files_aiGrepMode,
                style: AppTextStyles.bodyS.copyWith(
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTokens.s12),
            ],
            if (result.summary.isNotEmpty) ...[
              SectionHeader(title: l10n.files_aiSummary),
              TonalCard(
                child: SelectableText(
                  result.summary,
                  style: AppTextStyles.bodyM,
                ),
              ),
              const SizedBox(height: AppTokens.s16),
            ],
            TonalCard(
              child: Wrap(
                spacing: AppTokens.s16,
                runSpacing: AppTokens.s8,
                children: [
                  _meta(
                    '${l10n.files_aiScanned}: '
                    '${result.contentScannedFiles}',
                  ),
                  _meta('${l10n.files_aiHits}: ${result.hits.length}'),
                  if (result.totalTokens > 0)
                    _meta('${l10n.files_aiTokens}: ${result.totalTokens}'),
                  if (result.duration.isNotEmpty)
                    _meta('${l10n.files_aiDuration}: ${result.duration}'),
                ],
              ),
            ),
            if (result.truncated || result.contentHitsTruncated) ...[
              const SizedBox(height: AppTokens.s8),
              Text(
                l10n.files_aiTruncated,
                style: AppTextStyles.bodyS.copyWith(
                  color: context.scheme.error,
                ),
              ),
            ],
            const SizedBox(height: AppTokens.s16),
            SectionHeader(title: l10n.files_aiHits),
            if (result.hits.isEmpty)
              EmptyState(
                icon: TablerIcons.search_off,
                title: l10n.files_aiHitsEmptyTitle,
                message: l10n.files_aiEmpty,
                compact: true,
              )
            else
              SplitListGroup(
                children: [
                  for (final hit in result.hits)
                    SplitListTile(
                      leading: const Icon(TablerIcons.file_text),
                      title: hit.path,
                      subtitle: hit.line > 0
                          ? '${l10n.files_aiLine} ${hit.line}: ${hit.text}'
                          : hit.text,
                      trailing: const Icon(TablerIcons.chevron_right),
                      onTap: () => context.push(
                        '/s/${widget.serverId}/files/edit'
                        '?path=${Uri.encodeComponent(hit.path)}',
                      ),
                    ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _meta(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyS.copyWith(
        color: context.scheme.onSurfaceVariant,
      ),
    );
  }
}
