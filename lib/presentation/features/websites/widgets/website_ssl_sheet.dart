import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/dto/website/website_acme_account_dto.dart';
import '../../../../data/dto/website/website_https_dto.dart';
import '../../../../data/dto/website/website_ssl_dto.dart';
import '../../../../data/repositories_impl/website_repository_impl.dart';
import '../../../common/components/app_toast.dart';
import '../../../common/components/buttons.dart';
import '../providers/websites_provider.dart';
import '../../../common/states/error_toast.dart';

class WebsiteSslSheet extends ConsumerStatefulWidget {
  const WebsiteSslSheet({
    super.key,
    required this.websiteId,
    required this.domain,
  });

  final int websiteId;
  final String domain;

  @override
  ConsumerState<WebsiteSslSheet> createState() => _WebsiteSslSheetState();
}

class _WebsiteSslSheetState extends ConsumerState<WebsiteSslSheet> {
  WebsiteHttpsDto? _https;
  List<WebsiteAcmeAccountDto> _accounts = const [];
  List<WebsiteSslDto> _certs = const [];
  int _accountId = 0;
  int _certId = 0;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final https = await repository.getWebsiteHttps(widget.websiteId);
      final accounts = await repository.searchAcmeAccounts();
      if (accounts.isEmpty) {
        setState(() {
          _https = https;
          _accounts = accounts;
          _loading = false;
        });
        return;
      }
      final accountId = accounts
          .firstWhere(
            (account) => account.id == https.ssl?.acmeAccountId,
            orElse: () => accounts.first,
          )
          .id;
      final certs = await repository.listWebsiteSsl(accountId);
      final currentId = https.ssl?.id ?? 0;
      if (!mounted) return;
      setState(() {
        _https = https;
        _accounts = accounts;
        _accountId = accountId;
        _certs = certs;
        _certId = certs.any((cert) => cert.id == currentId)
            ? currentId
            : (certs.isEmpty ? 0 : certs.first.id);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _loadCerts(int accountId) async {
    setState(() {
      _accountId = accountId;
      _certs = const [];
      _certId = 0;
      _loading = true;
    });
    try {
      final repository = await ref.read(websiteRepositoryProvider.future);
      final certs = await repository.listWebsiteSsl(accountId);
      if (!mounted) return;
      setState(() {
        _certs = certs;
        _certId = certs.isEmpty ? 0 : certs.first.id;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final https = _https;
    if (https == null) return;
    if (_certId <= 0) {
      AppToast.error(context, l10n.ssl_selectCertificate);
      return;
    }
    setState(() => _saving = true);
    try {
      final cert = _certs.firstWhere((item) => item.id == _certId);
      final repository = await ref.read(websiteRepositoryProvider.future);
      await repository.updateWebsiteHttps(widget.websiteId, {
        'acmeAccountID': _accountId,
        'enable': true,
        'websiteId': widget.websiteId,
        'websiteSSLId': _certId,
        'type': cert.type,
        'importType': 'local',
        'privateKey': '',
        'certificate': '',
        'privateKeyPath': '',
        'certificatePath': '',
        'httpConfig': https.httpConfig,
        'hsts': https.hsts,
        'hstsIncludeSubDomains': https.hstsIncludeSubDomains,
        'algorithm': https.algorithm,
        'SSLProtocol': https.sslProtocol ?? const ['TLSv1.2', 'TLSv1.3'],
        'httpsPort': https.httpsPort.isEmpty ? '443' : https.httpsPort,
        'http3': https.http3,
      });
      if (!mounted) return;
      AppToast.success(context, l10n.action_save);
      ref.invalidate(websiteDetailProvider(widget.websiteId));
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.scheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.ssl_bindTitle, style: AppTextStyles.titleL),
                  Text(
                    widget.domain,
                    style: AppTextStyles.bodyS.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.action_close,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(TablerIcons.x),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s16),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTokens.s32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_error!, style: AppTextStyles.bodyS),
              const SizedBox(height: AppTokens.s12),
              SecondaryButton(label: l10n.action_retry, onPressed: _load),
            ],
          )
        else ...[
          Text(l10n.ssl_acmeAccount, style: AppTextStyles.bodyS),
          const SizedBox(height: AppTokens.s8),
          DropdownButtonFormField<int>(
            initialValue: _accountId,
            items: [
              for (final account in _accounts)
                DropdownMenuItem(
                  value: account.id,
                  child: Text(account.displayName),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              _loadCerts(value);
            },
          ),
          const SizedBox(height: AppTokens.s16),
          Text(l10n.ssl_certificate, style: AppTextStyles.bodyS),
          const SizedBox(height: AppTokens.s8),
          if (_certs.isEmpty)
            Text(
              l10n.ssl_noCertificates,
              style: AppTextStyles.bodyS.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          else
            DropdownButtonFormField<int>(
              initialValue: _certId,
              items: [
                for (final cert in _certs)
                  DropdownMenuItem(
                    value: cert.id,
                    child: Text(
                      '${cert.primaryDomain} · ${cert.expireDate}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _certId = value ?? 0),
            ),
          const SizedBox(height: AppTokens.s24),
          PrimaryButton(
            label: l10n.action_save,
            icon: TablerIcons.shield_check,
            loading: _saving,
            onPressed: _saving || _certs.isEmpty ? null : _save,
          ),
        ],
      ],
    );
  }
}
