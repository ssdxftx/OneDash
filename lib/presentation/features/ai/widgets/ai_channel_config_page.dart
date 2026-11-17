import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/simple_form_page.dart';
import '../../../common/components/tonal_card.dart';

class AiChannelConfigPage extends StatefulWidget {
  const AiChannelConfigPage({
    super.key,
    required this.channel,
    required this.initial,
  });

  final String channel;
  final Map<String, dynamic> initial;

  @override
  State<AiChannelConfigPage> createState() => _AiChannelConfigPageState();
}

class _AiChannelConfigPageState extends State<AiChannelConfigPage> {
  late bool _enabled;
  late String _dmPolicy;
  late String _groupPolicy;
  late String _streaming;
  late bool _requireMention;
  late bool _separateSession;
  late bool _sharedMemory;
  late bool _asyncMode;
  late TextEditingController _allowFrom;
  late TextEditingController _groupAllowFrom;
  late TextEditingController _proxy;
  late TextEditingController _defaultAccount;
  late TextEditingController _botId;
  late TextEditingController _secret;
  late TextEditingController _ackText;
  late String _groupSessionScope;
  final List<_BotDraft> _bots = [];

  bool get _supportsBots => const {
    'telegram',
    'discord',
    'qqbot',
    'dingtalk',
  }.contains(widget.channel);
  bool get _supportsGroupAllowFrom => widget.channel != 'discord';
  bool get _showsProxy =>
      widget.channel == 'telegram' || widget.channel == 'discord';
  bool get _showsDefaultAccount =>
      widget.channel == 'telegram' || widget.channel == 'discord';

  @override
  void initState() {
    super.initState();
    final data = widget.initial;
    _enabled = data['enabled'] == true;
    _dmPolicy = _valid(data['dmPolicy'], const [
      'pairing',
      'open',
      'allowlist',
      'disabled',
    ], 'pairing');
    _groupPolicy = _valid(data['groupPolicy'], const [
      'open',
      'allowlist',
      'disabled',
    ], 'open');
    _streaming = _valid(data['streaming'], const [
      'off',
      'partial',
      'block',
      'progress',
    ], 'off');
    _requireMention = data['requireMention'] == true;
    _separateSession = data['separateSessionByConversation'] == true;
    _sharedMemory = data['sharedMemoryAcrossConversations'] == true;
    _asyncMode = data['asyncMode'] == true;
    _groupSessionScope = _valid(data['groupSessionScope'], const [
      'group',
      'group_sender',
    ], 'group');
    _allowFrom = TextEditingController(
      text: _stringList(data['allowFrom']).join(', '),
    );
    _groupAllowFrom = TextEditingController(
      text: _stringList(data['groupAllowFrom']).join(', '),
    );
    _proxy = TextEditingController(text: '${data['proxy'] ?? ''}');
    _defaultAccount = TextEditingController(
      text: '${data['defaultAccount'] ?? ''}',
    );
    _botId = TextEditingController(text: '${data['botId'] ?? ''}');
    _secret = TextEditingController(text: '${data['secret'] ?? ''}');
    _ackText = TextEditingController(text: '${data['ackText'] ?? ''}');
    final rawBots = data['bots'];
    if (rawBots is List) {
      for (final bot in rawBots.whereType<Map>()) {
        _bots.add(_BotDraft.fromJson(bot));
      }
    }
    if (_bots.isEmpty && _supportsBots) {
      _bots.add(_BotDraft.empty());
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _allowFrom,
      _groupAllowFrom,
      _proxy,
      _defaultAccount,
      _botId,
      _secret,
      _ackText,
    ]) {
      controller.dispose();
    }
    for (final bot in _bots) {
      bot.dispose();
    }
    super.dispose();
  }

  String _valid(Object? value, List<String> allowed, String fallback) {
    final text = value?.toString().trim() ?? '';
    return allowed.contains(text) ? text : fallback;
  }

  List<String> _stringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => '$item'.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return _splitIds(value?.toString() ?? '');
  }

  List<String> _splitIds(String raw) => raw
      .split(RegExp(r'[,\n]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);

  String _policyLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'pairing' => l10n.ai_agent_policy_pairing,
      'open' => l10n.ai_agent_policy_open,
      'allowlist' => l10n.ai_agent_policy_allowlist,
      'disabled' => l10n.ai_agent_policy_disabled,
      _ => value,
    };
  }

  String _streamingLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'off' => l10n.ai_agent_streaming_off,
      'partial' => l10n.ai_agent_streaming_partial,
      'block' => l10n.ai_agent_streaming_block,
      'progress' => l10n.ai_agent_streaming_progress,
      _ => value,
    };
  }

  Widget _policyDropdown(
    AppLocalizations l10n, {
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem(value: item, child: Text(_policyLabel(l10n, item))),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }

  Widget _streamingDropdown(
    AppLocalizations l10n, {
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: l10n.ai_agent_streaming),
      items: [
        for (final item in const ['off', 'partial', 'block', 'progress'])
          DropdownMenuItem(
            value: item,
            child: Text(_streamingLabel(l10n, item)),
          ),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SimpleFormPage(
      title: '${l10n.ai_agent_channel_config} · ${widget.channel}',
      saveLabel: l10n.action_save,
      onSave: () async => Navigator.of(context).pop(_payload()),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.ai_agent_channel_enabled),
          value: _enabled,
          onChanged: (value) => setState(() => _enabled = value),
        ),
        _policyDropdown(
          l10n,
          label: l10n.ai_agent_dm_policy,
          value: _dmPolicy,
          values: const ['pairing', 'open', 'allowlist', 'disabled'],
          onChanged: (value) => setState(() => _dmPolicy = value),
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: _allowFrom,
          label: l10n.ai_agent_allow_from,
          hint: l10n.ai_agent_allow_from_hint,
        ),
        const SizedBox(height: AppTokens.s12),
        _policyDropdown(
          l10n,
          label: l10n.ai_agent_group_policy,
          value: _groupPolicy,
          values: const ['open', 'allowlist', 'disabled'],
          onChanged: (value) => setState(() => _groupPolicy = value),
        ),
        if (_supportsGroupAllowFrom) ...[
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: _groupAllowFrom,
            label: l10n.ai_agent_group_allow_from,
            hint: l10n.ai_agent_allow_from_hint,
          ),
        ],
        if (_showsProxy) ...[
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: _proxy,
            label: l10n.ai_agent_proxy,
            hint: 'http://127.0.0.1:7890',
          ),
        ],
        if (_showsDefaultAccount) ...[
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: _defaultAccount,
            label: l10n.ai_agent_default_account,
          ),
        ],
        if (widget.channel == 'telegram') ...[
          const SizedBox(height: AppTokens.s12),
          _streamingDropdown(
            l10n,
            value: _streaming,
            onChanged: (value) => setState(() => _streaming = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.ai_agent_require_mention),
            value: _requireMention,
            onChanged: (value) => setState(() => _requireMention = value),
          ),
        ],
        if (widget.channel == 'discord')
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.ai_agent_require_mention),
            value: _requireMention,
            onChanged: (value) => setState(() => _requireMention = value),
          ),
        if (widget.channel == 'wecom') ...[
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: _botId, label: l10n.ai_agent_bot_id),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: _secret,
            label: l10n.ai_agent_bot_secret,
            obscure: true,
          ),
        ],
        if (widget.channel == 'dingtalk') ...[
          const SizedBox(height: AppTokens.s12),
          DropdownButtonFormField<String>(
            initialValue: _groupSessionScope,
            decoration: InputDecoration(
              labelText: l10n.ai_agent_group_session_scope,
            ),
            items: [
              DropdownMenuItem(
                value: 'group',
                child: Text(l10n.ai_agent_group_scope_group),
              ),
              DropdownMenuItem(
                value: 'group_sender',
                child: Text(l10n.ai_agent_group_scope_sender),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _groupSessionScope = value);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.ai_agent_separate_session),
            value: _separateSession,
            onChanged: (value) => setState(() => _separateSession = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.ai_agent_shared_memory),
            value: _sharedMemory,
            onChanged: (value) => setState(() => _sharedMemory = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.ai_agent_async_mode),
            value: _asyncMode,
            onChanged: (value) => setState(() => _asyncMode = value),
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(controller: _ackText, label: l10n.ai_agent_ack_text),
        ],
        if (_supportsBots) ...[
          const SizedBox(height: AppTokens.s24),
          _botsHeader(l10n),
          const SizedBox(height: AppTokens.s8),
          for (var index = 0; index < _bots.length; index++) ...[
            _botCard(index, l10n),
            const SizedBox(height: AppTokens.s12),
          ],
        ],
      ],
    );
  }

  Widget _botsHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: Text(l10n.ai_agent_bots, style: AppTextStyles.titleM)),
        TextButton.icon(
          onPressed: _addBot,
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.ai_agent_add_bot),
        ),
      ],
    );
  }

  void _addBot() {
    setState(() {
      final bot = _BotDraft.empty();
      bot.isDefault = _bots.every((item) => !item.isDefault);
      _bots.add(bot);
    });
  }

  Widget _botCard(int index, AppLocalizations l10n) {
    final bot = _bots[index];
    return TonalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bot.name.text.trim().isEmpty
                      ? '${l10n.ai_agent_bot_name} ${index + 1}'
                      : bot.name.text.trim(),
                  style: AppTextStyles.titleS,
                ),
              ),
              if (_bots.length > 1)
                IconButton(
                  tooltip: l10n.ai_agent_remove_bot,
                  onPressed: () => setState(() {
                    _bots.removeAt(index).dispose();
                  }),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          AppTextField(controller: bot.name, label: l10n.ai_agent_bot_name),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            controller: bot.accountId,
            label: l10n.ai_agent_account_id,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.ai_agent_channel_enabled),
            value: bot.enabled,
            onChanged: (value) => setState(() => bot.enabled = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.ai_agent_bot_default),
            value: bot.isDefault,
            onChanged: (value) => _setDefaultBot(index, value),
          ),
          ..._botFields(bot, l10n),
        ],
      ),
    );
  }

  void _setDefaultBot(int index, bool value) {
    setState(() {
      for (var i = 0; i < _bots.length; i++) {
        _bots[i].isDefault = i == index && value;
      }
    });
  }

  List<Widget> _botFields(_BotDraft bot, AppLocalizations l10n) {
    return switch (widget.channel) {
      'telegram' => [
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: bot.token,
          label: l10n.ai_agent_bot_token,
          obscure: true,
        ),
        const SizedBox(height: AppTokens.s12),
        _policyDropdown(
          l10n,
          label: l10n.ai_agent_dm_policy,
          value: bot.dmPolicy.text,
          values: const ['pairing', 'open', 'allowlist', 'disabled'],
          onChanged: (value) => setState(() => bot.dmPolicy.text = value),
        ),
        const SizedBox(height: AppTokens.s12),
        _policyDropdown(
          l10n,
          label: l10n.ai_agent_group_policy,
          value: bot.groupPolicy.text,
          values: const ['open', 'allowlist', 'disabled'],
          onChanged: (value) => setState(() => bot.groupPolicy.text = value),
        ),
        const SizedBox(height: AppTokens.s12),
        _streamingDropdown(
          l10n,
          value: bot.streaming.text,
          onChanged: (value) => setState(() => bot.streaming.text = value),
        ),
      ],
      'discord' => [
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: bot.token,
          label: l10n.ai_agent_bot_token,
          obscure: true,
        ),
      ],
      'qqbot' => [
        const SizedBox(height: AppTokens.s12),
        AppTextField(controller: bot.appId, label: l10n.ai_agent_bot_app_id),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: bot.clientSecret,
          label: l10n.ai_agent_bot_client_secret,
          obscure: true,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: bot.allowFrom,
          label: l10n.ai_agent_allow_from,
          hint: l10n.ai_agent_allow_from_hint,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: bot.systemPrompt,
          label: l10n.ai_agent_bot_system_prompt,
          maxLines: 3,
        ),
      ],
      'dingtalk' => [
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: bot.clientId,
          label: l10n.ai_agent_bot_client_id,
        ),
        const SizedBox(height: AppTokens.s12),
        AppTextField(
          controller: bot.clientSecret,
          label: l10n.ai_agent_bot_client_secret,
          obscure: true,
        ),
      ],
      _ => const [],
    };
  }

  Map<String, dynamic> _payload() {
    final payload = Map<String, dynamic>.from(widget.initial);
    payload['enabled'] = _enabled;
    payload['dmPolicy'] = _dmPolicy;
    payload['allowFrom'] = _splitIds(_allowFrom.text);
    payload['groupPolicy'] = _groupPolicy;
    if (_supportsGroupAllowFrom) {
      payload['groupAllowFrom'] = _splitIds(_groupAllowFrom.text);
    }
    switch (widget.channel) {
      case 'telegram':
        payload['proxy'] = _proxy.text.trim();
        payload['streaming'] = _streaming;
        payload['requireMention'] = _requireMention;
        payload['defaultAccount'] = _defaultAccountText();
      case 'discord':
        payload['proxy'] = _proxy.text.trim();
        payload['requireMention'] = _requireMention;
        payload['defaultAccount'] = _defaultAccountText();
      case 'wecom':
        payload['botId'] = _botId.text.trim();
        payload['secret'] = _secret.text.trim();
      case 'dingtalk':
        payload['separateSessionByConversation'] = _separateSession;
        payload['sharedMemoryAcrossConversations'] = _sharedMemory;
        payload['asyncMode'] = _asyncMode;
        payload['groupSessionScope'] = _groupSessionScope;
        payload['ackText'] = _ackText.text.trim();
    }
    if (_supportsBots) {
      payload['bots'] = _bots.map((bot) => bot.toJson()).toList();
    }
    return payload;
  }

  String _defaultAccountText() {
    final value = _defaultAccount.text.trim();
    if (value.isNotEmpty) return value;
    for (final bot in _bots) {
      final account = bot.accountId.text.trim();
      if (account.isNotEmpty) return account;
    }
    for (final bot in _bots) {
      if (bot.isDefault) return bot.accountId.text.trim();
    }
    return '';
  }
}

class _BotDraft {
  _BotDraft({
    required this.accountId,
    required this.name,
    required this.token,
    required this.dmPolicy,
    required this.groupPolicy,
    required this.streaming,
    required this.appId,
    required this.clientId,
    required this.clientSecret,
    required this.allowFrom,
    required this.systemPrompt,
    required this.enabled,
    required this.isDefault,
  });

  factory _BotDraft.empty() {
    return _BotDraft(
      accountId: TextEditingController(),
      name: TextEditingController(),
      token: TextEditingController(),
      dmPolicy: TextEditingController(text: 'pairing'),
      groupPolicy: TextEditingController(text: 'open'),
      streaming: TextEditingController(text: 'off'),
      appId: TextEditingController(),
      clientId: TextEditingController(),
      clientSecret: TextEditingController(),
      allowFrom: TextEditingController(),
      systemPrompt: TextEditingController(),
      enabled: true,
      isDefault: true,
    );
  }

  factory _BotDraft.fromJson(Map<dynamic, dynamic> json) {
    final data = Map<String, dynamic>.from(json);
    return _BotDraft(
      accountId: TextEditingController(text: '${data['accountId'] ?? ''}'),
      name: TextEditingController(text: '${data['name'] ?? ''}'),
      token: TextEditingController(
        text: '${data['botToken'] ?? data['token'] ?? ''}',
      ),
      dmPolicy: TextEditingController(text: '${data['dmPolicy'] ?? 'pairing'}'),
      groupPolicy: TextEditingController(
        text: '${data['groupPolicy'] ?? 'open'}',
      ),
      streaming: TextEditingController(text: '${data['streaming'] ?? 'off'}'),
      appId: TextEditingController(text: '${data['appId'] ?? ''}'),
      clientId: TextEditingController(text: '${data['clientId'] ?? ''}'),
      clientSecret: TextEditingController(
        text: '${data['clientSecret'] ?? ''}',
      ),
      allowFrom: TextEditingController(text: _listText(data['allowFrom'])),
      systemPrompt: TextEditingController(
        text: '${data['systemPrompt'] ?? ''}',
      ),
      enabled: data['enabled'] != false,
      isDefault: data['isDefault'] == true,
    );
  }

  final TextEditingController accountId;
  final TextEditingController name;
  final TextEditingController token;
  final TextEditingController dmPolicy;
  final TextEditingController groupPolicy;
  final TextEditingController streaming;
  final TextEditingController appId;
  final TextEditingController clientId;
  final TextEditingController clientSecret;
  final TextEditingController allowFrom;
  final TextEditingController systemPrompt;
  bool enabled;
  bool isDefault;

  void dispose() {
    for (final controller in [
      accountId,
      name,
      token,
      dmPolicy,
      groupPolicy,
      streaming,
      appId,
      clientId,
      clientSecret,
      allowFrom,
      systemPrompt,
    ]) {
      controller.dispose();
    }
  }

  Map<String, dynamic> toJson() => {
    'accountId': accountId.text.trim(),
    'name': name.text.trim(),
    'enabled': enabled,
    'isDefault': isDefault,
    'botToken': token.text.trim(),
    'token': token.text.trim(),
    'dmPolicy': dmPolicy.text,
    'groupPolicy': groupPolicy.text,
    'streaming': streaming.text,
    'appId': appId.text.trim(),
    'clientId': clientId.text.trim(),
    'clientSecret': clientSecret.text.trim(),
    'allowFrom': allowFrom.text
        .split(RegExp(r'[,\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false),
    'systemPrompt': systemPrompt.text.trim(),
  };
}


String _listText(Object? value) {
  if (value is List) return value.map((item) => '$item').join(', ');
  return value?.toString() ?? '';
}
