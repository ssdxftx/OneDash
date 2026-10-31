import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/localization/generated/app_localizations.dart';
import '../components/skeleton.dart';
import 'empty_state.dart';
import 'error_mapper.dart';
import 'error_state.dart';

/// 统一四态容器：loading / empty / error / data。
class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.loading,
    this.isEmpty,
    this.empty,
    this.errorBuilder,
    this.compactError = false,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final Widget? loading;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final Widget Function(Object error, StackTrace stack)? errorBuilder;
  final bool compactError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return value.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => SkeletonShimmer(child: loading ?? const SkeletonList()),
      error: (error, stack) {
        if (errorBuilder != null) return errorBuilder!(error, stack);
        return ErrorState(
          data: mapError(error, l10n),
          onRetry: onRetry,
          compact: compactError,
        );
      },
      data: (data) {
        if (isEmpty?.call(data) ?? false) {
          return empty ??
              EmptyState(
                icon: TablerIcons.inbox,
                title: l10n.common_empty_title,
                message: l10n.common_empty_message,
              );
        }
        return builder(data);
      },
    );
  }
}
