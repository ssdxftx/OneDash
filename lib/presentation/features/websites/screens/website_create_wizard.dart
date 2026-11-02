import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/cronjob/cronjob_form_data_dto.dart';
import '../../../../data/dto/website/website_create_req.dart';
import '../../../../data/dto/website/website_domain_req.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/bottom_sheet_surface.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../../../common/components/section_header.dart';
import '../../../common/components/segmented_tabs.dart';
import '../../../common/components/tonal_card.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../providers/websites_provider.dart';
import '../../../common/states/error_toast.dart';

class WebsiteCreateWizard extends ConsumerStatefulWidget {
  const WebsiteCreateWizard({super.key, required this.serverId});

  final int serverId;

  @override
  ConsumerState<WebsiteCreateWizard> createState() =>
      _WebsiteCreateWizardState();
}

class _WebsiteCreateWizardState extends ConsumerState<WebsiteCreateWizard> {
  final _domainController = TextEditingController();
  final _aliasController = TextEditingController();
  final _proxyController = TextEditingController();

  final List<String> _domains = [];
  String _type = 'static';
  bool _creating = false;

  @override
  void dispose() {
    _domainController.dispose();
    _aliasController.dispose();
    _proxyController.dispose();
    super.dispose();
  }

  void _addDomain() {
    final value = _domainController.text.trim();
    if (value.isEmpty || _domains.contains(value)) return;
    if (!RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value) &&
        !RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(value)) {
      AppToast.error(
        context,
        AppLocalizations.of(context).websites_invalidDomainFormat,
      );
      return;
    }
    setState(() {
      _domains.add(value);
      _domainController.clear();
    });
  }

  Future<void> _copyFromExisting() async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final options = await repository.getWebsiteOptions();
      if (!mounted) return;
      if (options.isEmpty) {
        AppToast.warning(context, l10n.state_empty);
        return;
      }
      final picked = await showAppSheet<WebsiteOptionDto>(
        context: context,
        maxHeightFactor: 0.85,
        builder: (sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.websites_copyFromExisting, style: AppTextStyles.titleL),
            const SizedBox(height: AppTokens.s16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    ListTile(
                      leading: const Icon(TablerIcons.world),
                      title: Text(option.primaryDomain),
                      subtitle: Text(option.alias),
                      onTap: () => Navigator.of(sheetContext).pop(option),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
      if (picked == null || !mounted) return;
      setState(() {
        _aliasController.text = picked.alias;
        if (picked.primaryDomain.isNotEmpty) {
          _domains
            ..clear()
            ..add(picked.primaryDomain);
        }
      });
    } catch (error) {
      if (!mounted) return;
      showErrorToast(context, error);
    }
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    if (_domains.isEmpty) {
      AppToast.error(context, l10n.websites_domainAtLeastOne);
      return;
    }
    if (_type == 'proxy' && _proxyController.text.trim().isEmpty) {
      AppToast.error(context, l10n.websites_proxyTargetRequired);
      return;
    }
    setState(() => _creating = true);
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.createWebsite(
        WebsiteCreateReq(
          alias: _aliasController.text.trim(),
          type: _type,
          domains: [
            for (final domain in _domains) WebsiteDomainReq(domain: domain),
          ],
          proxy: _type == 'proxy' ? _proxyController.text.trim() : '',
          siteDir: _domains.first,
        ),
      );
      if (!mounted) return;
      AppToast.success(context, l10n.action_done);
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _creating = false);
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    final metadata = ref.watch(websiteCreateMetadataProvider);

    final typeLabel = switch (_type) {
      'proxy' => l10n.websites_proxy,
      'php' => l10n.websites_php,
      _ => l10n.websites_static,
    };
    return Scaffold(
      appBar: AppBarLarge(
        title: l10n.websites_create,
        leading: IconButton(
          tooltip: l10n.action_close,
          onPressed: () => context.pop(),
          icon: const Icon(TablerIcons.x),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.s16),
        children: [
          SectionHeader(title: l10n.websites_domains),
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _domainController,
                        hint: 'example.com',
                        keyboardType: TextInputType.url,
                        onSubmitted: (_) => _addDomain(),
                      ),
                    ),
                    const SizedBox(width: AppTokens.s8),
                    IconButton.filledTonal(
                      onPressed: _addDomain,
                      icon: const Icon(TablerIcons.plus),
                    ),
                  ],
                ),
                if (_domains.isNotEmpty) ...[
                  const SizedBox(height: AppTokens.s12),
                  Wrap(
                    spacing: AppTokens.s8,
                    runSpacing: AppTokens.s8,
                    children: [
                      for (final domain in _domains)
                        InputChip(
                          label: Text(domain),
                          onDeleted: () =>
                              setState(() => _domains.remove(domain)),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: AppTokens.s12),
                AppTextField(
                  controller: _aliasController,
                  label: l10n.websites_alias,
                  hint: l10n.websites_optional,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _copyFromExisting,
                    child: Text(l10n.websites_copyFromExisting),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.websites_type),
          SegmentedTabs(
            labels: [
              l10n.websites_static,
              l10n.websites_proxy,
              l10n.websites_php,
            ],
            selectedIndex: switch (_type) {
              'proxy' => 1,
              'php' => 2,
              _ => 0,
            },
            scrollable: false,
            onChanged: (index) => setState(
              () => _type = switch (index) {
                1 => 'proxy',
                2 => 'php',
                _ => 'static',
              },
            ),
          ),
          if (_type == 'proxy') ...[
            const SizedBox(height: AppTokens.s16),
            AppTextField(
              controller: _proxyController,
              label: l10n.websites_targetAddress,
              hint: 'http://127.0.0.1:3000',
              keyboardType: TextInputType.url,
            ),
          ],
          const SizedBox(height: AppTokens.s24),
          SectionHeader(title: l10n.action_confirm),
          TonalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.websites_domains}: ${_domains.join(', ')}',
                  style: AppTextStyles.bodyM,
                ),
                const SizedBox(height: AppTokens.s8),
                Text(
                  '${l10n.websites_type}: $typeLabel',
                  style: AppTextStyles.bodyM,
                ),
                const SizedBox(height: AppTokens.s8),
                Text(
                  '${l10n.websites_siteDirectory}: ${metadata.valueOrNull?.sitesRootDir ?? '/'}/${_domains.isEmpty ? '' : _domains.first}',
                  style: AppTextStyles.bodyS.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s32),
          PrimaryButton(
            label: l10n.action_create,
            icon: TablerIcons.check,
            loading: _creating,
            onPressed: _creating ? null : _create,
          ),
          const SizedBox(height: AppTokens.s32),
        ],
      ),
    );
  }
}
