import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../data/repositories_impl/ai_repository_impl.dart';
import '../../../common/components/app_bar_large.dart';
import '../../../common/components/app_text_field.dart';
import '../../../common/components/skeleton.dart';
import '../../../common/states/empty_state.dart';
import '../../../common/states/error_toast.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key, required this.accountId, this.accountName = ''});

  final int accountId;
  final String accountName;

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_ChatMessage> _messages = [];
  List<Map<String, dynamic>> _models = const [];
  String? _model;
  bool _loading = true;
  bool _failed = false;
  bool _sending = false;
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final models = await repository.getAccountModels(widget.accountId);
      if (!mounted) return;
      final verified = models.where((item) => item['isVerifyModel'] == true);
      final preferred = verified.isNotEmpty ? verified.first : null;
      setState(() {
        _models = models;
        _model =
            preferred?['id']?.toString() ??
            models.firstOrNull?['id']?.toString();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBarLarge(
        title: widget.accountName.isEmpty
            ? l10n.ai_chat_title
            : widget.accountName,
      ),
      body: _loading
          ? const SkeletonList(itemCount: 4)
          : _failed
          ? EmptyState(
              icon: TablerIcons.alert_triangle,
              title: l10n.common_notAvailable,
              actionLabel: l10n.action_retry,
              onAction: _load,
            )
          : _models.isEmpty
          ? EmptyState(
              icon: TablerIcons.brain,
              title: l10n.ai_chat_noModels,
              actionLabel: l10n.action_retry,
              onAction: _load,
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.pagePadding,
                    AppTokens.s12,
                    context.pagePadding,
                    0,
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _model,
                    decoration: InputDecoration(labelText: l10n.ai_chat_model),
                    items: [
                      for (final model in _models)
                        DropdownMenuItem(
                          value: '${model['id']}',
                          child: Text('${model['name'] ?? model['id'] ?? ''}'),
                        ),
                    ],
                    onChanged: _sending
                        ? null
                        : (value) => setState(() => _model = value),
                  ),
                ),
                Expanded(
                  child: _messages.isEmpty
                      ? EmptyState(
                          icon: TablerIcons.message_chatbot,
                          title: l10n.ai_chat_empty,
                          compact: true,
                        )
                      : ListView.builder(
                          controller: _scroll,
                          padding: EdgeInsets.all(context.pagePadding),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) =>
                              _MessageBubble(message: _messages[index]),
                        ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.pagePadding,
                      AppTokens.s8,
                      context.pagePadding,
                      AppTokens.s12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _input,
                            label: l10n.ai_chat_input,
                            maxLines: 4,
                            enabled: !_sending,
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: AppTokens.s8),
                        _sending
                            ? AppIconButton(
                                icon: TablerIcons.player_stop,
                                tooltip: l10n.ai_chat_stop,
                                onPressed: _stop,
                              )
                            : AppIconButton(
                                icon: TablerIcons.send,
                                tooltip: l10n.ai_chat_send,
                                onPressed: _send,
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    final model = _model;
    if (text.isEmpty || model == null || _sending) return;
    final history = [
      for (final message in _messages)
        if (message.content.isNotEmpty)
          {'role': message.role, 'content': message.content},
      {'role': 'user', 'content': text},
    ];
    setState(() {
      _sending = true;
      _messages
        ..add(_ChatMessage(role: 'user', content: text))
        ..add(const _ChatMessage(role: 'assistant', content: ''));
      _input.clear();
    });
    _scrollToEnd();
    try {
      final repository = await ref.read(aiRepositoryProvider.future);
      final stream = repository.chatAccount(
        id: widget.accountId,
        model: model,
        messages: history,
      );
      _subscription = stream.listen(
        (delta) {
          if (!mounted) return;
          setState(() {
            final current = _messages.last;
            _messages[_messages.length - 1] = _ChatMessage(
              role: current.role,
              content: current.content + delta,
            );
          });
          _scrollToEnd();
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() => _sending = false);
          showErrorToast(context, error);
        },
        onDone: () {
          if (!mounted) return;
          setState(() => _sending = false);
        },
        cancelOnError: true,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      showErrorToast(context, error);
    }
  }

  void _stop() {
    _subscription?.cancel();
    setState(() => _sending = false);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: AppTokens.dFast,
        curve: AppTokens.curveFast,
      );
    });
  }
}

class _ChatMessage {
  const _ChatMessage({required this.role, required this.content});

  final String role;
  final String content;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final user = message.role == 'user';
    final scheme = context.scheme;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        margin: const EdgeInsets.only(bottom: AppTokens.s8),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s16,
          vertical: AppTokens.s12,
        ),
        decoration: BoxDecoration(
          color: user ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppTokens.rMd),
        ),
        child: Text(
          message.content.isEmpty ? '…' : message.content,
          style: AppTextStyles.bodyM.copyWith(
            color: user ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
