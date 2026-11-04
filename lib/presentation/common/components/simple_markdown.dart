import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/tokens.dart';

/// Lightweight Markdown renderer for README content.
///
/// Supports headings, paragraphs, bullet and numbered lists, fenced code,
/// block quotes, horizontal rules, inline code, bold text and links. Unknown
/// syntax renders as plain text so no content is lost.
class SimpleMarkdown extends StatelessWidget {
  const SimpleMarkdown({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildBlocks(context),
    );
  }

  List<Widget> _buildBlocks(BuildContext context) {
    final lines = data.replaceAll('\r\n', '\n').split('\n');
    final blocks = <Widget>[];
    var index = 0;
    while (index < lines.length) {
      final line = lines[index];
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        index++;
        continue;
      }
      if (trimmed.startsWith('```')) {
        final language = trimmed.substring(3).trim();
        final buffer = <String>[];
        index++;
        while (index < lines.length && !lines[index].trim().startsWith('```')) {
          buffer.add(lines[index]);
          index++;
        }
        if (index < lines.length) index++;
        blocks.add(_CodeBlock(language: language, lines: buffer));
        continue;
      }
      if (RegExp(r'^#{1,6}\s').hasMatch(trimmed)) {
        final level = trimmed.indexOf(' ');
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(
              top: AppTokens.s16,
              bottom: AppTokens.s8,
            ),
            child: _inline(
              context,
              trimmed.substring(level + 1).trim(),
              _headingStyle(level),
            ),
          ),
        );
        index++;
        continue;
      }
      if (RegExp(r'^(-{3,}|\*{3,}|_{3,})$').hasMatch(trimmed)) {
        blocks.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTokens.s12),
            child: Divider(height: 1),
          ),
        );
        index++;
        continue;
      }
      if (trimmed.startsWith('>')) {
        final buffer = <String>[];
        while (index < lines.length && lines[index].trim().startsWith('>')) {
          buffer.add(lines[index].trim().replaceFirst(RegExp(r'^>\s?'), ''));
          index++;
        }
        blocks.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: AppTokens.s8),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s12,
              vertical: AppTokens.s8,
            ),
            decoration: BoxDecoration(
              color: context.scheme.surfaceContainerHigh,
              border: Border(
                left: BorderSide(color: context.scheme.primary, width: 3),
              ),
            ),
            child: _inline(context, buffer.join('\n'), AppTextStyles.bodyS),
          ),
        );
        continue;
      }
      final bullet = RegExp(r'^([-*+]|\d+\.)\s+').firstMatch(trimmed);
      if (bullet != null) {
        final marker = bullet.group(1)!;
        final texts = <String>[];
        while (index < lines.length) {
          final current = lines[index].trim();
          final match = RegExp(r'^([-*+]|\d+\.)\s+').firstMatch(current);
          if (match == null) break;
          texts.add(current.substring(match.end));
          index++;
        }
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.s8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < texts.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.s4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            marker == '-' || marker == '*' || marker == '+'
                                ? '•'
                                : '${i + 1}.',
                            style: AppTextStyles.bodyM,
                          ),
                        ),
                        Expanded(
                          child: _inline(
                            context,
                            texts[i],
                            AppTextStyles.bodyM,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
        continue;
      }
      final paragraph = <String>[];
      while (index < lines.length) {
        final current = lines[index].trim();
        if (current.isEmpty ||
            current.startsWith('```') ||
            current.startsWith('>') ||
            RegExp(r'^#{1,6}\s').hasMatch(current) ||
            RegExp(r'^([-*+]|\d+\.)\s+').hasMatch(current) ||
            RegExp(r'^(-{3,}|\*{3,}|_{3,})$').hasMatch(current)) {
          break;
        }
        paragraph.add(current);
        index++;
      }
      if (paragraph.isEmpty) {
        index++;
        continue;
      }
      blocks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.s8),
          child: _inline(context, paragraph.join('\n'), AppTextStyles.bodyM),
        ),
      );
    }
    return blocks;
  }

  TextStyle _headingStyle(int level) {
    return switch (level) {
      1 => AppTextStyles.headline,
      2 => AppTextStyles.titleL,
      3 => AppTextStyles.titleM,
      _ => AppTextStyles.titleS,
    };
  }

  Widget _inline(BuildContext context, String text, TextStyle style) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'(\*\*[^*]+\*\*|`[^`]+`|\[[^\]]+\]\([^)]+\))');
    var cursor = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final token = match.group(0)!;
      if (token.startsWith('**')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      } else if (token.startsWith('`')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        );
      } else {
        final link = RegExp(r'\[([^\]]+)\]\(([^)]+)\)').firstMatch(token)!;
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => _open(link.group(2)!),
              child: Text(
                link.group(1)!,
                style: style.copyWith(
                  color: context.scheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        );
      }
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return Text.rich(TextSpan(style: style, children: spans), softWrap: true);
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.language, required this.lines});

  final String language;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppTokens.s8),
      padding: const EdgeInsets.all(AppTokens.s12),
      decoration: BoxDecoration(
        color: AppTokens.consoleBackground,
        borderRadius: BorderRadius.circular(AppTokens.rMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty) ...[
            Text(
              language,
              style: AppTextStyles.caption.copyWith(
                color: AppTokens.consoleMuted,
              ),
            ),
            const SizedBox(height: AppTokens.s4),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              lines.join('\n'),
              style: AppTextStyles.bodyS.copyWith(
                fontFamily: 'monospace',
                color: AppTokens.consoleForeground,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
